import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  late TextEditingController _hargaController;
  late TextEditingController _jasaController;
  final Vendordatabase _vendorDb = Vendordatabase();

  @override
  void initState() {
    super.initState();
    _hargaController = TextEditingController(
      text: widget.packageData['harga'].toString(),
    );
    _jasaController = TextEditingController(
      text: widget.packageData['jasa'] ?? '',
    );
  }

  @override
  void dispose() {
    _hargaController.dispose();
    _jasaController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      final newHarga = int.parse(_hargaController.text.trim());
      final newJasa = _jasaController.text.trim();

      final newPackageData = {'harga': newHarga, 'jasa': newJasa};

      await _vendorDb.updatePackage(
        widget.vendorEmail,
        widget.packageName,
        widget.packageName,
        newPackageData,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Harga paket berhasil diperbarui!")),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Harga Paket"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: widget.packageName,
                decoration: const InputDecoration(
                  labelText: "Nama Paket",
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _hargaController,
                decoration: const InputDecoration(
                  labelText: "Harga Paket",
                  prefixText: "Rp ",
                  border: OutlineInputBorder(),
                  hintText: "Masukkan harga paket (contoh: 500000)",
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Harga tidak boleh kosong';
                  }
                  final number = int.tryParse(value);
                  if (number == null || number <= 0) {
                    return 'Masukkan harga yang valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _jasaController,
                decoration: const InputDecoration(
                  labelText: "Deskripsi Jasa (Pisahkan dengan koma)",
                  hintText: "Contoh: Fotografer, Videografer, Album Cetak",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Deskripsi jasa tidak boleh kosong';
                  }

                  final invalidSeparators = RegExp(r'[.;:/\-]');
                  if (invalidSeparators.hasMatch(value)) {
                    return 'Gunakan koma (,) untuk memisahkan jasa';
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
