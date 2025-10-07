import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:projek_uts_mbr/model/VendorModel.dart';
import 'package:projek_uts_mbr/databases/vendorDatabase.dart';
import 'package:projek_uts_mbr/services/sessionManager.dart';
import 'package:projek_uts_mbr/vendorform.dart';

class Vendorprofile extends StatefulWidget {
  const Vendorprofile({super.key});

  @override
  State<Vendorprofile> createState() => _VendorprofileState();
}

class _VendorprofileState extends State<Vendorprofile> {
  late StreamController<Vendormodel?> _vendorController;
  final Vendordatabase vendorDb = Vendordatabase();
  final SessionManager sessionManager = SessionManager();

  @override
  void initState() {
    super.initState();
    _vendorController = StreamController<Vendormodel?>();
    loadVendorData();
  }

  @override
  void dispose() {
    _vendorController.close();
    super.dispose();
  }

  Future<void> loadVendorData() async {
    final String? vendorEmail = await sessionManager.getEmail();
    if (vendorEmail != null) {
      final vendor = await vendorDb.getVendorByEmail(vendorEmail);
      if (!_vendorController.isClosed) {
        _vendorController.add(vendor);
      }
    } else {
      if (!_vendorController.isClosed) {
        _vendorController.add(null);
      }
    }
  }

  void tambahPaketBaru() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const VendorForm()),
    );
    loadVendorData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profil Vendor")),
      body: StreamBuilder<Vendormodel?>(
        stream: _vendorController.stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final currentVendor = snapshot.data;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    children: [
                      Text(
                        "Paket Anda (${currentVendor?.nama ?? 'Vendor'})",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: tambahPaketBaru,
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
                if (currentVendor == null)
                  Card(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      width: double.infinity,
                      child: Column(
                        children: const [
                          Icon(Icons.inbox, size: 40, color: Colors.grey),
                          SizedBox(height: 10),
                          Text(
                            "Tidak dapat memuat data vendor.",
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  _buildPackageList(currentVendor),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPackageList(Vendormodel vendor) {
    Map<String, dynamic> hargaMap;
    try {
      if (vendor.harga.isNotEmpty) {
        hargaMap = jsonDecode(vendor.harga);
      } else {
        hargaMap = {};
      }
    } catch (e) {
      print("error decode harga untuk ${vendor.nama}:$e");
      hargaMap = {};
    }

    if (hargaMap.isEmpty) {
      return Card(
        child: Container(
          padding: const EdgeInsets.all(24),
          width: double.infinity,
          child: Column(
            children: const [
              Icon(Icons.inbox, size: 40, color: Colors.grey),
              SizedBox(height: 10),
              Text(
                "Belum ada paket. \nKlik 'Tambah Paket untuk menambahkan.",
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    return Column(
      children: hargaMap.entries.map((entry) {
        final packageName = entry.key;
        final packageData = entry.value as Map<String, dynamic>;
        final harga = packageData['harga'] ?? 0;
        final jasa = packageData['jasa'] ?? 'tidak ada deskripsi';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  packageName.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.pink,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Rp $harga",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 5),
                Text(jasa, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
