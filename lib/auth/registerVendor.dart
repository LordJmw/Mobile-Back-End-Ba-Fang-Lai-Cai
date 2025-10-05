import 'package:flutter/material.dart';
import 'package:projek_uts_mbr/auth/logincostumer.dart';
import 'package:projek_uts_mbr/auth/registerCustomer.dart';
import 'package:projek_uts_mbr/databases/vendorDatabase.dart';
import 'package:projek_uts_mbr/model/VendorModel.dart';

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
        selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Harap isi semua field dan pilih kategori"),
          backgroundColor: Colors.pink,
        ),
      );
      return;
    }

    final vendor = Vendormodel(
      nama: _namatokoController.text,
      deskripsi: "Deskripsi baru",
      rating: 0.0,
      harga: "{}",
      testimoni: "[]",
      email: _emailController.text,
      telepon: _teleponController.text,
      image: "https://via.placeholder.com/400x300",
      kategori: selectedCategory!,
      alamat: _alamatController.text,
      password: _passwordController.text,
    );

    if (_passwordController.text != _confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.pink,
          content: Text("Password konfirmasi tidak sama"),
        ),
      );
      return;
    }


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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
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

                // 🔹 No Telepon
                TextField(
                  controller: _teleponController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.phone_outlined),
                    labelText: "Nomor Telepon",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 20),

                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: InputDecoration(
                    labelText: "Kategori Vendor",
                    prefixIcon: const Icon(Icons.category_outlined,),

                    border: OutlineInputBorder( 
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: categories
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value;
                    });
                  },
                  validator: (value) =>
                      value == null ? "Pilih kategori vendor" : null,
                ),
                const SizedBox(height: 20),

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
                  onPressed: _onRegisterPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                  ),
                  child: const Text(
                    "Daftar Vendor",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),

                // 🔹 Tombol ke Login
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

  void _onRegisterPressed() {
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmController.text.isEmpty ||
        _namatokoController.text.isEmpty ||
        _alamatController.text.isEmpty ||
        _teleponController.text.isEmpty ||
        selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Harap isi semua field dan pilih kategori"),
          backgroundColor: Colors.pink,
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

    _saveVendor();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.green,
        content: Text("Vendor berhasil didaftarkan!"),
      ),
    );


    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginCustomer()),
    );
  }
}
