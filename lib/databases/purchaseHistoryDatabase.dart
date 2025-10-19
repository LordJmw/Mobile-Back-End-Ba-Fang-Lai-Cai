import 'package:projek_uts_mbr/databases/database.dart';
import 'package:projek_uts_mbr/model/purchaseHistoryModel.dart';
import 'package:sqflite/sqflite.dart';

class Purchasehistorydatabase {
  DatabaserService _dbService = DatabaserService();

  Future<Database> getDatabase() async {
    return await _dbService.getDatabase();
  }

  Future<void> addPurchaseHistory(PurchaseHistory purchaseHistory) async {
    final db = await getDatabase();
    await db.insert('PurchaseHistory', purchaseHistory.toMap());
  }

  Future<List<PurchaseHistory>> getPurchaseHistoryByCustomerId(
    int customerId,
  ) async {
    try {
      final db = await getDatabase();
      List<Map<String, dynamic>> dbRes = await db.query(
        'PurchaseHistory',
        where: 'customer_id = ?',
        whereArgs: [customerId],
        orderBy: 'purchase_date DESC',
      );

      return dbRes.map((package) => PurchaseHistory.fromMap(package)).toList();
    } catch (e) {
      print("error getting customer package: $e");
      rethrow;
    }
  }

  Future<int> updatePurchaseHistory(
    PurchaseHistory updatedPurchaseHistory,
  ) async {
    final db = await getDatabase();
    return await db.update(
      'PurchaseHistory',
      updatedPurchaseHistory.toMap(),
      where: 'id = ?',
      whereArgs: [updatedPurchaseHistory.id],
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
