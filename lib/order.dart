import 'package:flutter/material.dart';
import 'package:projek_uts_mbr/services/dataServices.dart';

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

  DateTime? selectedDate;
  String? selectedPackage;
  int? selectedPrice;

  Map<String, int> packages = {};
  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    Dataservices dataservices = Dataservices();
    Map<String, dynamic> respond = await dataservices.loadDataDariNama(
      widget.namaVendor,
    );

    Map<String, dynamic> tipePaket = respond['harga'] as Map<String, dynamic>;
    print("Tipe paket: $tipePaket");

    Map<String, int> parsedPackages = {};
    tipePaket.forEach((key, value) {
      if (value is int) {
        parsedPackages[key] = value;
      } else if (value is Map && value['harga'] is int) {
        parsedPackages[key] = value['harga'];
      }
    });

    setState(() {
      packages = parsedPackages;

      if (widget.paketDipilih != null &&
          packages.containsKey(widget.paketDipilih)) {
        selectedPackage = widget.paketDipilih;
        selectedPrice = packages[widget.paketDipilih];
      }
    });

    print("Parsed packages: $packages");
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 243, 243, 245),
      appBar: AppBar(
        title: const Text("Halaman Pembayaran"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
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

            // FORM CARD
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
                    DropdownButtonFormField<String>(
                      value: selectedPackage,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      hint: const Text("Pilih paket"),
                      items:
                          packages.entries.map((entry) {
                            return DropdownMenuItem(
                              value: entry.key,
                              child: Text("${entry.key} - Rp ${entry.value}"),
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

                    // CATATAN
                    const Text("Catatan Khusus"),
                    const SizedBox(height: 5),
                    TextField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        hintText: "Tambahkan catatan atau permintaan khusus",
                      ),
                    ),
                    const SizedBox(height: 20),

                    // RINGKASAN HARGA
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
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // BUTTON BAYAR
                    ElevatedButton(
                      onPressed: () {
                        print(
                          "Order dibuat untuk paket $selectedPackage seharga Rp $selectedPrice",
                        );
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
