import 'dart:async';
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
                _deletePackage(vendor.penyedia.first.email, packageName);
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
    TipePaket packageData,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPackageForm(
          vendorEmail: vendor.penyedia.first.email,
          packageName: packageName,
          packageData: {"harga": packageData.harga, "jasa": packageData.jasa},
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
          if (currentVendor == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  const Text("Tidak dapat memuat data vendor"),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout),
                    label: const Text("Logout"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(200, 45),
                    ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(
                      currentVendor.penyedia.first.image.isNotEmpty
                          ? currentVendor.penyedia.first.image
                          : 'https://cdn-icons-png.flaticon.com/512/149/149071.png',
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  currentVendor.penyedia.first.nama,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  currentVendor.penyedia.first.deskripsi.isNotEmpty
                      ? currentVendor.penyedia.first.deskripsi
                      : "Belum ada deskripsi",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star, color: Colors.amber[600]),
                    const SizedBox(width: 5),
                    Text(
                      currentVendor.penyedia.first.rating.toStringAsFixed(1),
                    ),
                  ],
                ),
                const Divider(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    children: [
                      Text(
                        "Paket Anda (${currentVendor.penyedia.first.nama})",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
                _buildPackageList(currentVendor),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPackageList(Vendormodel vendor) {
    final harga = vendor.penyedia.first.harga;
    final packages = {
      "Basic": harga.basic,
      "Premium": harga.premium,
      "Custom": harga.custom,
    };

    List<Widget> packageWidgets = packages.entries.map((entry) {
      final packageName = entry.key;
      final data = entry.value;
      final hargaText = data.harga > 0 ? "Rp ${data.harga}" : "Belum diatur";
      final jasaText = data.jasa.isNotEmpty ? data.jasa : "Tidak ada deskripsi";

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
                      ),
                      const SizedBox(height: 10),
                      Text(
                        hargaText,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    jasaText,
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
                        _navigateToEditForm(vendor, packageName, data);
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
    }).toList();

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
