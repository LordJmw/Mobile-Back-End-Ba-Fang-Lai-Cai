import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:projek_uts_mbr/analytics/eventLogs.dart';
import 'package:projek_uts_mbr/cardDetail.dart';
import 'package:projek_uts_mbr/category/category_consts.dart';
import 'package:projek_uts_mbr/databases/vendorDatabase.dart';
import 'package:projek_uts_mbr/helper/semantics.dart';
import 'package:projek_uts_mbr/l10n/app_localizations.dart';
import 'package:projek_uts_mbr/model/VendorModel.dart';
import 'package:projek_uts_mbr/provider/language_provider.dart';
import 'package:projek_uts_mbr/services/dataServices.dart';
import 'package:projek_uts_mbr/viewall.dart';
import 'package:provider/provider.dart';
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

  List<String> getLocalizedCategories(AppLocalizations l10n) {
    return [
      l10n.categoryPhotography.replaceAll("\n", " "),
      l10n.categoryEventOrganizer.replaceAll("\n", " "),
      l10n.categoryMakeupFashion.replaceAll("\n", " "),
      l10n.categoryEntertainment.replaceAll("\n", " "),
      l10n.categoryDecorVenue.replaceAll("\n", " "),
      l10n.categoryCateringFB.replaceAll("\n", " "),
      l10n.categoryTechEventProduction.replaceAll("\n", " "),
      l10n.categoryTransportationLogistics.replaceAll("\n", " "),
      l10n.categorySupportServices.replaceAll("\n", " "),
    ];
  }

  List<String> _layanan = [];
  List<String> tapppedCategory = [];
  List<dynamic> data = [];
  bool loading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _layanan = getLocalizedCategories(l10n);
    });
  }

  @override
  void initState() {
    super.initState();
    Vendordatabase vendordatabase = Vendordatabase();
    vendordatabase.getData().then((res) async {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        data = res;
        loading = false;
      });
      final l10n = AppLocalizations.of(context)!;

      //useSavedPreferences artinya user klik kategori spesifik
      if (!widget.useSavedPreferences && widget.category.isNotEmpty) {
        print("MODE KATEGORI SPESIFIK");
        print("Category code: ${widget.category}");
        // untuk apa user sudah pernah menyetel filter sebelumnya
        final savedCategories =
            prefs.getStringList("${_preferencesKey}_category") ?? [];
        print("Saved categories from preferences: $savedCategories");
        if (savedCategories.isEmpty) {
          // kalau pertama kali, set kategori jadi ini
          await _initializeCategoryFilter(widget.category, l10n, prefs);
        } else {
          //kalau sudah pernah, ambil dari sharedPreferences
          await _loadFromPreferences(prefs, l10n);
        }
      } else {
        //kalau user click tombol view Category Page di home(lihat semua kategori)
        print("MODE VIEW ALL");
        await _loadFromPreferences(prefs, l10n);
      }
      setState(() {});
    });
  }

  //inisialisasi untuk filter kategori
  Future<void> _initializeCategoryFilter(
    String categoryCode,
    AppLocalizations l10n,
    SharedPreferences prefs,
  ) async {
    print("Initializing category filter for: $categoryCode");
    //untuk get nama lokal kategori(inggris/indo)
    String localizedCategoryName = "";
    try {
      final dbLabel = CategoryConst.codeToDbLabel[categoryCode];
      if (dbLabel != null) {
        localizedCategoryName = _convertDbLabelToLocalized(dbLabel, l10n);
      } else {
        localizedCategoryName = CategoryConst.codeToLocalizedLabel(
          categoryCode,
          l10n,
        ).replaceAll("\n", " ");
      }
    } catch (e) {
      print("Error converting category: $e");
      localizedCategoryName = categoryCode;
    }
    print("Localized name: $localizedCategoryName");

    //reset agar kategori yang tidak terpilih tidak dicentang
    for (var i = 0; i < _layananDipilih.length; i++) {
      _layananDipilih[i] = false;
    }

    // Centang hanya kategori yang dipilih
    final categoryIndex = _layanan.indexWhere(
      (item) =>
          item.toLowerCase().contains(localizedCategoryName.toLowerCase()) ||
          localizedCategoryName.toLowerCase().contains(item.toLowerCase()),
    );
    if (categoryIndex != -1) {
      _layananDipilih[categoryIndex] = true;
      tapppedCategory = [localizedCategoryName];
      print("Category found at index: $categoryIndex");
    }

    // Set default values untuk filter lainnya
    _rentangHarga = RangeValues(0, 10000000);
    _jumlahBintang = 0;
    for (int i = 0; i < _starIsclicked.length; i++) {
      _starIsclicked[i] = false;
    }

    // Simpan ke preferences
    await saveFilterPreferences();
  }

  // Method untuk load filter dari preferences
  Future<void> _loadFromPreferences(
    SharedPreferences prefs,
    AppLocalizations l10n,
  ) async {
    print("Loading from preferences with key: ${_preferencesKey}");
    // Load kategori yang dipilih
    tapppedCategory = prefs.getStringList("${_preferencesKey}_category") ?? [];
    print("Loaded categories: $tapppedCategory");

    // Update _layananDipilih berdasarkan loaded categories
    for (var i = 0; i < _layanan.length; i++) {
      _layananDipilih[i] = tapppedCategory.contains(_layanan[i]);
    }

    // Load rentang harga
    _rentangHarga = RangeValues(
      prefs.getDouble("${_preferencesKey}_price_min") ?? 0,
      prefs.getDouble("${_preferencesKey}_price_max") ?? 10000000,
    );

    // Load rating
    _jumlahBintang = prefs.getInt("${_preferencesKey}_rating") ?? 0;
    for (int i = 0; i < _starIsclicked.length; i++) {
      _starIsclicked[i] = i < _jumlahBintang;
    }
  }

  // Helper method untuk konversi dbLabel ke localized name
  String _convertDbLabelToLocalized(String dbLabel, AppLocalizations l10n) {
    switch (dbLabel) {
      case "Fotografi & Videografi":
        return l10n.categoryPhotography.replaceAll("\n", " ");
      case "Event Organizer & Planner":
        return l10n.categoryEventOrganizer.replaceAll("\n", " ");
      case "Makeup & Fashion":
        return l10n.categoryMakeupFashion.replaceAll("\n", " ");
      case "Entertainment & Performers":
        return l10n.categoryEntertainment.replaceAll("\n", " ");
      case "Dekorasi & Venue":
        return l10n.categoryDecorVenue.replaceAll("\n", " ");
      case "Catering & F&B":
        return l10n.categoryCateringFB.replaceAll("\n", " ");
      case "Teknologi & Produksi Acara":
        return l10n.categoryTechEventProduction.replaceAll("\n", " ");
      case "Transportasi & Logistik":
        return l10n.categoryTransportationLogistics.replaceAll("\n", " ");
      case "Layanan Pendukung Lainnya":
        return l10n.categorySupportServices.replaceAll("\n", " ");
      default:
        return dbLabel;
    }
  }

  //kalau dari home tombol view category page maka global
  String get _preferencesKey {
    if (widget.useSavedPreferences) {
      return "global_filter";
    } else {
      return "category_${widget.category}";
    }
  }

  Future<void> saveFilterPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final selectedService = _layanan
        .asMap()
        .entries
        .where((entry) => _layananDipilih[entry.key])
        .map((entry) => entry.value)
        .toList();

    print("Saving preferences with key: ${_preferencesKey}");
    print("Selected services to save: $selectedService");
    print("Price range to save: ${_rentangHarga.start} - ${_rentangHarga.end}");
    print("Rating to save: $_jumlahBintang");

    await prefs.setStringList("${_preferencesKey}_category", selectedService);
    await prefs.setDouble("${_preferencesKey}_price_min", _rentangHarga.start);
    await prefs.setDouble("${_preferencesKey}_price_max", _rentangHarga.end);
    await prefs.setInt("${_preferencesKey}_rating", _jumlahBintang);

    // Update tapppedCategory untuk konsistensi
    tapppedCategory = selectedService;
  }

  Future<SharedPreferences> getSharedPrefsInstance() async {
    return await SharedPreferences.getInstance();
  }

  List<Penyedia> filterData() {
    final selectedService = _layanan
        .asMap()
        .entries
        .where((entry) => _layananDipilih[entry.key])
        .map((entry) => entry.value)
        .toList();

    print("FILTER DATA");
    print("Selected services: $selectedService");
    print("Tapped category: $tapppedCategory");
    print("Layanan dipilih: $_layananDipilih");
    print("All available categories in _layanan:");
    for (int i = 0; i < _layanan.length; i++) {
      print(" [$i] ${_layanan[i]} - checked: ${_layananDipilih[i]}");
    }

    List<Penyedia> result = [];
    for (var vendorModel in data) {
      for (var penyedia in vendorModel.penyedia) {
        final kategoriName =
            vendorModel.kategori; // dbLabel (misal: "Fotografi & Videografi")
        final hargaBasic = penyedia.harga.basic.harga;
        final rating = penyedia.rating;

        bool matchesPrice =
            hargaBasic >= _rentangHarga.start &&
            hargaBasic <= _rentangHarga.end;
        bool matchesRating = _jumlahBintang == 0 || rating >= _jumlahBintang;

        // Konversi kategori vendor (dbLabel) ke localized name
        String vendorLocalizedCategory = "";
        try {
          vendorLocalizedCategory = _convertDbLabelToLocalized(
            kategoriName,
            AppLocalizations.of(context)!,
          );
        } catch (e) {
          print("Error converting vendor category: $e");
          vendorLocalizedCategory = kategoriName;
        }

        // Cek apakah kategori vendor termasuk dalam yang dipilih
        bool matchesService =
            selectedService.isEmpty ||
            selectedService.any((selectedLabel) {
              bool isMatch = selectedLabel == vendorLocalizedCategory;
              if (isMatch) {
                print("MATCH FOUND!");
                print(" Selected: $selectedLabel");
                print(" Vendor DB: $kategoriName");
                print(" Vendor Localized: $vendorLocalizedCategory");
              }
              return isMatch;
            });

        if (matchesPrice && matchesRating && matchesService) {
          result.add(penyedia);
        }
      }
    }
    print("Total hasil filter: ${result.length}");
    print("\n");

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

  void resetToCategoryOnly(String categoryCode) async {
    final prefs = await SharedPreferences.getInstance();
    final l10n = AppLocalizations.of(context)!;

    // Reset semua filter
    for (var i = 0; i < _layananDipilih.length; i++) {
      _layananDipilih[i] = false;
    }

    // Set hanya kategori yang dipilih
    final localizedName = CategoryConst.codeToLocalizedName(categoryCode, l10n);
    final categoryIndex = _layanan.indexWhere((item) => item == localizedName);
    if (categoryIndex != -1) {
      _layananDipilih[categoryIndex] = true;
    }

    // Reset filter lainnya
    _rentangHarga = RangeValues(0, 10000000);
    _jumlahBintang = 0;
    for (int i = 0; i < _starIsclicked.length; i++) {
      _starIsclicked[i] = false;
    }

    // Clear saved preferences untuk kategori ini
    await prefs.remove("${_preferencesKey}_category");
    await prefs.remove("${_preferencesKey}_price_min");
    await prefs.remove("${_preferencesKey}_price_max");
    await prefs.remove("${_preferencesKey}_rating");

    // Save new preferences
    saveFilterPreferences();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context).locale;
    final l10n = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;
    final width = size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text(l10n.categoryPage)),
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
                              l10n.filter,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: width > 500 ? 24 : 18,
                              ),
                            ),
                            SizedBox(height: 15),
                            SizedBox(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Semantics(
                                    container: true,
                                    label: l10n.priceRange,
                                    child: Text(
                                      l10n.priceRange,
                                      style: TextStyle(
                                        fontSize: width > 500 ? 15 : 13,
                                      ),
                                    ),
                                  ),
                                  Semantics(
                                    container: true,
                                    label: tr(
                                      'filter',
                                      'rentangHargaLabel',
                                      lang,
                                    ),
                                    hint: tr(
                                      'filter',
                                      'rentangHargaHint',
                                      lang,
                                    ),
                                    value:
                                        "Rp ${formatPrice(_rentangHarga.start.round())} sampai Rp ${formatPrice(_rentangHarga.end.round())}",
                                    child: Column(
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
                                          onChanged:
                                              (RangeValues values) async {
                                                setState(() {
                                                  _rentangHarga = values;
                                                });
                                                saveFilterPreferences();
                                                await Eventlogs().HargaFilter(
                                                  values,
                                                );
                                              },
                                          min: 0,
                                          max: 10000000,

                                          semanticFormatterCallback:
                                              (double newValue) {
                                                return "Rp ${formatPrice(newValue.round())}";
                                              },
                                        ),

                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Semantics(
                                              label: tr(
                                                'filter',
                                                'hargaMinimumLabel',
                                                lang,
                                              ),
                                              hint: tr(
                                                'filter',
                                                'hargaMinimumHint',
                                                lang,
                                              ),
                                              value:
                                                  "Rp ${formatPrice(_rentangHarga.start.round())}",
                                              child: Text(
                                                "Rp ${formatPrice(_rentangHarga.start.round())}",
                                                style: TextStyle(
                                                  fontSize: width > 500
                                                      ? 13
                                                      : 11,
                                                ),
                                              ),
                                            ),
                                            Semantics(
                                              label: tr(
                                                'filter',
                                                'hargaMaksimumLabel',
                                                lang,
                                              ),
                                              hint: tr(
                                                'filter',
                                                'hargaMaksimumHint',
                                                lang,
                                              ),
                                              value:
                                                  "Rp ${formatPrice(_rentangHarga.end.round())}",
                                              child: Text(
                                                "Rp ${formatPrice(_rentangHarga.end.round())}",
                                                style: TextStyle(
                                                  fontSize: width > 500
                                                      ? 13
                                                      : 11,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 15),
                            Text(
                              l10n.ratingFilter,
                              style: TextStyle(fontSize: width > 500 ? 15 : 13),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Semantics untuk keseluruhan rating bintang
                                Semantics(
                                  label: tr(
                                    'filter',
                                    'ratingLabel',
                                    lang,
                                  ), // contoh: "Filter rating"
                                  hint: tr(
                                    'filter',
                                    'ratingHint',
                                    lang,
                                  ), // contoh: "Ketuk bintang untuk memilih rating"
                                  value: "${_jumlahBintang} bintang dipilih",
                                  child: Row(
                                    children: List.generate(5, (index) {
                                      return Semantics(
                                        label: "Bintang ${index + 1}",
                                        hint: _starIsclicked[index]
                                            ? "Ketuk untuk membatalkan bintang"
                                            : "Ketuk untuk memilih bintang",
                                        toggled: _starIsclicked[index],
                                        button: true,
                                        child: GestureDetector(
                                          onTap: () async {
                                            setState(() {
                                              _starIsclicked[index] =
                                                  !_starIsclicked[index];
                                              _starIsclicked[index]
                                                  ? _jumlahBintang++
                                                  : _jumlahBintang--;
                                            });
                                            saveFilterPreferences();
                                            await Eventlogs().ratingFilter(
                                              _jumlahBintang,
                                            );
                                          },
                                          child: Icon(
                                            Icons.star,
                                            size: 20,
                                            color: _starIsclicked[index]
                                                ? Colors.amber
                                                : Colors.grey,
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                                // Semantics untuk teks hasil rating
                                Semantics(
                                  label: tr('filter', 'hasilRatingLabel', lang),
                                  hint: tr('filter', 'hasilRatingHint', lang),
                                  value: _jumlahBintang > 0
                                      ? "${_jumlahBintang} bintang atau lebih"
                                      : "Semua rating",
                                  child: Text(
                                    _jumlahBintang > 0
                                        ? _jumlahBintang == 5
                                              ? l10n.fiveStars
                                              : "${l10n.starsAndAbove(_jumlahBintang)}"
                                        : l10n.allRatings,
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 139, 139, 139),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            ExpansionTile(
                              title: Semantics(
                                label: tr('filter', 'jenisLayananLabel', lang),
                                hint: tr('filter', 'jenisLayananHint', lang),
                                button: true,
                                child: Text(
                                  l10n.serviceType,
                                  style: TextStyle(
                                    fontSize: width > 500 ? 15 : 13,
                                    fontWeight: FontWeight.w500,
                                  ),
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
                                    return Semantics(
                                      label: _layanan[index],
                                      hint: _layananDipilih[index]
                                          ? "Ketuk untuk membatalkan pilihan kategori"
                                          : "Ketuk untuk memilih kategori",
                                      toggled: _layananDipilih[index],
                                      button: true,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Checkbox(
                                            activeColor: const Color.fromARGB(
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
                                                if (widget
                                                    .useSavedPreferences) {
                                                  saveFilterPreferences();
                                                }
                                              });
                                            }),
                                          ),
                                          Text(_layanan[index]),
                                        ],
                                      ),
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
                            children: filterData().isNotEmpty
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
                                        child: Semantics(
                                          excludeSemantics: true,
                                          label: trDetail(
                                            'button',
                                            'kategoriCard',
                                            lang,
                                            penyedia.nama,
                                            '${penyedia.rating}',
                                            '${formatPrice(getBasicPrice(penyedia))}',
                                          ),
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
                                                        const SizedBox(
                                                          width: 4,
                                                        ),
                                                        Text(
                                                          "${penyedia.rating}",
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 13,
                                                                color:
                                                                    Colors.grey,
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
                                            l10n.noProductsMatchFilter,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                          ),
                    SizedBox(height: 15),
                    Semantics(
                      label: tr('button', 'viewAllKategoriButtonLabel', lang),
                      hint: tr('button', 'viewAllKategoriButtonHint', lang),
                      button: true,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ViewAllPage(),
                            ),
                          );
                        },
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(
                            Color.fromARGB(255, 223, 83, 129),
                          ),
                        ),
                        child: Text(
                          l10n.viewAll,
                          style: TextStyle(color: Colors.white),
                        ),
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
