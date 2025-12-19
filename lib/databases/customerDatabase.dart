import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projek_uts_mbr/databases/database.dart';
import 'package:projek_uts_mbr/helper/base_url.dart';
import 'package:projek_uts_mbr/model/CustomerModel.dart';
import 'package:http/http.dart' as http;

class CustomerDatabase {
  final DatabaserService _dbService = DatabaserService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore firestorDb = FirebaseFirestore.instance;

  Future insertCustomer(CustomerModel customer) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: customer.email,
            password: customer.password,
          );
      String uid = userCredential.user!.uid;
      print("Register customer sukses with UID: $uid");

      var customerToAdd = {
        "id": uid,
        "nama": customer.nama,
        "email": customer.email,
        "telepon": customer.telepon,
        "alamat": customer.alamat,
        "fotoProfil": customer.fotoProfil,
      };

      await firestorDb.collection("customers").doc(uid).set(customerToAdd);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        print("Email sudah digunakan");
        throw Exception("EMAIL_USED");
      } else {
        print("FirebaseAuth error: ${e.code} - ${e.message}");
        throw Exception("FIREBASE_ERROR");
      }
    } catch (e) {
      print("Error register customer: $e");
      rethrow;
    }
  }

  Future<CustomerModel?> LoginCustomer(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;
      print("Login customer sukses with UID: $uid");

      final testDoc = await FirebaseFirestore.instance
          .collection("customers")
          .doc(uid)
          .get();

      print("DOC EXISTS? ${testDoc.exists}");
      print("DOC DATA = ${testDoc.data()}");

      DocumentSnapshot<Map<String, dynamic>> doc = await firestorDb
          .collection("customers")
          .doc(uid)
          .get();

      if (doc.exists) {
        return CustomerModel.fromJson(doc.data()!);
      }

      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('Tidak ada user dengan email tersebut.');
      } else if (e.code == 'wrong-password') {
        print('Password salah.');
      } else if (e.code == 'invalid-email') {
        print('Format email tidak valid.');
      } else {
        print('${e.code} Firebase Auth error: ${e.message}');
      }
      return null;
    } catch (e) {
      print("Error login customer: $e");
      rethrow;
    }
  }

  Future<CustomerModel?> getCustomerByEmail(String email) async {
    try {
      QuerySnapshot<Map<String, dynamic>> customerDariEmail = await firestorDb
          .collection("customers")
          .where("email", isEqualTo: email)
          .limit(1)
          .get();

      if (customerDariEmail.docs.isNotEmpty) {
        var customer = customerDariEmail.docs.first.data();
        return CustomerModel.fromJson(customer);
      } else {
        print("customers dengan email ${email} tidak ditemukan");
        return null;
      }
    } catch (e) {
      print("error getCustomer by email: $e");
      rethrow;
    }
  }

  Future<bool> updateCustomerProfile(CustomerModel customer) async {
    try {
      QuerySnapshot<Map<String, dynamic>> query = await firestorDb
          .collection("customers")
          .where("email", isEqualTo: customer.email)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        print("customer dengan email ${customer.email} tidak ditemukan");
        return false;
      }

      String id = query.docs.first.data()['id'];

      Map<String, dynamic> updatedProfile = {
        'id': id,
        "nama": customer.nama,
        "email": customer.email,
        "telepon": customer.telepon,
        "alamat": customer.alamat,
        "fotoProfil": customer.fotoProfil,
      };

      await firestorDb.collection("customers").doc(id).update(updatedProfile);

      final user = _auth.currentUser;
      if (user != null) {
        await user.updateDisplayName(customer.nama);
        await user.reload();
        print("Firebase Auth displayName updated");
      }

      print("update profile customer sukses");
      return true;
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<bool> updateCustomerPremiumStatus({
    required String customerEmail,
    required bool isPremiumUser,
    required DateTime expiryDate,
    DateTime? startDate,
  }) async {
    try {
      QuerySnapshot<Map<String, dynamic>> query = await firestorDb
          .collection("customers")
          .where("email", isEqualTo: customerEmail)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        print("customer dengan email $customerEmail tidak ditemukan");
        return false;
      }

      String id = query.docs.first.id;

      Map<String, dynamic> premiumUpdate = {
        'isPremiumUser': isPremiumUser,
        'premiumExpiryDate': expiryDate.toIso8601String(),
        'premiumStartDate': (startDate ?? DateTime.now()).toIso8601String(),
        'premiumUpdatedAt': FieldValue.serverTimestamp(),
      };

      await firestorDb.collection("customers").doc(id).update(premiumUpdate);

      print("Premium status updated for $customerEmail");
      return true;
    } catch (e) {
      print("Error updating premium status: $e");
      return false;
    }
  }

  Future<void> printAllCustomers() async {
    final db = await _dbService.getDatabase();
    final Customers = await db.query('Customer');
    print("Daftar Customer:");
    for (var v in Customers) {
      print(v);
    }
  }

  Future<String> getCurrentUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("NO_USER_LOGGED_IN");
    }
    return user.uid;
  }

  Future<bool> isUserPremium() async {
    CustomerModel? currCustomer = await getCurrentCustomer();
    return currCustomer!.isPremiumUser;
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<CustomerModel?> getCurrentCustomer() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;

    final doc = await firestorDb.collection("customers").doc(uid).get();
    if (!doc.exists) return null;

    return CustomerModel.fromJson(doc.data()!);
  }

  Future<bool> deleteCustomerAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception("NO_USER_LOGGED_IN");
      }

      final String uid = user.uid;
      final String email = user.email ?? '';

      await firestorDb.collection("customers").doc(uid).delete();
      print("Customer document deleted successfully");

      await user.delete();
      print("Firebase Auth user deleted successfully");

      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        print('User needs to reauthenticate.');
        throw Exception("REQUIRES_RECENT_LOGIN");
      }
      print("Firebase Auth error during deletion: ${e.code} - ${e.message}");
      throw Exception("AUTH_ERROR");
    } catch (e) {
      print("Error deleting customer account: $e");
      rethrow;
    }
  }

  Future<void> reauthenticateUser(String password) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception("NO_USER_LOGGED_IN");
      }

      final email = user.email;
      if (email == null) {
        throw Exception("NO_EMAIL_FOUND");
      }

      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);
      print("User reauthenticated successfully");
    } on FirebaseAuthException catch (e) {
      print("Reauthentication failed: ${e.code} - ${e.message}");
      if (e.code == 'wrong-password') {
        throw Exception("WRONG_PASSWORD");
      } else if (e.code == 'user-mismatch') {
        throw Exception("USER_MISMATCH");
      } else if (e.code == 'user-not-found') {
        throw Exception("USER_NOT_FOUND");
      } else if (e.code == 'invalid-credential') {
        throw Exception("INVALID_CREDENTIAL");
      } else if (e.code == 'invalid-email') {
        throw Exception("INVALID_EMAIL");
      } else if (e.code == 'too-many-requests') {
        throw Exception("TOO_MANY_REQUESTS");
      }
      throw Exception("REAUTH_FAILED");
    }
  }
}
