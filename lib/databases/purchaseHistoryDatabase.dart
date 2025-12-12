import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:projek_uts_mbr/databases/customerDatabase.dart';
import 'package:projek_uts_mbr/helper/base_url.dart';
import 'package:projek_uts_mbr/model/purchaseHistoryModel.dart';

class Purchasehistorydatabase {
  /// ADD
  Future<void> addPurchaseHistory(PurchaseHistory purchaseHistory) async {
    try {
      final uid = await CustomerDatabase().getCurrentUserId();
      print("uid di pruchaseDb : ${uid}");
      final url = Uri.parse("${base_url.purchaseHistoryUrl}/add");

      final body = purchaseHistory.toJson();

      body["customer_id"] = uid;
      print("body di purchaseDb : ${body}");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode != 201) {
        print("SERVER REPLY: ${response.body}");
        throw Exception("FAILED_ADD");
      }

      print("Purchase history berhasil ditambah!");
    } catch (e) {
      print("error insert purchase history : $e");
      rethrow;
    }
  }

  /// GET by current user
  Future<List<PurchaseHistory>> getPurchaseHistory() async {
    try {
      final uid = await CustomerDatabase().getCurrentUserId();
      print("ada id kok di database ${uid}");
      final url = Uri.parse("${base_url.purchaseHistoryUrl}/$uid");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final results = jsonDecode(response.body)["results"];
        return results
            .map<PurchaseHistory>((item) => PurchaseHistory.fromMap(item))
            .toList();
      }

      throw Exception("SERVER_ERROR");
    } catch (e) {
      print("error getting purchase history: $e");
      rethrow;
    }
  }

  /// UPDATE
  Future<void> updatePurchaseHistory(PurchaseHistory updated) async {
    try {
      final uid = await CustomerDatabase().getCurrentUserId();

      final url = Uri.parse("${base_url.purchaseHistoryUrl}/${updated.id}");

      final body = updated.toJson();
      body["customer_id"] = uid;

      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode != 200) {
        print("UPDATE FAILED: ${response.statusCode} - ${response.body}");
        throw Exception("FAILED_UPDATE");
      }

      print("Purchase history updated!");
    } catch (e) {
      print("Error update purchase history: $e");
      rethrow;
    }
  }

  /// DELETE
  Future<void> deletePurchaseHistory(int purchaseId) async {
    try {
      final url = Uri.parse("${base_url.purchaseHistoryUrl}/$purchaseId");

      final response = await http.delete(url);

      if (response.statusCode != 200) {
        print("DELETE FAILED: ${response.statusCode} - ${response.body}");
        throw Exception("FAILED_DELETE");
      }

      print("Purchase history deleted!");
    } catch (e) {
      print("error delete purchase history : $e");
      rethrow;
    }
  }
}
