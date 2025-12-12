import 'package:flutter/material.dart';
import 'package:projek_uts_mbr/analytics/eventLogs.dart';
import 'package:projek_uts_mbr/cardDetail.dart';
import 'package:projek_uts_mbr/category/category_consts.dart';
import 'package:projek_uts_mbr/databases/vendorDatabase.dart';
import 'package:projek_uts_mbr/helper/semantics.dart';
import 'package:projek_uts_mbr/l10n/app_localizations.dart';
import 'package:projek_uts_mbr/model/VendorModel.dart';
import 'package:projek_uts_mbr/provider/language_provider.dart';
import 'package:provider/provider.dart';

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
    await Eventlogs().logSearchBarUsed(query);

    if (query.isEmpty) {
      setState(() => filteredVendors = allVendors);
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    Vendordatabase vendordatabase = Vendordatabase();

    // 1. Cek apakah query adalah kategori
    final categoryCode = CategoryConst.searchLabelToCode(query, l10n);
    print("search label to code : ${categoryCode}");
    if (categoryCode != null) {
      // Ambil seluruh data vendor sesuai kategori
      final allData = await vendordatabase.getData();

      List<Penyedia> result = [];

      for (var vm in allData) {
        // Konversi kategori database ke code
        final dbCode = CategoryConst.dbLabelToCode[vm.kategori];
        if (dbCode == categoryCode) {
          result.addAll(vm.penyedia);
        }
      }

      setState(() => filteredVendors = result);
      return;
    }

    //bukan kategori, maka text search normal
    final results = await vendordatabase.searchVendors(query);

    setState(() {
      filteredVendors = results;
    });
  }

  int getBasicPrice(Penyedia vendor) {
    if (vendor.harga == null) return 0;

    final hargaMap = vendor.harga.toJson();
    List<int> hargaList = [];

    for (var value in hargaMap.values) {
      if (value is Map<String, dynamic> && value['harga'] is int) {
        final currentPrice = value['harga'] as int;
        if (currentPrice > 0) {
          hargaList.add(currentPrice);
        }
      }
    }

    if (hargaList.isEmpty) return 0;

    hargaList.sort();
    return hargaList.first;
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context).locale;
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.ourProduct),
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
                child: Semantics(
                  label: tr('textField', 'kategoriPencarian', lang),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: l10n.searchVendorOrCategory,
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
              ),
              Expanded(
                child: filteredVendors.isEmpty
                    ? Center(child: Text(l10n.noResults))
                    : GridView.builder(
                        padding: const EdgeInsets.all(12),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.6,
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
                            lang: lang,
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
    required Locale lang,
  }) {
    return Semantics(
      label: trDetail(
        'button',
        'kategoriCard',
        lang,
        name,
        "${rating}",
        "${price}",
      ),
      hint: trDropDown('button', 'kategoriCard', lang, name),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Carddetail(namaVendor: name),
            ),
          );
        },
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Image.network(
                  imageUrl,
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    height: 100,
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
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            description,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black87,
                            ),
                            maxLines: 3,
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
                                size: 14,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                rating.toStringAsFixed(1),
                                style: const TextStyle(fontSize: 11),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            "Rp $price",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.pink[400],
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
      ),
    );
  }
}
