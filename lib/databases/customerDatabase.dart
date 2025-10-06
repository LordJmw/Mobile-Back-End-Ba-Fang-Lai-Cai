import 'package:projek_uts_mbr/databases/database.dart';
import 'package:projek_uts_mbr/model/CustomerModel.dart';
import 'package:sqflite/sqflite.dart';

class CustomerDatabase {
  final DatabaserService _dbService = DatabaserService();

  Future<int> insertCustomer(CustomerModel customer) async {
    final db = await _dbService.getDatabase();
    return await db.insert('Customer', customer.toMap());
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

  Future<void> addPurchaseHistory(
    int customerId,
    String purchaseDetails,
  ) async {
    final db = await _dbService.getDatabase();
    await db.insert('PurchaseHistory', {
      'customer_id': customerId,
      'purchase_details': purchaseDetails,
      'purchase_date': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getPurchaseHistoryByCustomerId(
    int customerId,
  ) async {
    final db = await getDatabase();
    return await db.query(
      'PurchaseHistory',
      where: 'customer_id = ?',
      whereArgs: [customerId],
      orderBy: 'purchase_date DESC',
    );
  }

  Future<int> updatePurchaseHistory(
    int purchaseId,
    String newPurchaseDetails,
  ) async {
    final db = await getDatabase();
    return await db.update(
      'PurchaseHistory',
      {
        'purchase_details': newPurchaseDetails,
        'purchase_date': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [purchaseId],
    );
  }

  Future<int> deletePurchaseHistory(int purchaseId) async {
    final db = await getDatabase();
    return await db.delete(
      'PurchaseHistory',
      where: 'id = ?',
      whereArgs: [purchaseId],
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
