import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:projek_uts_mbr/analytics/eventLogs.dart';
import 'package:projek_uts_mbr/auth/logincostumer.dart';
import 'package:projek_uts_mbr/databases/vendorDatabase.dart';
import 'package:projek_uts_mbr/model/VendorModel.dart';
import 'dart:convert';

class RegisterVendor extends StatefulWidget {
  const RegisterVendor({super.key});

  @override
  State<RegisterVendor> createState() => _RegisterVendorState();
}

class _RegisterVendorState extends State<RegisterVendor> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _namatokoController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _teleponController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _hargaBasicController = TextEditingController();
  final TextEditingController _jasaBasicController = TextEditingController();
  final TextEditingController _hargaPremiumController = TextEditingController();
  final TextEditingController _jasaPremiumController = TextEditingController();
  final TextEditingController _hargaCustomController = TextEditingController();
  final TextEditingController _jasaCustomController = TextEditingController();

  String? selectedCategory;
  List<String> categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final db = Vendordatabase();
    final cats = await db.getCategories();
    setState(() {
      categories = cats;
    });
  }

  Future<void> _saveVendor() async {
    if (!_formKey.currentState!.validate()) return;

    final penyedia = Penyedia(
      nama: _namatokoController.text,
      deskripsi: _deskripsiController.text,
      rating: 0.0,
      harga: Harga(
        basic: TipePaket(
          harga: int.parse(_hargaBasicController.text),
          jasa: _jasaBasicController.text,
        ),
        premium: TipePaket(
          harga: int.parse(_hargaPremiumController.text),
          jasa: _jasaPremiumController.text,
        ),
        custom: TipePaket(
          harga: int.parse(_hargaCustomController.text),
          jasa: _jasaCustomController.text,
        ),
      ),
      testimoni: [],
      email: _emailController.text,
      password: _passwordController.text,
      telepon: _teleponController.text,
      image: "https://cdn-icons-png.flaticon.com/512/149/149071.png",
    );

    final vendor = Vendormodel(
      kategori: selectedCategory ?? "",
      penyedia: [penyedia],
    );

    final db = Vendordatabase();
    await db.insertVendor(vendor);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Vendor berhasil didaftarkan!"),
        backgroundColor: Colors.green,
      ),
    );

    await Eventlogs().logVendorRegisterActivity(
      penyedia.email,
      "vendor",
      selectedCategory!,
      penyedia.nama,
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginCustomer()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Text(
                    "Buat Akun Vendor Baru",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _namatokoController,
                    decoration: const InputDecoration(
                      labelText: "Nama Toko",
                      prefixIcon: Icon(Icons.store_outlined),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? "Nama toko wajib diisi" : null,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) return "Email wajib diisi";
                      final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                      if (!regex.hasMatch(value)) return "Email tidak valid";
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _teleponController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: "Nomor Telepon",
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) return "Nomor telepon wajib diisi";
                      if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                        return "Hanya angka yang diperbolehkan";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: const InputDecoration(
                      labelText: "Kategori Vendor",
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                    items: categories
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (value) => setState(() {
                      selectedCategory = value;
                    }),
                    validator: (value) =>
                        value == null ? "Pilih kategori vendor" : null,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _alamatController,
                    decoration: const InputDecoration(
                      labelText: "Alamat Toko",
                      prefixIcon: Icon(Icons.home_outlined),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? "Alamat wajib diisi" : null,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _deskripsiController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: "Deskripsi Toko",
                      prefixIcon: Icon(Icons.description_outlined),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? "Deskripsi wajib diisi" : null,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Paket Basic",
                    style: TextStyle(
                      color: Colors.pink,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _hargaBasicController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(labelText: "Harga Basic"),
                    validator: (v) {
                      if (v == null || v.isEmpty)
                        return "Harga Basic wajib diisi";
                      final value = int.tryParse(v);
                      if (value == null) return "Harga tidak valid";
                      if (value > 10000000)
                        return "Harga tidak boleh lebih dari 10 juta";
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _jasaBasicController,
                    decoration: const InputDecoration(labelText: "Jasa Basic"),
                    validator: (v) =>
                        v!.isEmpty ? "Jasa Premium wajib diisi" : null,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Paket Premium",
                    style: TextStyle(
                      color: Colors.pink,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextFormField(
                    controller: _hargaPremiumController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: "Harga Premium",
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty)
                        return "Harga Basic wajib diisi";
                      final value = int.tryParse(v);
                      if (value == null) return "Harga tidak valid";
                      if (value > 10000000)
                        return "Harga tidak boleh lebih dari 10 juta";
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _jasaPremiumController,
                    decoration: const InputDecoration(
                      labelText: "Jasa Premium",
                    ),
                    validator: (v) =>
                        v!.isEmpty ? "Jasa Premium wajib diisi" : null,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Paket Custom",
                    style: TextStyle(
                      color: Colors.pink,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextFormField(
                    controller: _hargaCustomController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: "Harga Custom",
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty)
                        return "Harga Basic wajib diisi";
                      final value = int.tryParse(v);
                      if (value == null) return "Harga tidak valid";
                      if (value > 10000000)
                        return "Harga tidak boleh lebih dari 10 juta";
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _jasaCustomController,
                    decoration: const InputDecoration(labelText: "Jasa Custom"),
                    validator: (v) =>
                        v!.isEmpty ? "Jasa Custom wajib diisi" : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: "Password"),
                    validator: (v) =>
                        v!.length < 6 ? "Minimal 6 karakter" : null,
                  ),
                  TextFormField(
                    controller: _confirmController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Konfirmasi Password",
                    ),
                    validator: (v) => v != _passwordController.text
                        ? "Password tidak sama"
                        : null,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _saveVendor,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      "Daftar Vendor",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
