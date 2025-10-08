import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:projek_uts_mbr/model/VendorModel.dart';
import 'package:projek_uts_mbr/databases/vendorDatabase.dart';
import 'package:projek_uts_mbr/services/sessionManager.dart';
import 'package:projek_uts_mbr/auth/loginCostumer.dart';
import 'package:projek_uts_mbr/vendorform.dart';
import 'package:projek_uts_mbr/profile/editPackageForm.dart';

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

  void _showDeleteConfirmationDialog(Vendormodel vendor, String packageName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Konfirmasi Hapus"),
          content: Text(
            "Apakah Anda yakin ingin menghapus paket '$packageName'?",
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Batal"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("Hapus", style: TextStyle(color: Colors.red)),
              onPressed: () {
                _deletePackage(vendor.email, packageName);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deletePackage(String vendorEmail, String packageName) async {
    await vendorDb.deletePackage(vendorEmail, packageName);
    loadVendorData();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Paket '$packageName' berhasil dihapus.")),
    );
  }

  void _navigateToEditForm(
    Vendormodel vendor,
    String packageName,
    Map<String, dynamic> packageData,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPackageForm(
          vendorEmail: vendor.email,
          packageName: packageName,
          packageData: packageData,
        ),
      ),
    );

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

  void _logout() async {
    await sessionManager.logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginCustomer()),
      (route) => false,
    );
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
                // ======= TAMBAHAN BAGIAN PROFIL VENDOR DI SINI =======
                if (currentVendor != null) ...[
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(
                        currentVendor.image.isNotEmpty
                            ? currentVendor.image
                            : 'https://via.placeholder.com/400x300',
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    currentVendor.nama,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    currentVendor.kategori,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    currentVendor.deskripsi.isNotEmpty
                        ? currentVendor.deskripsi
                        : "Belum ada deskripsi",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star, color: Colors.amber[600]),
                      const SizedBox(width: 5),
                      Text(currentVendor.rating.toStringAsFixed(1)),
                    ],
                  ),
                  const Divider(height: 30),
                ],
                // ========================================================

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    children: [
                      Text(
                        "Paket Anda (${currentVendor?.nama ?? 'Vendor'})",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
                if (currentVendor == null)
                  Card(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      width: double.infinity,
                      child: const Column(
                        children: [
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

    List<Widget> packageWidgets = [];
    if (hargaMap.isEmpty) {
      packageWidgets.add(
        Card(
          child: Container(
            padding: const EdgeInsets.all(24),
            width: double.infinity,
            child: const Column(
              children: [
                Icon(Icons.inbox, size: 40, color: Colors.grey),
                SizedBox(height: 10),
                Text(
                  "Belum ada paket. \nKlik 'Tambah Paket' untuk menambahkan.",
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      packageWidgets.addAll(
        hargaMap.entries.map((entry) {
          final packageName = entry.key;
          final packageData = entry.value as Map<String, dynamic>;
          final harga = packageData['harga'] ?? 0;
          final jasa = packageData['jasa'] ?? 'tidak ada deskripsi';

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Container(
              height: 160,
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            packageName.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.pink,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Rp $harga",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        jasa,
                        style: const TextStyle(fontSize: 14),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  Positioned(
                    top: -10,
                    right: -10,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.blue,
                            size: 20,
                          ),
                          onPressed: () {
                            _navigateToEditForm(
                              vendor,
                              packageName,
                              packageData,
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                            size: 20,
                          ),
                          onPressed: () {
                            _showDeleteConfirmationDialog(vendor, packageName);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      );
    }

    return Column(
      children: [
        ...packageWidgets,
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: _logout,
          icon: const Icon(Icons.logout),
          label: const Text("Logout"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pink,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
      ],
    );
  }
}
