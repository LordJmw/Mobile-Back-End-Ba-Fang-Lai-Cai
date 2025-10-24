import 'package:flutter/material.dart';
import 'package:projek_uts_mbr/cardDetail.dart';
import 'package:projek_uts_mbr/databases/vendorDatabase.dart';
import 'package:projek_uts_mbr/model/VendorModel.dart';
import 'dart:convert';

class ViewAllPage extends StatefulWidget {
  const ViewAllPage({super.key});

  @override
  State<ViewAllPage> createState() => _ViewAllPageState();
}

class _ViewAllPageState extends State<ViewAllPage> {
  late Future<List<Penyedia>> futureVendors;
  List<Penyedia> allVendors = [];
  List<Penyedia> filteredVendors = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    futureVendors = fetchData();
  }

  Future<List<Penyedia>> fetchData() async {
    Vendordatabase vendordatabase = Vendordatabase();
    final data = await vendordatabase.getData();
    final List<Penyedia> penyediaList = [];
    for (var vm in data) {
      penyediaList.addAll(vm.penyedia);
    }
    allVendors = penyediaList;
    filteredVendors = penyediaList;
    return penyediaList;
  }

  void _filterData(String query) async {
    Vendordatabase vendordatabase = Vendordatabase();

    if (query.isEmpty) {
      setState(() {
        filteredVendors = allVendors;
      });
      return;
    }

    final results = await vendordatabase.searchVendors(query);

    setState(() {
      filteredVendors = results;
    });
  }

  int getBasicPrice(Penyedia vendor) {
    if (vendor.harga == null) return 0;
    final hargaMap = vendor.harga.toJson();
    int minPrice = -1;
    for (var value in hargaMap.values) {
      if (value is Map<String, dynamic> && value['harga'] is int) {
        final currentPrice = value['harga'] as int;
        if (minPrice == -1 || currentPrice < minPrice) {
          minPrice = currentPrice;
        }
      }
    }
    return minPrice == -1 ? 0 : minPrice;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Our Product"),
        foregroundColor: Colors.black,
      ),
      body: FutureBuilder<List<Penyedia>>(
        future: futureVendors,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

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
              Expanded(
                child: filteredVendors.isEmpty
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
                        itemCount: filteredVendors.length,
                        itemBuilder: (context, index) {
                          final vendor = filteredVendors[index];
                          return buildCard(
                            name: vendor.nama,
                            description: vendor.deskripsi,
                            rating: vendor.rating,
                            price: getBasicPrice(vendor),
                            imageUrl: vendor.image,
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
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Image.network(
                imageUrl,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 140,
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image, size: 40),
                ),
              ),
            ),
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
                          "Rp $price",
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
