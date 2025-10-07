import 'package:flutter/material.dart';
import 'package:projek_uts_mbr/databases/vendorDatabase.dart';

class EditPackageForm extends StatefulWidget {
  final String vendorEmail;
  final String packageName;
  final Map<String, dynamic> packageData;

  const EditPackageForm({
    super.key,
    required this.vendorEmail,
    required this.packageName,
    required this.packageData,
  });

  @override
  State<EditPackageForm> createState() => _EditPackageFormState();
}

class _EditPackageFormState extends State<EditPackageForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _jasaController;
  final Vendordatabase _vendorDb = Vendordatabase();

  @override
  void initState() {
    super.initState();
    // Isi controller dengan data paket yang ada
    _nameController = TextEditingController(text: widget.packageName);
    _jasaController = TextEditingController(
      text: widget.packageData['jasa'] ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _jasaController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      final newPackageName = _nameController.text;
      final newJasa = _jasaController.text;

      // Siapkan data paket yang baru, harga tetap sama
      final newPackageData = {
        'harga': widget.packageData['harga'],
        'jasa': newJasa,
      };

      // Panggil fungsi update dari database
      await _vendorDb.updatePackage(
        widget.vendorEmail,
        widget.packageName, // Nama paket lama
        newPackageName, // Nama paket baru
        newPackageData, // Data paket baru
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Paket berhasil diperbarui!")),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Paket"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Nama Paket",
                  border: OutlineInputBorder(),
                  helperText:
                      "Nama unik untuk paket Anda (misal: Basic, Premium).",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama paket tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _jasaController,
                decoration: const InputDecoration(
                  labelText: "Deskripsi Jasa / Kategori",
                  hintText: "Contoh: Fotografer, Videografer, Album Cetak",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Deskripsi jasa tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text("Simpan Perubahan"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
