import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:projek_uts_mbr/auth/loginCostumer.dart';
import 'package:projek_uts_mbr/databases/customerDatabase.dart';
import 'package:projek_uts_mbr/databases/purchaseHistoryDatabase.dart';
import 'package:projek_uts_mbr/model/CustomerModel.dart';
import 'package:projek_uts_mbr/services/sessionManager.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  late StreamController<CustomerModel?> _customerController;
  late StreamController<List<Map<String, dynamic>>> _purchaseHistoryController;
  final Customerdatabase customerDb = Customerdatabase();
  final Purchasehistorydatabase purchaseDb = Purchasehistorydatabase();
  final SessionManager sessionManager = SessionManager();

  @override
  void initState() {
    super.initState();
    _customerController = StreamController<CustomerModel?>();
    _purchaseHistoryController = StreamController<List<Map<String, dynamic>>>();
    _loadCustomerData();
  }

  @override
  void dispose() {
    _customerController.close();
    _purchaseHistoryController.close();
    super.dispose();
  }

  Future<void> _logout() async {
    final session = SessionManager();
    await session.logout();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginCustomer()),
      (route) => false,
    );
  }

  Future<void> _loadCustomerData() async {
    try {
      final String? customerEmail = await sessionManager.getEmail();
      if (customerEmail != null) {
        final customer = await customerDb.getCustomerByEmail(customerEmail);
        print('customer loaded: $customer');
        if (!_customerController.isClosed) {
          _customerController.add(customer);
        }

        // Load purchase history jika customer ditemukan
        if (customer != null) {
          await _loadPurchaseHistory(customer.id!);
        }
      } else {
        if (!_customerController.isClosed) {
          _customerController.add(null);
        }
        if (!_purchaseHistoryController.isClosed) {
          _purchaseHistoryController.add([]);
        }
      }
    } catch (e) {
      print("Error loading customer data: $e");
      if (!_customerController.isClosed) {
        _customerController.addError(e);
      }
    }
  }

  Future<void> _loadPurchaseHistory(int customerId) async {
    try {
      final history = await purchaseDb.getPurchaseHistoryByCustomerId(
        customerId,
      );
      if (!_purchaseHistoryController.isClosed) {
        _purchaseHistoryController.add(history);
      }
    } catch (e) {
      print("Error loading purchase history: $e");
      if (!_purchaseHistoryController.isClosed) {
        _purchaseHistoryController.addError(e);
      }
    }
  }

  Future<void> _editProfile() async {
    // Kita perlu mendapatkan current customer data dengan cara yang berbeda
    // Karena StreamController tidak punya .value, kita akan gunakan session manager

    try {
      final String? customerEmail = await sessionManager.getEmail();
      print('pengecekkan email session manager : $customerEmail');
      if (customerEmail == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text("Tidak dapat memuat data customer"),
          ),
        );
        return;
      }

      final currentCustomer = await customerDb.getCustomerByEmail(
        customerEmail,
      );
      if (currentCustomer == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text("Customer tidak ditemukan"),
          ),
        );
        return;
      }

      // Buat controller dengan data lama
      TextEditingController namaController = TextEditingController(
        text: currentCustomer.nama,
      );
      TextEditingController emailController = TextEditingController(
        text: currentCustomer.email,
      );
      TextEditingController teleponController = TextEditingController(
        text: currentCustomer.telepon,
      );
      TextEditingController alamatController = TextEditingController(
        text: currentCustomer.alamat,
      );

      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Edit Profil"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: namaController,
                    decoration: const InputDecoration(
                      labelText: "Nama Lengkap",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // TextField(
                  //   controller: emailController,
                  //   decoration: const InputDecoration(
                  //     labelText: "Email",
                  //     border: OutlineInputBorder(),
                  //     prefixIcon: Icon(Icons.email),
                  //   ),
                  //   keyboardType: TextInputType.emailAddress,
                  // ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: teleponController,
                    decoration: const InputDecoration(
                      labelText: "Nomor Telepon",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: alamatController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: "Alamat",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on),
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
                  // Validasi input
                  if (namaController.text.isEmpty ||
                      emailController.text.isEmpty ||
                      teleponController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: Colors.red,
                        content: Text("Nama, email, dan telepon harus diisi"),
                      ),
                    );
                    return;
                  }

                  try {
                    // Buat customer model dengan data baru
                    final updatedCustomer = CustomerModel(
                      id: currentCustomer.id,
                      nama: namaController.text,
                      email: emailController.text,
                      password: currentCustomer.password, // Password tetap
                      telepon: teleponController.text,
                      alamat: alamatController.text,
                    );

                    // Update ke database
                    final result = await customerDb.updateCustomer(
                      updatedCustomer,
                    );

                    if (result) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: Colors.green,
                          content: Text("Profil berhasil diupdate"),
                        ),
                      );

                      Navigator.pop(context);
                      await _refreshData(); // Refresh data
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: Colors.red,
                          content: Text("Gagal mengupdate profil"),
                        ),
                      );
                    }
                  } catch (e) {
                    print("Error updating profile: $e");
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
    } catch (e) {
      print("Error loading customer for edit: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.red, content: Text("Error: $e")),
      );
    }
  }

  Future<void> _refreshData() async {
    await _loadCustomerData();
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
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Edit Pesanan"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
                      final updatedDetails = {
                        'vendor': details['vendor'],
                        'package': details['package'],
                        'price': details['price'],
                        'date': selectedDate!.toIso8601String(),
                        'location': locationController.text,
                        'notes': notesController.text,
                        'status': details['status'] ?? 'pending',
                      };

                      await purchaseDb.updatePurchaseHistory(
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
                      await _refreshData(); // Refresh data setelah edit
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
        await purchaseDb.deletePurchaseHistory(purchaseId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text("Pesanan berhasil dihapus"),
          ),
        );
        await _refreshData(); // Refresh data setelah delete
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.red, content: Text("Error: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil Pengguna"),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshData),
        ],
      ),
      body: StreamBuilder<CustomerModel?>(
        stream: _customerController.stream,
        builder: (context, customerSnapshot) {
          if (customerSnapshot.connectionState == ConnectionState.waiting &&
              !customerSnapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.pink),
            );
          }

          if (customerSnapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${customerSnapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshData,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          final currentCustomer = customerSnapshot.data;

          if (currentCustomer == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  const Text(
                    "Tidak dapat memuat data customer",
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout),
                    label: const Text("Logout"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(200, 45),
                    ),
                  ),
                ],
              ),
            );
          }

          return StreamBuilder<List<Map<String, dynamic>>>(
            stream: _purchaseHistoryController.stream,
            builder: (context, historySnapshot) {
              final purchaseHistory = historySnapshot.data ?? [];

              return SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Card(
                      child: Container(
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    "Profil Saya",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.pink,
                                    ),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 20),
                                    onPressed: () {
                                      _editProfile();
                                    },
                                    color: Colors.pink,
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.network(
                                    'https://cdn-icons-png.flaticon.com/512/149/149071.png',
                                    fit: BoxFit.cover,
                                    width: 100,
                                    height: 100,
                                  ),
                                ],
                              ),

                              Text(
                                currentCustomer.nama,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.pink,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text("Email: ${currentCustomer.email}"),
                              Text("Telepon: ${currentCustomer.telepon}"),
                              Text("Alamat: ${currentCustomer.alamat}"),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Purchase History Section
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        children: const [
                          Text(
                            "Riwayat Pembelian Anda",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (historySnapshot.connectionState ==
                        ConnectionState.waiting)
                      const Center(
                        child: CircularProgressIndicator(color: Colors.pink),
                      )
                    else if (purchaseHistory.isEmpty)
                      _buildEmptyState()
                    else
                      Column(
                        children: purchaseHistory
                            .map((purchase) => _buildPurchaseCard(purchase))
                            .toList(),
                      ),

                    const SizedBox(height: 25),

                    ElevatedButton.icon(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout),
                      label: const Text("Logout"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(24),
        width: double.infinity,
        child: Column(
          children: const [
            Icon(Icons.shopping_bag_outlined, size: 40, color: Colors.grey),
            SizedBox(height: 10),
            Text(
              "Belum ada pembelian.\nSilakan beli paket dari vendor.",
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPurchaseCard(Map<String, dynamic> purchase) {
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
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      onSelected: (value) {
                        if (value == 'edit') {
                          _editPurchase(purchase);
                        } else if (value == 'delete') {
                          _deletePurchase(
                            purchase['id'],
                            details['vendor']?.toString() ?? 'Vendor',
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
                              Icon(Icons.delete, size: 20, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                'Hapus',
                                style: TextStyle(color: Colors.red),
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
                Text("Tanggal acara: ${_formatDate(details['date'])}"),
                Text("Lokasi: ${details['location'] ?? '-'}"),
                if (details['notes'] != null && details['notes'].isNotEmpty)
                  Text("Catatan: ${details['notes']}"),
                const SizedBox(height: 8),
                Text(
                  "Dibeli pada: ${_formatDate(purchase['purchase_date'])}",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
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
