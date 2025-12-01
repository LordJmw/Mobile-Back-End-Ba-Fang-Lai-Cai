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

      // final url = Uri.parse("${base_url.customer}/register");
      // final response = await http.post(
      //   url,
      //   headers: {"Content-Type": "application/json"},
      //   body: jsonEncode({
      //     "id": uid,
      //     "nama": customer.nama,
      //     "email": customer.email,
      //     "password": customer.password,
      //     "telepon": customer.telepon,
      //     "alamat": customer.alamat,
      //   }),
      // );
      // if (response.statusCode == 201) {
      //   print("Register ke Node.js sukses");
      //   final data = jsonDecode(response.body);
      //   return data['customerId'];
      // } else {
      //    print("Gagal register ke Node.js: ${response.statusCode}");
      //    print("Body: ${response.body}");
      //   throw Exception("Register Node.js gagal");
      // }
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

      // final url = Uri.parse("${base_url.customer}/login");
      // final response = await http.post(
      //   url,
      //   headers: {"Content-Type": "application/json"},
      //   body: jsonEncode({"email": email, "password": password}),
      // );
      // if (response.statusCode == 200) {
      //   print("Login ke customer sukses");
      //   final data = jsonDecode(response.body);
      //   return CustomerModel.fromJson(data['user']);
      // } else if (response.statusCode == 401) {
      //   print("Email atau password salah");
      //   return null;
      // } else {
      //   print("Gagal login ke Node.js: ${response.statusCode}");
      //   print("Body: ${response.body}");
      //   throw Exception("Login Node.js gagal");
      // }
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

      // final url = Uri.parse("${base_url.customer}/email/${email}");
      // final response = await http.get(url);
      // if (response.statusCode == 200) {
      //   final decoded = jsonDecode(response.body);
      //   final results = decoded['results'];
      //   if (results != null && results.isNotEmpty) {
      //     return CustomerModel.fromJson(results[0]);
      //   } else {
      //     print("Tidak ada customer dengan email: $email");
      //     return null;
      //   }
      // }
      // throw Exception('Server error while getCustomer by email');
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

      // final response = await http.put(
      //   Uri.parse('${base_url.customer}/update/${customer.id}'),
      //   headers: {"Content-Type": "application/json"},
      //   body: jsonEncode(customer.toJson()),
      // );
      // if (response.statusCode == 200) {
      //   ...
      //   return true;
      // } else {
      //   print("Failed to update customer...");
      //   return false;
      // }
    } catch (e) {
      print(e);
      rethrow;
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
}
