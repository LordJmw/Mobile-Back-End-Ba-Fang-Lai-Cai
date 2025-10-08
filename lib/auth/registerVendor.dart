import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    if (_namatokoController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmController.text.isEmpty ||
        _alamatController.text.isEmpty ||
        _teleponController.text.isEmpty ||
        _deskripsiController.text.isEmpty ||
        _hargaBasicController.text.isEmpty ||
        _jasaBasicController.text.isEmpty ||
        _hargaPremiumController.text.isEmpty ||
        _jasaPremiumController.text.isEmpty ||
        _hargaCustomController.text.isEmpty ||
        _jasaCustomController.text.isEmpty ||
        selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Vendor berhasil didaftarkan!",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(12),
        ),
      );
      return;
    }

    if (_passwordController.text != _confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.pink,
          content: Text("Password konfirmasi tidak sama"),
        ),
      );
      return;
    }

    final vendor = Vendormodel(
      nama: _namatokoController.text,
      deskripsi: _deskripsiController.text,
      rating: 0.0,
      harga: jsonEncode({
        "basic": {
          "harga": _hargaBasicController.text,
          "jasa": _jasaBasicController.text,
        },
        "premium": {
          "harga": _hargaPremiumController.text,
          "jasa": _jasaPremiumController.text,
        },
        "custom": {
          "harga": _hargaCustomController.text,
          "jasa": _jasaCustomController.text,
        },
      }),
      testimoni: jsonEncode([]),
      email: _emailController.text,
      telepon: _teleponController.text,
      image: "https://via.placeholder.com/400x300",
      kategori: selectedCategory!,
      alamat: _alamatController.text,
      password: _passwordController.text,
    );

    final db = Vendordatabase();
    await db.insertVendor(vendor);
    await db.printAllVendors();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Vendor berhasil didaftarkan!")),
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
                const SizedBox(height: 10),
                const Text(
                  "Isi data untuk mendaftar vendor",
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 30),

                // 🔹 Nama Toko
                TextField(
                  controller: _namatokoController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.store_outlined),
                    labelText: "Nama Toko",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 🔹 Email
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.email_outlined),
                    labelText: "Email",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 🔹 Nomor Telepon
                TextField(
                  controller: _teleponController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.phone_outlined),
                    labelText: "Nomor Telepon",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 🔹 Kategori Vendor
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: InputDecoration(
                    labelText: "Kategori Vendor",
                    prefixIcon: const Icon(Icons.category_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: categories
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value;
                    });
                  },
                ),
                const SizedBox(height: 20),

                // 🔹 Alamat Toko
                TextField(
                  controller: _alamatController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.home_outlined),
                    labelText: "Alamat Toko",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 🔹 Deskripsi Toko
                TextField(
                  controller: _deskripsiController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.description_outlined),
                    labelText: "Deskripsi Toko",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // 🔹 Harga & Jasa Basic
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Paket Basic",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.pink,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                TextField(
                  controller: _hargaBasicController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.attach_money),
                    labelText: "Harga Basic",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _jasaBasicController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.build_circle_outlined),
                    labelText: "Jasa Basic",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 🔹 Harga & Jasa Premium
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Paket Premium",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.pink,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                TextField(
                  controller: _hargaPremiumController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.star),
                    labelText: "Harga Premium",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _jasaPremiumController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.workspace_premium_outlined),
                    labelText: "Jasa Premium",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 🔹 Harga & Jasa Custom
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Paket Custom",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.pink,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                TextField(
                  controller: _hargaCustomController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.money_outlined),
                    labelText: "Harga Custom",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _jasaCustomController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.design_services_outlined),
                    labelText: "Jasa Custom",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // 🔹 Password
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock_outline),
                    labelText: "Password",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 🔹 Konfirmasi Password
                TextField(
                  controller: _confirmController,
                  obscureText: true,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock_reset),
                    labelText: "Konfirmasi Password",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                ElevatedButton(
                  onPressed: _saveVendor,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Daftar Vendor",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),

                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => LoginCustomer()),
                    );
                  },
                  child: const Text(
                    "Sudah punya akun? Masuk",
                    style: TextStyle(color: Colors.pink),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
