import 'package:projek_uts_mbr/databases/database.dart';
import 'package:sqflite/sqflite.dart';

class Purchasehistorydatabase {
  DatabaserService _dbService = DatabaserService();

  Future<Database> getDatabase() async {
    return await _dbService.getDatabase();
  }

  Future<void> addPurchaseHistory(
    int customerId,
    String purchaseDetails,
  ) async {
    final db = await getDatabase();
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
}
