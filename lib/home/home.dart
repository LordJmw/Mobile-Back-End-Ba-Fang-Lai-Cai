import 'package:flutter/material.dart';
import 'package:projek_uts_mbr/analytics/eventLogs.dart';
import 'package:projek_uts_mbr/helper/localization_helper.dart';
import 'package:projek_uts_mbr/l10n/app_localizations.dart';

import 'package:projek_uts_mbr/services/sessionManager.dart';
import 'package:projek_uts_mbr/main.dart';
import 'package:projek_uts_mbr/auth/loginCostumer.dart';
import 'package:projek_uts_mbr/cardDetail.dart';
import 'package:projek_uts_mbr/category.dart';
import 'package:projek_uts_mbr/databases/vendorDatabase.dart';
import 'package:projek_uts_mbr/model/VendorModel.dart';
import 'dart:convert';

import 'package:projek_uts_mbr/auth/register.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SessionManager _sessionManager = SessionManager();
  final LocalizationHelper _localizationHelper = LocalizationHelper();
  bool _isLoggedIn = false;
  String? _email;
  bool _isLoadingCategories = true;
  List<Map<String, dynamic>> _categories = [];

  @override
  void initState() {
    super.initState();

    _checkLoginStatus();
    Vendordatabase vendordatabase = Vendordatabase();
    vendordatabase.initDataAwal();
    vendordatabase.updatePasswords();
  }

  // Future<void> _loadCategories() async {
  //   try {
  //     final categories = await _localizationHelper.getCategories();
  //     setState(() {
  //       _categories = categories;
  //       _isLoadingCategories = false;
  //     });
  //   } catch (e) {
  //     print('Error loading categories: $e');
  //     // Fallback ke hardcoded jika error
  //     setState(() {
  //       _categories = _getDefaultCategories();
  //       _isLoadingCategories = false;
  //     });
  //   }
  // }

  List<Map<String, dynamic>> getLocalizedCategories(AppLocalizations l10n) {
    return [
      {"icon": Icons.camera_alt_outlined, "label": l10n.categoryPhotography},
      {"icon": Icons.event, "label": l10n.categoryEventOrganizer},
      {"icon": Icons.brush, "label": l10n.categoryMakeupFashion},
      {"icon": Icons.music_note, "label": l10n.categoryEntertainment},
      {"icon": Icons.chair, "label": l10n.categoryDecorVenue},
      {"icon": Icons.restaurant, "label": l10n.categoryCateringFB},
      {"icon": Icons.tv, "label": l10n.categoryTechEventProduction},
      {
        "icon": Icons.local_shipping,
        "label": l10n.categoryTransportationLogistics,
      },
      {"icon": Icons.handshake, "label": l10n.categorySupportServices},
    ];
  }

  // List<Map<String, dynamic>> _getDefaultCategories() {
  //   return [
  //     {"icon": Icons.camera_alt_outlined, "label": "Fotografi &\nVideografi"},
  //     {"icon": Icons.event, "label": "Event Organizer\n& Planner"},
  //     {"icon": Icons.brush, "label": "Makeup &\nFashion"},
  //     {"icon": Icons.music_note, "label": "Entertainment &\nPerformers"},
  //     {"icon": Icons.chair, "label": "Dekorasi &\nVenue"},
  //     {"icon": Icons.restaurant, "label": "Catering &\nF&B"},
  //     {"icon": Icons.tv, "label": "Teknologi &\nProduksi Acara"},
  //     {"icon": Icons.local_shipping, "label": "Transportasi &\nLogistik"},
  //     {"icon": Icons.handshake, "label": "Layanan Pendukung\nLainnya"},
  //   ];
  // }

  Future<void> _checkLoginStatus() async {
    final isLoggedIn = await _sessionManager.isLoggedIn();
    final email = await _sessionManager.getEmail();
    setState(() {
      _isLoggedIn = isLoggedIn;
      _email = email;
    });
  }

  Future<void> _logout() async {
    await _sessionManager.logout();
    _checkLoginStatus();
  }

  Future<List<Vendormodel>> _loadVendors() async {
    Vendordatabase vendordatabase = Vendordatabase();
    List<Vendormodel> allVendors = await vendordatabase.getData();

    // ini nnti apus
    for (var v in allVendors) {
      print("Kategori: ${v.kategori}, jumlah penyedia: ${v.penyedia.length}");
    }

    allVendors.sort(
      (a, b) => b.penyedia.first.rating.compareTo(a.penyedia.first.rating),
    );
    return allVendors.take(8).toList();
  }

  Future<List<Vendormodel>> _loadPortfolios() async {
    Vendordatabase vendordatabase = Vendordatabase();
    List<Vendormodel> allVendors = await vendordatabase.getData();
    return allVendors.take(8).toList();
  }

  Future<List<Vendormodel>> _loadFeeds() async {
    Vendordatabase vendordatabase = Vendordatabase();
    List<Vendormodel> allVendors = await vendordatabase.getData();
    return allVendors.take(8).toList();
  }

  String _getFirstTestimonial(List<Testimoni> testimoniList) {
    if (testimoniList.isEmpty) {
      return "";
    }
    try {
      return testimoniList.first.isi;
    } catch (e) {
      print("Error getting testimoni in home.dart: $e");
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations l10n = AppLocalizations.of(context)!;
    final categories = getLocalizedCategories(l10n);
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: Text(l10n.appTitle), backgroundColor: Colors.pink),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                l10n.bestRatedThisWeek,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 200,
              child: FutureBuilder<List<Vendormodel>>(
                future: _loadVendors(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  final vendors = snapshot.data ?? [];
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: vendors.length,
                    itemBuilder: (context, index) {
                      final vendor = vendors[index];
                      return _buildVendorCard(
                        context,
                        vendor.penyedia.first.nama,
                        "⭐ ${vendor.penyedia.first.rating}",
                        vendor.penyedia.first.image,
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 15),
            const Divider(),
            // ElevatedButton.icon(
            //   onPressed: _logout,
            //   icon: const Icon(Icons.logout),
            //   label: const Text("Logout"),
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: Colors.pink,
            //     foregroundColor: Colors.white,
            //     minimumSize: const Size(double.infinity, 50),
            //   ),
            // ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                "Kategori Vendor",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return _buildCategory(category["icon"], category["label"]);
                },
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  await Eventlogs().LihatHalKategori();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CategoryPage(
                        category: "",
                        useSavedPreferences: true,
                      ),
                    ),
                  );
                },
                child: Text(
                  l10n.viewCategoryPage,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            if (!bool.fromEnvironment('dart.vm.product'))
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            const Divider(),
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                l10n.portfolioAndReview,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 220,
              child: FutureBuilder<List<Vendormodel>>(
                future: _loadPortfolios(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  final portfolios = snapshot.data ?? [];
                  return ListView(
                    scrollDirection: Axis.horizontal,
                    children: portfolios.map((item) {
                      return SizedBox(
                        width: 260,
                        child: _buildPortfolioCard(
                          context,
                          item.penyedia.first.nama,
                          item.penyedia.first.deskripsi,
                          item.penyedia.first.image,
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
            const Divider(),
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                l10n.inspirationAndFeed,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 220,
              child: FutureBuilder<List<Vendormodel>>(
                future: _loadFeeds(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  final feeds = snapshot.data ?? [];
                  return ListView(
                    scrollDirection: Axis.horizontal,
                    children: feeds.map((item) {
                      return SizedBox(
                        width: 300,
                        child: _buildFeedItem(
                          context,
                          item.penyedia.first.nama,
                          _getFirstTestimonial(item.penyedia.first.testimoni),
                          item.penyedia.first.image,
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategory(IconData icon, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pink,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(16),
          ),
          onPressed: () async {
            await Eventlogs().categoryIconButtonClicked(
              label.replaceAll("\n", " "),
              "HomePage",
            );
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CategoryPage(
                  category: label.replaceAll("\n", " "),
                  useSavedPreferences: false,
                ),
              ),
            );
          },
          child: Icon(icon, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  static Widget _buildVendorCard(
    BuildContext context,
    String name,
    String rating,
    String imgPath,
  ) {
    return GestureDetector(
      onTap: () async {
        print("im here bro");
        await Eventlogs().bestInWeek(context, name, rating, imgPath);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Carddetail(namaVendor: name)),
        );
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(left: 16, right: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black12)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Image.network(
                imgPath,
                height: 100,
                width: 160,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(rating),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildPortfolioCard(
    BuildContext context,
    String name,
    String desc,
    String imgPath,
  ) {
    return GestureDetector(
      onTap: () async {
        await Eventlogs().portNReview(context, name, desc, imgPath);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Carddetail(namaVendor: name)),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black12)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: SizedBox(
                height: 100,
                width: double.infinity,
                child: Image.network(imgPath, fit: BoxFit.cover),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(desc, style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildFeedItem(
    BuildContext context,
    String user,
    String text,
    String imgPath,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Carddetail(namaVendor: user)),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              backgroundColor: Colors.pink,
              child: Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(text),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      height: 100,
                      width: double.infinity,
                      child: Image.network(imgPath, fit: BoxFit.cover),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
