import 'dart:convert';

import 'package:projek_uts_mbr/databases/database.dart';
import 'package:projek_uts_mbr/helper/base_url.dart';
import 'package:projek_uts_mbr/model/CustomerModel.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;

class CustomerDatabase {
  final DatabaserService _dbService = DatabaserService();

  Future<int> insertCustomer(CustomerModel customer) async {
    try {
      final url = Uri.parse("${base_url.customer}/register");
      final response = await http.post(
        url,
        body: jsonEncode(customer.toJson()),
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print("register customer sukses");
        return data['customerId'];
      }
      throw Exception('Server error while register customer');
    } catch (e) {
      print("error register customer : $e");
      rethrow;
    }
    // final db = await _dbService.getDatabase();
    // return await db.insert('Customer', customer.toJson());
  }

  Future<Database> getDatabase() async {
    return await _dbService.getDatabase();
  }

  Future<CustomerModel?> LoginCustomer(String email, String password) async {
    try {
      final url = Uri.parse("${base_url.customer}/login");
      final response = await http.post(
        url,
        body: jsonEncode({'email': email, 'password': password}),
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode == 200) {
        print("login customer sukses");
        final data = jsonDecode(response.body);
        return CustomerModel.fromJson(data['user']);
      } else if (response.statusCode == 401) {
        print("Email atau password salah");
        return null;
      } else {
        print("Gagal login: ${response.statusCode} ${response.body}");
        throw Exception("Failed to login");
      }
    } catch (e) {
      print("error login customer : $e");
      rethrow;
    }
  }

  Future<CustomerModel?> getCustomerByEmail(String email) async {
    try {
      final url = Uri.parse("${base_url.customer}/email/${email}");
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final results = decoded['results'];

        if (results != null && results.isNotEmpty) {
          return CustomerModel.fromJson(results[0]);
        } else {
          print("Tidak ada customer dengan email: $email");
          return null;
        }
      }
      throw Exception('Server error while getCustomer by email');
    } catch (e) {
      print("error  getCustomer by email: $e");
      rethrow;
    }
    // final db = await _dbService.getDatabase();
    // final maps = await db.query(
    //   'Customer',
    //   where: 'email = ?',
    //   whereArgs: [email],
    // );

    // if (maps.isNotEmpty) {
    //   return CustomerModel.fromJson(maps.first);
    // }
    // return null;
  }

  Future<int> updateCustomerProfile(CustomerModel customer) async {
    final db = await getDatabase();
    return await db.update(
      'Customer',
      customer.toJson(),
      where: 'id = ?',
      whereArgs: [customer.id],
    );
  }

  Future<void> printAllCustomers() async {
    final db = await _dbService.getDatabase();
    final Customers = await db.query('Customer'); // ambil semua data
    print("Daftar Customer:");
    for (var v in Customers) {
      print(v);
    }
  }
}
