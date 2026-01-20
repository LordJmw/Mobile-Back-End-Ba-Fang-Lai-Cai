// test/mock_profile_dependencies.dart
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// Mock models
class MockCustomerModel {
  final int id;
  final String nama;
  final String email;
  final String password;
  final String telepon;
  final String alamat;
  final String? fotoProfil;

  MockCustomerModel({
    required this.id,
    required this.nama,
    required this.email,
    required this.password,
    required this.telepon,
    required this.alamat,
    this.fotoProfil,
  });
}

class MockPurchaseHistory {
  final int id;
  final int customerId;
  final MockPurchaseDetails purchaseDetails;
  final DateTime purchaseDate;

  MockPurchaseHistory({
    required this.id,
    required this.customerId,
    required this.purchaseDetails,
    required this.purchaseDate,
  });
}

class MockPurchaseDetails {
  final String vendor;
  final String packageName;
  final double price;
  final DateTime date;
  final String location;
  final String notes;
  final String status;

  MockPurchaseDetails({
    required this.vendor,
    required this.packageName,
    required this.price,
    required this.date,
    required this.location,
    required this.notes,
    required this.status,
  });
}

// Mock ProfileService
class MockProfileService {
  Future<MockCustomerModel?> loadCustomerData() async {
    await Future.delayed(Duration(milliseconds: 100));
    return MockCustomerModel(
      id: 1,
      nama: 'Test User',
      email: 'test@example.com',
      password: 'password',
      telepon: '08123456789',
      alamat: 'Test Address',
      fotoProfil: null,
    );
  }

  Future<List<MockPurchaseHistory>> loadPurchaseHistory() async {
    await Future.delayed(Duration(milliseconds: 100));
    return [
      MockPurchaseHistory(
        id: 1,
        customerId: 1,
        purchaseDetails: MockPurchaseDetails(
          vendor: 'Test Vendor',
          packageName: 'Test Package',
          price: 100000,
          date: DateTime.now(),
          location: 'Test Location',
          notes: 'Test Notes',
          status: 'Completed',
        ),
        purchaseDate: DateTime.now(),
      ),
    ];
  }

  Future<void> logout(BuildContext context) async {
    await Future.delayed(Duration(milliseconds: 100));
  }

  Future<File?> pickImage(ImageSource source) async {
    await Future.delayed(Duration(milliseconds: 100));
    return null;
  }

  Future<String?> uploadProfilePicture(File image, String userId) async {
    await Future.delayed(Duration(milliseconds: 100));
    return 'https://example.com/profile.jpg';
  }

  Future<bool> updateUserProfile(MockCustomerModel customer) async {
    await Future.delayed(Duration(milliseconds: 100));
    return true;
  }

  Future<void> updatePurchase(MockPurchaseHistory purchase) async {
    await Future.delayed(Duration(milliseconds: 100));
  }

  Future<void> deletePurchase(int purchaseId, String vendorName) async {
    await Future.delayed(Duration(milliseconds: 100));
  }
}

// Mock AppLocalizations
class MockAppLocalizations {
  String get userProfile => 'User Profile';
  String get editProfile => 'Edit Profile';
  String get cancel => 'Cancel';
  String get save => 'Save';
  String get fullName => 'Full Name';
  String get phoneNumber => 'Phone Number';
  String get address => 'Address';
  String get editOrder => 'Edit Order';
  String get deleteOrder => 'Delete Order';
  String get eventDate => 'Event Date';
  String get selectDate => 'Select Date';
  String get location => 'Location';
  String get enterEventLocation => 'Enter event location';
  String get specialNotes => 'Special Notes';
  String get addNotes => 'Add notes...';
  String get confirmDelete => 'Confirm delete order from';
  String get delete => 'Delete';
  String get yourPurchaseHistory => 'Your Purchase History';
  String get noPurchasesYet => 'No purchases yet';
  String get pleaseBuyPackage => 'Please buy a package first';
  String get permissionDenied => 'Permission denied';
  String get noContactsFound => 'No contacts found';
  String get inviteFriends => 'Invite Friends';
  String get chooseContactToInvite => 'Choose a contact to invite';
  String get noPhoneNumber => 'No phone number';
  String get inviteButton => 'Invite';

  String inviteTitle(String name) => 'Invite $name';
  String inviteMessage(String name) => 'Send invitation to $name?';
  String inviteSuccess(String name) => 'Invitation sent to $name';
  String sendInvitation() => 'Send Invitation';
}
