import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:projek_uts_mbr/cardDetail.dart';
import 'package:projek_uts_mbr/databases/vendorDatabase.dart';
import 'package:projek_uts_mbr/services/dataServices.dart';

class ViewAllPage extends StatefulWidget {
  const ViewAllPage({super.key});

  @override
  State<ViewAllPage> createState() => _ViewAllPageState();
}

class _ViewAllPageState extends State<ViewAllPage> {
  late Future<List<dynamic>> futureData;
  List<dynamic> allProviders = [];
  List<dynamic> filteredProviders = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    futureData = fetchData();
  }

  // Future<List<dynamic>> fetchData() async {
  //   Dataservices dataservices = Dataservices();
  //   List<dynamic> data = await dataservices.loadData();
  //   List<dynamic> providers = [];
  //   for (var kategori in data) {
  //     // untuk menyimpan juga kategori biar bisa dipakai untuk pencarian
  //     for (var penyedia in kategori["penyedia"]) {
  //       penyedia["kategori"] = kategori["kategori"];
  //       providers.add(penyedia);
  //     }
  //   }
  //   allProviders = providers;
  //   filteredProviders = providers;
  //   return providers;
  // }

  Future<List<dynamic>> fetchData() async {
    Vendordatabase vendordatabase = Vendordatabase();
    final data = await vendordatabase.getData();

    final providers =
        data
            .map(
              (vendor) => {
                "nama": vendor.nama,
                "deskripsi": vendor.deskripsi,
                "rating": vendor.rating,
                "harga": vendor.harga,
                "testimoni": vendor.testimoni,
                "email": vendor.email,
                "telepon": vendor.telepon,
                "image": vendor.image,
                "kategori": vendor.kategori,
              },
            )
            .toList();

    allProviders = providers;
    filteredProviders = providers;
    return providers;
  }

  void _filterData(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredProviders = allProviders;
      });
      return;
    }

    setState(() {
      filteredProviders =
          allProviders.where((item) {
            final name = (item["nama"] ?? "").toString().toLowerCase();
            final kategori = (item["kategori"] ?? "").toString().toLowerCase();
            return name.contains(query.toLowerCase()) ||
                kategori.contains(query.toLowerCase());
          }).toList();
    });
  }

  int getBasicPrice(Map<String, dynamic> penyedia) {
    try {
      final harga = jsonDecode(penyedia["harga"]);
      if (harga is Map) {
        final basic = harga["basic"];
        if (basic is int) return basic;
        if (basic is Map && basic["harga"] is int) return basic["harga"];
      }
    } catch (e) {
      print("Error parsing harga: $e");
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Our Product"),
        foregroundColor: Colors.black,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          //Search box untuk mencari berdasarkan nama penyedia jasa atau kategori
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Cari penyedia jasa atau kategori...",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: 16,
                    ),
                  ),
                  onChanged: _filterData,
                ),
              ),

              //Tampilan hasil pencarian dalam bentuk grid
              Expanded(
                child:
                    filteredProviders.isEmpty
                        ? const Center(child: Text("Tidak ada hasil"))
                        : GridView.builder(
                          padding: const EdgeInsets.all(12),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 16,
                                childAspectRatio: 0.7,
                              ),
                          itemCount: filteredProviders.length,
                          itemBuilder: (context, index) {
                            final item = filteredProviders[index];
                            return buildCard(
                              name: item["nama"],
                              description: item["deskripsi"],
                              rating: (item["rating"] as num).toDouble(),
                              price: getBasicPrice(item),
                              imageUrl:
                                  item["image"] ??
                                  "https://via.placeholder.com/400x300",
                            );
                          },
                        ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget buildCard({
    required String name,
    required String description,
    required double rating,
    required int price,
    required String imageUrl,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Carddetail(namaVendor: name)),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Image.network(
                imageUrl,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder:
                    (_, __, ___) => Container(
                      height: 140,
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image, size: 40),
                    ),
              ),
            ),
            // Isi
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              rating.toString(),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Rp ${price.toString()}",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.pink[200],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
