import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:projek_uts_mbr/databases/customerDatabase.dart';
import 'package:projek_uts_mbr/databases/purchaseHistoryDatabase.dart';
import 'package:projek_uts_mbr/databases/vendorDatabase.dart';
import 'package:projek_uts_mbr/main.dart';
import 'package:projek_uts_mbr/model/purchaseHistoryModel.dart';
import 'package:projek_uts_mbr/services/dataServices.dart';
import 'package:projek_uts_mbr/services/sessionManager.dart';

class OrderPage extends StatefulWidget {
  final String namaVendor;
  final String? paketDipilih;
  const OrderPage({super.key, required this.namaVendor, this.paketDipilih});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  Purchasehistorydatabase _purchaseDb = Purchasehistorydatabase();

  DateTime? selectedDate;
  String? selectedPackage;
  int? selectedPrice;

  Map<String, int> packages = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getDataFromDatabase() async {
    try {
      setState(() {
        isLoading = true;
      });

      final vendorDb = Vendordatabase();
      final vendor = await vendorDb.getVendorByName(widget.namaVendor);

      if (vendor == null) {
        print("Vendor tidak ditemukan");
        setState(() {
          packages = {};
          isLoading = false;
        });
        return;
      }
      Map<String, int> parsedPackages = {};

      try {
        dynamic hargaData = jsonDecode(vendor.harga);

        if (hargaData is Map) {
          hargaData.forEach((key, value) {
            if (value != null) {
              if (value is Map && value['harga'] != null) {
                parsedPackages[key.toString()] = value['harga'];
              } else if (value is int) {
                parsedPackages[key.toString()] = value;
              }
            }
          });
        }
      } catch (e) {
        print("Error parsing harga: $e");
      }

      setState(() {
        packages = parsedPackages;

        final selectedKey = widget.paketDipilih;
        if (selectedKey != null && packages.containsKey(selectedKey)) {
          selectedPackage = selectedKey;
          selectedPrice = packages[selectedKey];
        } else {
          selectedPackage = null;
          selectedPrice = null;
        }

        isLoading = false;
      });

      print("Paket yang ditemukan dari database: $packages");
      print("Paket terpilih: $selectedPackage, harga: $selectedPrice");
    } catch (e) {
      print("Error loading data from database: $e");
      setState(() {
        isLoading = false;
        packages = {};
      });
    }
  }

