import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:projek_uts_mbr/cardDetail.dart';
import 'package:projek_uts_mbr/databases/vendorDatabase.dart';
import 'package:projek_uts_mbr/model/VendorModel.dart';
import 'package:projek_uts_mbr/services/dataServices.dart';
import 'package:projek_uts_mbr/viewall.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoryPage extends StatefulWidget {
  final String category;
  final bool useSavedPreferences;
  const CategoryPage({
    super.key,
    required this.category,
    required this.useSavedPreferences,
  });

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

formatPrice(int price) {
  String temp = price.toString();
  String result = '';
  int count = 0;
  for (int i = temp.length - 1; i >= 0; i--) {
    result = temp[i] + result;
    count++;
    if (count % 3 == 0 && i != 0) {
      result = '.' + result;
    }
  }
  return result;
}

int getBasicPrice(Vendormodel penyedia) {
  try {
    final hargaMap = jsonDecode(penyedia.harga) as Map<String, dynamic>;
    if (hargaMap.isEmpty) {
      return 0;
    }

    int minPrice = -1;

    for (var packageData in hargaMap.values) {
      if (packageData is Map<String, dynamic> && packageData['harga'] is int) {
        final currentPrice = packageData['harga'] as int;
        if (minPrice == -1 || currentPrice < minPrice) {
          minPrice = currentPrice;
        }
      }
    }
    return minPrice == -1 ? 0 : minPrice;
  } catch (e) {
    print("Error parsing harga for lowest price: $e");
  }
  return 0;
}

class _CategoryPageState extends State<CategoryPage> {
  RangeValues _rentangHarga = RangeValues(0, 10000000);

  List<bool> _starIsclicked = [false, false, false, false, false];
  int _jumlahBintang = 0;
  List<bool> _layananDipilih = [
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
  ];
  List<String> _layanan = [
    "Fotografi & Videografi",
    "Event Organizer & Planner",
    "Makeup & Fashion",
    "Entertainment & Performers",
    "Dekorasi & Venue",
    "Catering & F&B",
    "Teknologi & Produksi Acara",
    "Transportasi & Logistik",
    "Layanan Pendukung Lainnya",
  ];

  List<String> tapppedCategory = [];

