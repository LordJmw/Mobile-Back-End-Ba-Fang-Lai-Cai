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
                    onPressed: (){
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
                children:
                    paketList.map((paket) {
                      final harga = jsonDecode(paket.harga);
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
                                "Rp ${harga["basic"]["harga"] ?? 0}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              Text(
                                harga["basic"]["jasa"] ?? "",
                                style: const TextStyle(fontSize: 14),
                              ),
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
