import 'package:projek_uts_mbr/databases/database.dart';
import 'package:projek_uts_mbr/model/CustomerModel.dart';
import 'package:sqflite/sqflite.dart';

class CustomerDatabase {
  final DatabaserService _dbService = DatabaserService();

  Future<int> insertCustomer(CustomerModel customer) async {
    final db = await _dbService.getDatabase();
    return await db.insert('Customer', customer.toMap());
  }

  Future<CustomerModel?> LoginCustomer(String email, String password) async {
    final db = await _dbService.getDatabase();
    final maps = await db.query(
      'Customer',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

     if (maps.isNotEmpty) {
      return CustomerModel.fromMap(maps.first);
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
      return CustomerModel.fromMap(maps.first);
    }
    return null;
  }

  Future<void> addPurchaseHistory(int customerId, String purchaseDetails) async {
    final db = await _dbService.getDatabase();
    await db.insert('PurchaseHistory', {
      'customer_id': customerId,
      'purchase_details': purchaseDetails,
      'purchase_date': DateTime.now().toIso8601String(),
    });
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