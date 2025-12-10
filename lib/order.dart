import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:projek_uts_mbr/analytics/eventLogs.dart';
import 'package:projek_uts_mbr/databases/customerDatabase.dart';
import 'package:projek_uts_mbr/databases/purchaseHistoryDatabase.dart';
import 'package:projek_uts_mbr/databases/vendorDatabase.dart';
import 'package:projek_uts_mbr/l10n/app_localizations.dart';
import 'package:projek_uts_mbr/l10n/app_localizations_en.dart';
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

      final harga = vendor.penyedia.first.harga;
      if (harga.basic.harga > 0) {
        parsedPackages['Basic'] = harga.basic.harga;
      }
      if (harga.premium.harga > 0) {
        parsedPackages['Premium'] = harga.premium.harga;
      }
      if (harga.custom.harga > 0) {
        parsedPackages['Custom'] = harga.custom.harga;
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

  bool isBuying = false;

  beliPaket(BuildContext context) async {
    print("Tombol beliPaket ditekan"); // Debug

    if (isLoading) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.orange,
          content: Text(AppLocalizations.of(context)!.loadingData),
        ),
      );
      return;
    }

    if (isBuying) {
      print("Sedang dalam proses pembelian"); // Debug
      return;
    }

    setState(() => isBuying = true);
    print("isBuying di-set ke true"); // Debug

    try {
      SessionManager sessionManager = SessionManager();
      String? userType = await sessionManager.getUserType();
      String? email = await sessionManager.getEmail();

      print("User type: $userType, Email: $email"); // Debug

      if (userType == "vendor") {
        _showError(AppLocalizations.of(context)!.loginAsCustomerToBuy);
        setState(() => isBuying = false);
        return;
      }

      if (!_validateFormInputs(context)) {
        setState(() => isBuying = false);
        return;
      }

      print("Validasi berhasil"); // Debug

      final purchaseDetails = PurchaseDetails(
        vendor: widget.namaVendor,
        packageName: selectedPackage!,
        price: selectedPrice!,
        date: selectedDate!,
        location: _locationController.text,
        notes: _notesController.text,
        status: 'pending',
      );

      print("Purchase details dibuat: ${purchaseDetails.toJson()}"); // Debug

      final purchaseHistory = PurchaseHistory(
        purchaseDetails: purchaseDetails,
        purchaseDate: DateTime.now(),
      );

      print("Menambahkan ke database..."); // Debug
      await _purchaseDb.addPurchaseHistory(purchaseHistory);
      print("Berhasil ditambahkan ke database"); // Debug

      await Eventlogs().beliPaket(
        widget.namaVendor,
        selectedPackage!,
        selectedPrice.toString(),
        selectedDate!.toIso8601String(),
        _locationController.text,
        email!,
      );

      _showSuccess(AppLocalizations.of(context)!.purchaseSuccessful);

      // Tunggu sebentar sebelum navigate agar user bisa melihat snackbar
      await Future.delayed(const Duration(seconds: 2));

      setState(() => isBuying = false);

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
        (route) => false,
      );
    } catch (e) {
      print("ERROR dalam beliPaket: $e"); // Debug penting
      _showError("Terjadi kesalahan: $e");
      setState(() => isBuying = false);
    }
  }

  bool _validateFormInputs(BuildContext context) {
    if (selectedDate == null) {
      _showError(AppLocalizations.of(context)!.selectEventDateFirst);
      return false;
    }

    if (_locationController.text.isEmpty) {
      _showError(AppLocalizations.of(context)!.enterEventLocation);
      return false;
    }

    if (selectedPackage == null) {
      _showError(AppLocalizations.of(context)!.selectPackageFirst);
      return false;
    }

    if (!packages.containsKey(selectedPackage)) {
      _showError(AppLocalizations.of(context)!.packageNotAvailable);
      return false;
    }

    return true;
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(backgroundColor: Colors.red, content: Text(msg)));
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(backgroundColor: Colors.green, content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 243, 243, 245),
      appBar: AppBar(title: Text(l10n.paymentPage), centerTitle: true),
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
                    children: [
                      Text(
                        l10n.appTitle,
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
                          Text(
                            l10n.orderForm,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // TANGGAL
                          Text(l10n.eventDate),
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
                                    ? l10n.eventDateLabel
                                    : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // LOKASI
                          Text(l10n.location),
                          const SizedBox(height: 5),
                          TextField(
                            controller: _locationController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              hintText: l10n.enterEventLocation,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // PAKET
                          Text(l10n.selectedPackage),
                          const SizedBox(height: 5),
                          packages.isEmpty
                              ? Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    l10n.noPackagesAvailable,
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

                          Text(l10n.specialNotes),
                          const SizedBox(height: 5),
                          TextField(
                            controller: _notesController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              hintText: l10n.addSpecialNotes,
                            ),
                          ),
                          const SizedBox(height: 20),

                          Text(
                            l10n.priceSummary,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              Text('${l10n.totalPrice}: '),
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
                            onPressed: () {
                              beliPaket(context);
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              backgroundColor: Colors.pink,
                              foregroundColor: Colors.white,
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            child: Text(AppLocalizations.of(context)!.payNow),
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
