import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:projek_uts_mbr/model/VendorModel.dart';
import 'package:projek_uts_mbr/databases/vendorDatabase.dart';
import 'package:projek_uts_mbr/vendorform.dart';

class Vendorprofile extends StatefulWidget {
  const Vendorprofile({super.key});

  @override
  State<Vendorprofile> createState() => _VendorprofileState();
}

class _VendorprofileState extends State<Vendorprofile> {
  List<Vendormodel> paketList = [];
  final Vendordatabase vendorDb = Vendordatabase();

  @override
  void initState() {
    super.initState();
    loadPaketFromDb();
  }

  Future<void> loadPaketFromDb() async {
    final data = await vendorDb.getData();
    print("Data dari database: $data"); // Debug print
    if (data.isNotEmpty) {
      print("Harga pertama: ${data.first.harga}"); // Debug harga
    }
    setState(() {
      paketList = data;
    });
  }

  void tambahPaketBaru() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const VendorForm()),
    );
    loadPaketFromDb();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profil Vendor")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                children: [
                  const Text(
                    "Paket Anda",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: () {
                      tambahPaketBaru();
                    },
                    icon: const Icon(Icons.add),
                    label: const Text("Tambah Paket"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            if (paketList.isEmpty)
              Card(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  width: double.infinity,
                  child: Column(
                    children: const [
                      Icon(Icons.inbox, size: 40, color: Colors.grey),
                      SizedBox(height: 10),
                      Text(
                        "Belum ada paket.\nKlik 'Tambah Paket' untuk menambahkan.",
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              Column(
                children: paketList.map((paket) {
                  Map<String, dynamic> hargaMap = {};

                  try {
                    // Pastikan harga tidak null dan bisa di-decode
                    if (paket.harga != null && paket.harga.isNotEmpty) {
                      hargaMap = jsonDecode(paket.harga);
                    } else {
                      // Jika harga null, gunakan default structure
                      hargaMap = jsonDecode(Vendormodel.defaultHargaJson);
                    }
                  } catch (e) {
                    print("Error decoding harga for ${paket.nama}: $e");
                    // Fallback ke default structure jika error
                    hargaMap = jsonDecode(Vendormodel.defaultHargaJson);
                  }

                  // Safe access dengan null-aware operators
                  final basicHarga = hargaMap["basic"]?["harga"] ?? 0;
                  final basicJasa =
                      hargaMap["basic"]?["jasa"] ?? "Deskripsi tidak tersedia";

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            paket.nama,
                            style: const TextStyle(
                              color: Colors.pink,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Rp ${basicHarga}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          Text(basicJasa, style: const TextStyle(fontSize: 14)),
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
