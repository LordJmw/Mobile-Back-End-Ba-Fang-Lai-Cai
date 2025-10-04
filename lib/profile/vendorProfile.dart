import 'package:flutter/material.dart';
import 'package:projek_uts_mbr/order.dart';
import 'package:projek_uts_mbr/services/dataServices.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  // Map<String, dynamic> infoVendor = {};
  // Map<String, dynamic> infoPaket = {};
  // int ulasan = 0;
  // bool loading = true;
  // String errorMessage = '';

  // formatPrice(int price) {
  //   String temp = price.toString();
  //   String result = '';
  //   int count = 0;
  //   for (int i = temp.length - 1; i >= 0; i--) {
  //     result = temp[i] + result;
  //     count++;
  //     if (count % 3 == 0 && i != 0) {
  //       result = '.' + result;
  //     }
  //   }
  //   return result;
  // }

  // Future<void> loadData(String namaVendor) async {
  //   try {
  //     setState(() {
  //       loading = true;
  //       errorMessage = '';
  //     });

  //     Dataservices dataservices = Dataservices();
  //     final vendor = await dataservices.loadDataDariNama(namaVendor);

  //     if (vendor.isEmpty) {
  //       throw Exception('Vendor tidak ditemukan');
  //     }

  //     List<dynamic> testimoni = vendor['testimoni'] ?? [];

  //     setState(() {
  //       infoVendor = vendor;
  //       infoPaket = vendor['harga'];
  //       ulasan = testimoni.length;
  //       loading = false;
  //     });

  //     print('Loaded vendor: $vendor');
  //     print('Testimoni count: $ulasan');
  //   } catch (e) {
  //     print('Error loading vendor data: $e');
  //     setState(() {
  //       loading = false;
  //       errorMessage = 'Gagal memuat data vendor: $e';
  //     });
  //   }
  // }

  // @override
  // void initState() {
  //   super.initState();
  //   loadData(widget.namaVendor);
  // }

  // Data statis/dummy
  final Map<String, dynamic> infoVendor = {
    'image': '',
    'nama': 'User A',
    'rating': 4.5,
    'deskripsi':
        'Ini adalah deskripsi vendor contoh. Menyediakan layanan terbaik untuk acara Anda.',
    'testimoni': [
      // {
      //   'nama': 'Budi',
      //   'rating': 5,
      //   'tanggal': '2024-06-01',
      //   'isi': 'Pelayanan sangat memuaskan!',
      // },
      // {
      //   'nama': 'Siti',
      //   'rating': 4,
      //   'tanggal': '2024-05-20',
      //   'isi': 'Cukup baik dan profesional.',
      // },
    ],
  };

  List<Map<String, dynamic>> paketList = [];

  // Fungsi untuk menambah paket baru (dummy)
  void tambahPaketBaru() {
    setState(() {
      paketList.add({
        'nama': 'Nama Paket',
        'harga': 0,
        'jasa': 'Isi jasa di sini',
      });
    });
  }

  final int ulasan = 2;
  final bool loading = false;
  final String errorMessage = '';

  // Tambahkan controller untuk edit
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _fotoController = TextEditingController();
  final TextEditingController _bgController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _namaController.text = infoVendor['nama'] ?? '';
    _deskripsiController.text = infoVendor['deskripsi'] ?? '';
    _fotoController.text = infoVendor['image'] ?? '';
    _bgController.text = infoVendor['background'] ?? '';
  }

  void _editNama() async {
    _namaController.text = infoVendor['nama'] ?? '';
    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Edit Nama'),
            content: TextField(
              controller: _namaController,
              decoration: InputDecoration(labelText: 'Nama'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    infoVendor['nama'] = _namaController.text;
                  });
                  Navigator.pop(context);
                },
                child: Text('Simpan'),
              ),
            ],
          ),
    );
  }

  void _editDeskripsi() async {
    _deskripsiController.text = infoVendor['deskripsi'] ?? '';
    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Edit Deskripsi'),
            content: TextField(
              controller: _deskripsiController,
              decoration: InputDecoration(labelText: 'Deskripsi'),
              maxLines: 3,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    infoVendor['deskripsi'] = _deskripsiController.text;
                  });
                  Navigator.pop(context);
                },
                child: Text('Simpan'),
              ),
            ],
          ),
    );
  }

  void _editFotoProfil() async {
    _fotoController.text = infoVendor['image'] ?? '';
    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Edit Foto Profil (URL)'),
            content: TextField(
              controller: _fotoController,
              decoration: InputDecoration(labelText: 'URL Foto Profil'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    infoVendor['image'] = _fotoController.text;
                  });
                  Navigator.pop(context);
                },
                child: Text('Simpan'),
              ),
            ],
          ),
    );
  }

  void _editBackgroundImage() async {
    _bgController.text = infoVendor['background'] ?? '';
    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Edit Background Image (URL)'),
            content: TextField(
              controller: _bgController,
              decoration: InputDecoration(labelText: 'URL Background Image'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    infoVendor['background'] = _bgController.text;
                  });
                  Navigator.pop(context);
                },
                child: Text('Simpan'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 241, 240, 240),
      appBar: AppBar(title: Text("Profil Vendor"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Background image section
                      Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            height: 180,
                            color: Colors.grey[300],
                            child:
                                infoVendor['background'] != null &&
                                        infoVendor['background'] != ''
                                    ? Image.network(
                                      infoVendor['background'],
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (_, __, ___) =>
                                              const Icon(Icons.image, size: 60),
                                    )
                                    : const Icon(
                                      Icons.image,
                                      size: 60,
                                      color: Colors.grey,
                                    ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              tooltip: 'Edit Background',
                              onPressed: _editBackgroundImage,
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 36,
                                  backgroundColor: Colors.grey[200],
                                  backgroundImage:
                                      infoVendor['image'] != null &&
                                              infoVendor['image'] != ''
                                          ? NetworkImage(infoVendor['image'])
                                          : null,
                                  child:
                                      infoVendor['image'] == null ||
                                              infoVendor['image'] == ''
                                          ? const Icon(
                                            Icons.person,
                                            size: 40,
                                            color: Colors.grey,
                                          )
                                          : null,
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.edit,
                                      size: 20,
                                      color: Colors.blue,
                                    ),
                                    tooltip: 'Edit Foto Profil',
                                    onPressed: _editFotoProfil,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          infoVendor['nama'] ?? "Nama Vendor",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.edit,
                                          size: 20,
                                          color: Colors.blue,
                                        ),
                                        tooltip: 'Edit Nama',
                                        onPressed: _editNama,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        "${infoVendor['rating'] ?? 0} (0 ulasan)",
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Tentang ${infoVendor['nama']?.split(" ").first ?? "Vendor"}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    infoVendor['deskripsi'] ??
                                        "Belum ada deskripsi untuk vendor ini.",
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.edit,
                                size: 20,
                                color: Colors.blue,
                              ),
                              tooltip: 'Edit Deskripsi',
                              onPressed: _editDeskripsi,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ],
              ),
            ),

            // --- Bagian Paket ---
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                children: [
                  const Text(
                    "Paket Anda",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Spacer(),
                  ElevatedButton.icon(
                    onPressed: tambahPaketBaru,
                    icon: Icon(Icons.add),
                    label: Text("Tambah Paket"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (paketList.isEmpty)
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(Icons.inbox, size: 40, color: Colors.grey),
                      SizedBox(height: 10),
                      Text(
                        "Belum ada paket.\nKlik 'Tambah Paket' untuk menambahkan.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              )
            else
              Column(
                children:
                    paketList.map((paket) {
                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                paket['nama'] ?? "Nama Paket",
                                style: TextStyle(
                                  color: Colors.pink,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                "Rp ${paket['harga'] ?? 0}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                ),
                              ),
                              Text("per acara"),
                              SizedBox(height: 10),
                              Text(
                                paket['jasa'] ?? "",
                                style: TextStyle(fontSize: 14),
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () {
                                      // Aksi edit paket (belum diimplementasi)
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      setState(() {
                                        paketList.remove(paket);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
              ),

            // --- Bagian Ulasan Klien ---
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Container(
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Ulasan Klien",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (infoVendor['testimoni'] == null ||
                          infoVendor['testimoni'].isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.rate_review,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 10),
                                Text(
                                  "Belum ada ulasan klien.",
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ...infoVendor['testimoni'].map<Widget>((ulasan) {
                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const CircleAvatar(
                                        radius: 18,
                                        backgroundColor: Colors.grey,
                                        child: Icon(
                                          Icons.person,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              ulasan['nama'] ?? "Anonim",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),

                                            Row(
                                              children: List.generate(
                                                5,
                                                (index) => Icon(
                                                  index <
                                                          (ulasan['rating'] ??
                                                              0)
                                                      ? Icons.star
                                                      : Icons.star_border,
                                                  size: 16,
                                                  color: Colors.amber,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        ulasan['tanggal'] ?? "",
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    ulasan['isi'] ?? "",
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
