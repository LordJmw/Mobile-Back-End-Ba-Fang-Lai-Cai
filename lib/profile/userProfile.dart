import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:projek_uts_mbr/databases/customerDatabase.dart';
import 'package:projek_uts_mbr/model/CustomerModel.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  List<Map<String, dynamic>> purchaseHistory = [];
  final CustomerDatabase customerDb = CustomerDatabase();

  @override
  void initState() {
    super.initState();
    // loadPurchaseHistory();
  }

  // Future<void> loadPurchaseHistory() async {
  //   final loggedInCustomer = await customerDb.getLoggedInCustomer();
  //   if (loggedInCustomer == null) return;

  //   final db = await customerDb.getDatabase();
  //   final results = await db.query(
  //     'PurchaseHistory',
  //     where: 'customer_id = ?',
  //     whereArgs: [loggedInCustomer.id],
  //     orderBy: 'purchase_date DESC',
  //   );

  //   setState(() {
  //     purchaseHistory = results;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profil Pengguna")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                children: const [
                  Text(
                    "Riwayat Pembelian Anda",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),

            if (purchaseHistory.isEmpty)
              Card(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  width: double.infinity,
                  child: Column(
                    children: const [
                      Icon(
                        Icons.shopping_bag_outlined,
                        size: 40,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Belum ada pembelian.\nSilakan beli paket dari vendor.",
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              Column(
                children: purchaseHistory.map((purchase) {
                  final details = jsonDecode(purchase['purchase_details']);
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            details['vendor'],
                            style: const TextStyle(
                              color: Colors.pink,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "${details['package']} - Rp ${details['price']}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            "Tanggal acara: ${details['date']?.split('T').first ?? '-'}",
                          ),
                          Text("Lokasi: ${details['location'] ?? '-'}"),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
