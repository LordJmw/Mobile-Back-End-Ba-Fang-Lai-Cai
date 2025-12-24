import 'dart:async';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:projek_uts_mbr/auth/loginCostumer.dart';
import 'package:projek_uts_mbr/databases/customerDatabase.dart';
import 'package:projek_uts_mbr/databases/purchaseHistoryDatabase.dart';
import 'package:projek_uts_mbr/model/CustomerModel.dart';
import 'package:projek_uts_mbr/model/purchaseHistoryModel.dart';
import 'package:projek_uts_mbr/services/sessionManager.dart';
import 'package:projek_uts_mbr/analytics/eventLogs.dart';
import 'package:projek_uts_mbr/l10n/app_localizations.dart';

class ProfileService {
  final CustomerDatabase _customerDb = CustomerDatabase();
  final Purchasehistorydatabase _purchaseDb = Purchasehistorydatabase();
  final SessionManager _sessionManager = SessionManager();

  Future<void> logout(BuildContext context) async {
    await _sessionManager.logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginCustomer()),
      (route) => false,
    );
  }

  Future<CustomerModel?> loadCustomerData() async {
    try {
      final customer = await _customerDb.getCurrentCustomer();
      print('customer loaded: $customer');
      return customer;
    } catch (e) {
      print("Error loading customer data: $e");
      rethrow;
    }
  }

  Future<List<PurchaseHistory>> loadPurchaseHistory() async {
    try {
      final user = await _customerDb.getCurrentCustomer();
      if (user == null) {
        print("User belum login, tidak bisa load purchase history");
        return [];
      }
      print("purchase database di profile service");
      final history = await _purchaseDb.getPurchaseHistory();
      print("Loaded ${history.length} purchase history items");
      return history;
    } catch (e) {
      print("Error loading purchase history: $e");
      return [];
    }
  }

  Future<File?> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  Future<String?> uploadProfilePicture(File image, String customerId) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_pictures')
          .child('$customerId.jpg');
      await storageRef.putFile(image);
      return await storageRef.getDownloadURL();
    } catch (e) {
      print("Error uploading profile picture: $e");
      return null;
    }
  }

  Future<bool> updateUserProfile(CustomerModel updatedCustomer) async {
    try {
      final result = await _customerDb.updateCustomerProfile(updatedCustomer);
      if (result) {
        await Eventlogs().logProfileEdited(updatedCustomer.email, "customer");
      }
      return result;
    } catch (e) {
      print("Error updating profile: $e");
      return false;
    }
  }

  Future<void> deletePurchase(int purchaseId, String vendorName) async {
    await _purchaseDb.deletePurchaseHistory(purchaseId);
    await Eventlogs().deletePaket(purchaseId, vendorName);
  }

  Future<void> updatePurchase(PurchaseHistory purchase) async {
    await _purchaseDb.updatePurchaseHistory(purchase);
    await Eventlogs().editPaket(
      purchase.id,
      purchase.customerId!,
      purchase.purchaseDetails,
      purchase.purchaseDate,
    );
  }
}