  List<dynamic> data = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    Vendordatabase vendordatabase = Vendordatabase();
    vendordatabase.getData(limit: 20).then((res) async {
      final prefs = await SharedPreferences.getInstance();

      setState(() {
        data = res;
        loading = false;
        tapppedCategory =
            prefs.getStringList("${_preferencesKey}_category") ?? [];
        if (!widget.useSavedPreferences && tapppedCategory.isEmpty) {
          if (_layanan.contains(widget.category)) {
            _layananDipilih[_layanan.indexOf(widget.category)] = true;
            tapppedCategory = [widget.category];
          }
        } else {
          for (var i = 0; i < _layanan.length; i++) {
            _layananDipilih[i] = tapppedCategory.contains(_layanan[i]);
          }
        }

        _rentangHarga = RangeValues(
          prefs.getDouble("${_preferencesKey}_price_min") ?? 0,
          prefs.getDouble("${_preferencesKey}_price_max") ?? 10000000,
        );

        _jumlahBintang = prefs.getInt("${_preferencesKey}_rating") ?? 0;
        for (int i = 0; i < _starIsclicked.length; i++) {
          _starIsclicked[i] = i < _jumlahBintang;
        }
      });
    });
  }

  String get _preferencesKey {
    if (widget.useSavedPreferences) {
      return "global_filter";
    } else {
      return "category_${widget.category}";
    }
  }

  void saveFilterPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final selectedService = _layanan
        .asMap()
        .entries
        .where((entry) => _layananDipilih[entry.key])
        .map((entry) => entry.value)
        .toList();

    await prefs.setStringList("${_preferencesKey}_category", selectedService);
    await prefs.setDouble("${_preferencesKey}_price_min", _rentangHarga.start);
    await prefs.setDouble("${_preferencesKey}_price_max", _rentangHarga.end);
    await prefs.setInt("${_preferencesKey}_rating", _jumlahBintang);
  }

  Future<SharedPreferences> getSharedPrefsInstance() async {
    return await SharedPreferences.getInstance();
  }

  List<Vendormodel> filterData() {
    final selectedService = _layanan
        .asMap()
        .entries
        .where((entry) => _layananDipilih[entry.key])
        .map((entry) => entry.value)
        .toList();

    tapppedCategory = selectedService;

    List<Vendormodel> result = [];

    for (var vendor in data) {
      int hargaBasic = 0;

      hargaBasic = getBasicPrice(vendor);

      final rating = vendor.rating;
      final kategoriName = vendor.kategori;

      bool matchesPrice =
          hargaBasic >= _rentangHarga.start && hargaBasic <= _rentangHarga.end;
      bool matchesRating = _jumlahBintang == 0 || rating >= _jumlahBintang;
      bool matchesService =
          selectedService.isEmpty || selectedService.contains(kategoriName);

      if (matchesPrice && matchesRating && matchesService) {
        result.add(vendor);
      }
    }

    final noFilters =
        _jumlahBintang == 0 &&
        selectedService.isEmpty &&
        _rentangHarga.start == 0 &&
        _rentangHarga.end == 10000000;

    if (noFilters) {
      return result.take(20).toList();
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text("Category Page")),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: const Color.fromARGB(255, 241, 240, 240),
              ),
              width: double.infinity,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    Card(
                      color: Colors.white,
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Filter",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: width > 500 ? 24 : 18,
                              ),
                            ),
                            SizedBox(height: 15),
                            Text(
                              "Rentang Harga",
                              style: TextStyle(fontSize: width > 500 ? 15 : 13),
                            ),
                            Column(
                              children: [
                                RangeSlider(
                                  divisions: 100,
                                  activeColor: const Color.fromARGB(
                                    255,
                                    223,
                                    83,
                                    129,
                                  ),
                                  inactiveColor: const Color.fromARGB(
                                    255,
                                    218,
                                    218,
                                    218,
                                  ),
                                  values: _rentangHarga,
                                  onChanged: (RangeValues values) {
                                    setState(() {
                                      _rentangHarga = values;
                                    });
                                    saveFilterPreferences();
                                  },
                                  min: 0,
                                  max: 10000000,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Rp ${formatPrice(_rentangHarga.start.round())}",
                                      style: TextStyle(
                                        fontSize: width > 500 ? 13 : 11,
                                      ),
                                    ),
                                    Text(
                                      "Rp ${formatPrice(_rentangHarga.end.round())}",
                                      style: TextStyle(
                                        fontSize: width > 500 ? 13 : 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 15),
                            Text(
                              "Rating",
                              style: TextStyle(fontSize: width > 500 ? 15 : 13),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: List.generate(5, (index) {
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _starIsclicked[index] =
                                              !_starIsclicked[index];
                                          _starIsclicked[index]
                                              ? _jumlahBintang++
                                              : _jumlahBintang--;
                                        });
                                        saveFilterPreferences();
                                      },
                                      child: Icon(
                                        Icons.star,
                                        size: 20,
                                        color: _starIsclicked[index]
                                            ? Colors.amber
                                            : Colors.grey,
                                      ),
                                    );
                                  }),
                                ),

                                Text(
                                  _jumlahBintang > 0
                                      ? _jumlahBintang == 5
                                            ? "5 bintang"
                                            : "$_jumlahBintang bintang ke atas"
                                      : "Semua",
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 139, 139, 139),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            ExpansionTile(
                              title: Text(
                                "Jenis Layanan",
                                style: TextStyle(
                                  fontSize: width > 500 ? 15 : 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              tilePadding: EdgeInsets.symmetric(horizontal: 10),
                              childrenPadding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              collapsedShape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(color: Colors.grey.shade300),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(color: Colors.grey.shade300),
                              ),
                              collapsedBackgroundColor: Colors.white,
                              backgroundColor: Colors.white,
                              children: [
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 5,

                                  children: List.generate(_layanan.length, (
                                    index,
                                  ) {
                                    return Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Checkbox(
                                          activeColor: Color.fromARGB(
                                            255,
                                            223,
                                            83,
                                            129,
                                          ),
                                          checkColor: Colors.white,
                                          value: _layananDipilih[index],
                                          onChanged: ((val) {
                                            setState(() {
                                              _layananDipilih[index] = val!;
                                              if (widget.useSavedPreferences) {
                                                saveFilterPreferences();
                                              }
                                            });
                                          }),
                                        ),
                                        Text("${_layanan[index]}"),
                                      ],
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    loading
                        ? const CircularProgressIndicator()
                        : Column(
                            children: filterData().length > 0
                                ? filterData().map((penyedia) {
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => Carddetail(
                                              namaVendor: penyedia.nama,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Card(
                                        elevation: 3,
                                        color: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        clipBehavior: Clip.antiAlias,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Image.network(
                                              penyedia.image,
                                              height: 180,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(
                                                12.0,
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    penyedia.nama,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
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
                                                        "${penyedia.rating}",
                                                        style: const TextStyle(
                                                          fontSize: 13,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Text(
                                                    "Rp ${formatPrice(getBasicPrice(penyedia))}",
                                                    style: const TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.pink,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList()
                                : [
                                    Card(
                                      elevation: 3,
                                      color: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: Container(
                                        width: double.infinity,
                                        height:
                                            MediaQuery.of(context).size.height *
                                            0.6,
                                        child: Center(
                                          child: Text(
                                            "Tidak ada Produk sesuai filter saat ini!",
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                          ),
                    SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ViewAllPage(),
                          ),
                        );
                      },
                      style: ButtonStyle(
                        backgroundColor: const WidgetStatePropertyAll(
                          Color.fromARGB(255, 223, 83, 129),
                        ),
                      ),
                      child: const Text(
                        "Lihat Semua",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
