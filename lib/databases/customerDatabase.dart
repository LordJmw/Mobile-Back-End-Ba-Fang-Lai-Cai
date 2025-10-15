import 'package:projek_uts_mbr/databases/database.dart';
import 'package:projek_uts_mbr/model/CustomerModel.dart';
import 'package:sqflite/sqflite.dart';

class CustomerDatabase {
  final DatabaserService _dbService = DatabaserService();

  Future<int> insertCustomer(CustomerModel customer) async {
    final db = await _dbService.getDatabase();
    return await db.insert('Customer', customer.toJson());
  }

  Future<Database> getDatabase() async {
    return await _dbService.getDatabase();
  }

  Future<CustomerModel?> LoginCustomer(String email, String password) async {
    final db = await _dbService.getDatabase();
    final maps = await db.query(
      'Customer',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (maps.isNotEmpty) {
      return CustomerModel.fromJson(maps.first);
    }
    return null;
  }

  Future<CustomerModel?> getCustomerByEmail(String email) async {
    final db = await _dbService.getDatabase();
    final maps = await db.query(
      'Customer',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isNotEmpty) {
      return CustomerModel.fromJson(maps.first);
    }
    return null;
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
