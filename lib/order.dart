import 'package:flutter/material.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  DateTime? selectedDate;
  String? selectedPackage;

  final List<String> packages = [
    "Paket 1",
    "Paket 2",
    "Paket 3",
  ];

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "EventHub",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink,
                  ),
                ),
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.pink,
                        side: const BorderSide(color: Colors.pink),
                      ),
                      child: const Text("Masuk"),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("Daftar"),
                    ),
                  ],
                )
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
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      hint: const Text("Pilih paket"),
                      items: packages.map((pkg) {
                        return DropdownMenuItem(
                          value: pkg,
                          child: Text(pkg),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedPackage = value;
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
                        hintText:
                            "Tambahkan catatan atau permintaan khusus",
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('Ringkasan Harga',
                      style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)
                    ),
                    Row(
                      children: [
                        Text('total harga: '),
                        Spacer(),
                        Text('Rp 0.')
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(onPressed: (){}, child: Text('Bayar Sekarang'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                        backgroundColor: Colors.pink,
                        foregroundColor: Colors.white,
                        textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                      ),
                    )
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