  getData() async {
    // Coba load dari database langsung dulu
    await getDataFromDatabase();

    // Fallback ke Dataservices jika perlu
    if (packages.isEmpty) {
      Dataservices dataservices = Dataservices();
      Map<String, dynamic>? respond = await dataservices.loadDataDariNama(
        widget.namaVendor,
      );

      if (respond == null || respond['harga'] == null) {
        print("Vendor tidak memiliki data harga");
        setState(() {
          packages = {};
          isLoading = false;
        });
        return;
      }

      dynamic hargaData = respond['harga'];

      if (hargaData is String) {
        try {
          hargaData = jsonDecode(hargaData);
        } catch (e) {
          print("Error decode harga: $e");
          hargaData = {};
        }
      }

      if (hargaData is! Map) {
        print("Format harga tidak valid");
        setState(() {
          packages = {};
          isLoading = false;
        });
        return;
      }

      Map<String, int> parsedPackages = {};

      hargaData.forEach((key, value) {
        if (value != null) {
          if (value is Map && value['harga'] != null) {
            parsedPackages[key.toString()] = value['harga'];
          } else if (value is int) {
            parsedPackages[key.toString()] = value;
          }
        }
      });

      setState(() {
        packages = parsedPackages;

        final selectedKey = widget.paketDipilih;

        if (selectedKey != null && packages.containsKey(selectedKey)) {
          selectedPackage = selectedKey;
          selectedPrice = packages[selectedKey];
        } else {
          selectedPackage = null;
          selectedPrice = null;
        }
        if (packages.isEmpty) {
          selectedPackage = null;
          selectedPrice = null;
        }
      });
    }
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  beliPaket() async {
    if (isLoading) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.orange,
          content: Text("Sedang memuat data..."),
        ),
      );
      return;
    }

    SessionManager sessionManager = SessionManager();
    String? userType = await sessionManager.getUserType();
    String? email = await sessionManager.getEmail();

    if (userType == "vendor") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.pink,
          content: Text("Login sebagai customer untuk dapat membeli paket"),
        ),
      );
      return;
    }

    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text("Pilih tanggal acara terlebih dahulu"),
        ),
      );
      return;
    }

    if (_locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text("Masukkan lokasi acara"),
        ),
      );
      return;
    }

    if (selectedPackage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text("Pilih paket terlebih dahulu"),
        ),
      );
      return;
    }

    if (!packages.containsKey(selectedPackage)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            "Paket yang dipilih tidak tersedia. Silakan pilih paket lain.",
          ),
        ),
      );
      return;
    }

    final customerDb = CustomerDatabase();
    final customer = await customerDb.getCustomerByEmail(email!);

    if (customer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text("Customer tidak ditemukan"),
        ),
      );
      return;
    }

    final purchaseDetails = PurchaseDetails(
      vendor: widget.namaVendor,
      packageName: selectedPackage!,
      price: selectedPrice!,
      date: selectedDate!,
      location: _locationController.text,
      notes: _notesController.text,
      status: 'pending',
    );

    final purchaseHistory = PurchaseHistory(
      customerId: customer.id!,
      purchaseDetails: purchaseDetails,
      purchaseDate: DateTime.now(),
    );

    await _purchaseDb.addPurchaseHistory(purchaseHistory);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.green,
        content: Text(
          "Pembelian berhasil! Paket telah ditambahkan ke profil Anda.",
        ),
      ),
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MainScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 243, 243, 245),
      appBar: AppBar(
        title: const Text("Halaman Pembayaran"),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        "EventHub",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.pink,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Form Pemesanan",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // TANGGAL
                          const Text("Tanggal Acara"),
                          const SizedBox(height: 5),
                          InkWell(
                            onTap: _pickDate,
                            child: InputDecorator(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                prefixIcon: const Icon(Icons.calendar_today),
                              ),
                              child: Text(
                                selectedDate == null
                                    ? "Pilih tanggal"
                                    : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // LOKASI
                          const Text("Lokasi"),
                          const SizedBox(height: 5),
                          TextField(
                            controller: _locationController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              hintText: "Masukkan lokasi acara",
                            ),
                          ),
                          const SizedBox(height: 20),

                          // PAKET
                          const Text("Paket yang Dipilih"),
                          const SizedBox(height: 5),
                          packages.isEmpty
                              ? Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    "Tidak ada paket tersedia",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                )
                              : DropdownButtonFormField<String>(
                                  value: selectedPackage,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  hint: const Text("Pilih paket"),
                                  items: packages.entries.map((entry) {
                                    return DropdownMenuItem(
                                      value: entry.key,
                                      child: Text(
                                        "${entry.key} - Rp ${entry.value}",
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedPackage = value;
                                      selectedPrice = packages[value];
                                    });
                                  },
                                ),

                          const SizedBox(height: 20),

                          const Text("Catatan Khusus"),
                          const SizedBox(height: 5),
                          TextField(
                            controller: _notesController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              hintText:
                                  "Tambahkan catatan atau permintaan khusus",
                            ),
                          ),
                          const SizedBox(height: 20),

                          const Text(
                            'Ringkasan Harga',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              const Text('Total harga: '),
                              const Spacer(),
                              Text(
                                selectedPrice == null
                                    ? "Rp 0"
                                    : "Rp ${selectedPrice!}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          ElevatedButton(
                            onPressed: beliPaket,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              backgroundColor: Colors.pink,
                              foregroundColor: Colors.white,
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            child: const Text('Bayar Sekarang'),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 50),
                  Center(
                    child: Text(
                      "© 2024 EventHub. All rights reserved.",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
