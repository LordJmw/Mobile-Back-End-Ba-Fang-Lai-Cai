import 'dart:convert';

import 'package:projek_uts_mbr/databases/database.dart';
import 'package:projek_uts_mbr/helper/base_url.dart';
import 'package:projek_uts_mbr/model/purchaseHistoryModel.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;

class Purchasehistorydatabase {
  DatabaserService _dbService = DatabaserService();

  Future<Database> getDatabase() async {
    return await _dbService.getDatabase();
  }

  Future<void> addPurchaseHistory(PurchaseHistory purchaseHistory) async {
    try {
      final url = Uri.parse("${base_url.purchaseHistoryUrl}/add");
      final response = await http.post(
        url,
        body: jsonEncode(purchaseHistory.toJson()),
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode == 200) {
        print("paket berhasil ditambah!");
      }
    } catch (e) {
      print("error insert purchase history : $e");
      rethrow;
    }
  }

  // Future<void> addPurchaseHistory(PurchaseHistory purchaseHistory) async {
  //   final db = await getDatabase();
  //   await db.insert('PurchaseHistory', purchaseHistory.toMap());
  // }

  // Future<List<PurchaseHistory>> getPurchaseHistoryByCustomerId(
  //   int customerId,
  // ) async {
  //   try {
  //     final db = await getDatabase();
  //     List<Map<String, dynamic>> dbRes = await db.query(
  //       'PurchaseHistory',
  //       where: 'customer_id = ?',
  //       whereArgs: [customerId],
  //       orderBy: 'purchase_date DESC',
  //     );

  //     return dbRes.map((package) => PurchaseHistory.fromMap(package)).toList();
  //   } catch (e) {
  //     print("error getting customer package: $e");
  //     rethrow;
  //   }
  // }

  Future<List<PurchaseHistory>> getPurchaseHistoryByCustomerId(
    int customerId,
  ) async {
    try {
      final url = Uri.parse('${base_url.purchaseHistoryUrl}/${customerId}');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = jsonDecode(response.body)['results'];

        return jsonResponse.map((package) {
          return PurchaseHistory.fromMap(package);
        }).toList();
      } else {
        throw Exception('server error');
      }
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
      updatedPurchaseHistory.toJson(),
      where: 'id = ?',
      whereArgs: [updatedPurchaseHistory.id],
    );
  }

  Future<void> deletePurchaseHistory(int purchaseId) async {
    try {
      final url = Uri.parse("${base_url.purchaseHistoryUrl}/${purchaseId}");
      final response = await http.delete(
        url,
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode == 200) {
        print("Purchase History dengan id $purchaseId berhasil dihapus!");
      } else {
        print(
          "Gagal menghapus purchase history. Status code: ${response.statusCode}, body: ${response.body}",
        );
      }
    } catch (e) {
      print("error delete purchase history : $e");
      rethrow;
    }
  }
}
