import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:projek_uts_mbr/databases/customerDatabase.dart';
import 'package:projek_uts_mbr/services/sessionManager.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  List<Map<String, dynamic>> purchaseHistory = [];
  final CustomerDatabase customerDb = CustomerDatabase();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadPurchaseHistory();
  }

  Future<void> loadPurchaseHistory() async {
    try {
      final sessionManager = SessionManager();
      String? email = await sessionManager.getEmail();

      print("Loading purchase history for email: $email");

      if (email == null) {
        print("Email is null");
        setState(() {
          isLoading = false;
        });
        return;
      }

      final customer = await customerDb.getCustomerByEmail(email);
      if (customer == null) {
        print("Customer not found for email: $email");
        setState(() {
          isLoading = false;
        });
        return;
      }

      print("Customer found: ${customer.nama}");

      final history = await customerDb.getPurchaseHistoryByCustomerId(
        customer.id!,
      );

      print("Purchase history loaded: ${history.length} items");

      setState(() {
        purchaseHistory = history;
        isLoading = false;
      });
    } catch (e) {
      print("Error loading purchase history: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _editPurchase(Map<String, dynamic> purchase) async {
    final details = jsonDecode(purchase['purchase_details']);

    TextEditingController locationController = TextEditingController(
      text: details['location'] ?? '',
    );
    TextEditingController notesController = TextEditingController(
      text: details['notes'] ?? '',
    );
    DateTime? selectedDate;

    // Parse existing date
    if (details['date'] != null) {
      try {
        selectedDate = DateTime.parse(details['date']);
      } catch (e) {
        print("Error parsing date: $e");
      }
    }

    await showDialog(
      context: context,
      builder: (context) {
        // Gunakan StatefulBuilder untuk manage state di dalam dialog
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Edit Pesanan"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Tanggal Acara
                    const Text(
                      "Tanggal Acara",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    InkWell(
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate ?? DateTime.now(),
                          firstDate: DateTime(2024),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          // Gunakan setDialogState untuk update UI di dalam dialog
                          setDialogState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          selectedDate == null
                              ? "Pilih tanggal"
                              : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Lokasi
                    const Text(
                      "Lokasi",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextField(
                      controller: locationController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Masukkan lokasi acara",
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Catatan
                    const Text(
                      "Catatan Khusus",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextField(
                      controller: notesController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Tambahkan catatan",
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Batal"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (selectedDate == null ||
                        locationController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: Colors.red,
                          content: Text("Lokasi dan tanggal harus diisi"),
                        ),
                      );
                      return;
                    }

                    try {
                      // Update purchase details
                      final updatedDetails = {
                        'vendor': details['vendor'],
                        'package': details['package'],
                        'price': details['price'],
                        'date': selectedDate!.toIso8601String(),
                        'location': locationController.text,
                        'notes': notesController.text,
                        'status': details['status'] ?? 'pending',
                      };

                      await customerDb.updatePurchaseHistory(
                        purchase['id'],
                        jsonEncode(updatedDetails),
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: Colors.green,
                          content: Text("Pesanan berhasil diupdate"),
                        ),
                      );

                      Navigator.pop(context);
                      await loadPurchaseHistory(); // Refresh data
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.red,
                          content: Text("Error: $e"),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
                  child: const Text(
                    "Simpan",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deletePurchase(int purchaseId, String vendorName) async {
    bool confirm =
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Hapus Pesanan"),
            content: Text("Yakin ingin menghapus pesanan dari $vendorName?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Batal"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text(
                  "Hapus",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (confirm) {
      try {
        await customerDb.deletePurchaseHistory(purchaseId);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text("Pesanan berhasil dihapus"),
          ),
        );

        await loadPurchaseHistory();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.red, content: Text("Error: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.pink)),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Profil Pengguna")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                children: const [
                  Text(
                    "Riwayat Pembelian Anda",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),

            if (purchaseHistory.isEmpty)
              Card(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  width: double.infinity,
                  child: Column(
                    children: const [
                      Icon(
                        Icons.shopping_bag_outlined,
                        size: 40,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Belum ada pembelian.\nSilakan beli paket dari vendor.",
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              Column(
                children: purchaseHistory.map((purchase) {
                  try {
                    final details = jsonDecode(purchase['purchase_details']);

                    return Card(
                      child: Container(
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header dengan tombol edit/delete
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      details['vendor']?.toString() ??
                                          'Vendor tidak diketahui',
                                      style: const TextStyle(
                                        color: Colors.pink,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  // Tombol Edit dan Delete
                                  PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert),
                                    onSelected: (value) {
                                      if (value == 'edit') {
                                        _editPurchase(purchase);
                                      } else if (value == 'delete') {
                                        _deletePurchase(
                                          purchase['id'],
                                          details['vendor']?.toString() ??
                                              'Vendor',
                                        );
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'edit',
                                        child: Row(
                                          children: [
                                            Icon(Icons.edit, size: 20),
                                            SizedBox(width: 8),
                                            Text('Edit'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.delete,
                                              size: 20,
                                              color: Colors.red,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              'Hapus',
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "${details['package'] ?? 'Paket'} - Rp ${details['price'] ?? 0}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                "Tanggal acara: ${_formatDate(details['date'])}",
                              ),
                              Text("Lokasi: ${details['location'] ?? '-'}"),
                              if (details['notes'] != null &&
                                  details['notes'].isNotEmpty)
                                Text("Catatan: ${details['notes']}"),
                              const SizedBox(height: 8),
                              Text(
                                "Dibeli pada: ${_formatDate(purchase['purchase_date'])}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  } catch (e) {
                    print("Error parsing purchase details: $e");
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text("Error menampilkan data pembelian: $e"),
                      ),
                    );
                  }
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '-';
    try {
      final date = DateTime.parse(dateString);
      return "${date.day}/${date.month}/${date.year}";
    } catch (e) {
      return dateString.split('T').first;
    }
  }
}
