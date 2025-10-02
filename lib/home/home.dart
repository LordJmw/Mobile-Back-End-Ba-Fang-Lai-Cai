import 'package:flutter/material.dart';
import 'package:projek_uts_mbr/cardDetail.dart';
import 'package:projek_uts_mbr/category.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, dynamic>> _categories = [
    {"icon": Icons.camera_alt_outlined, "label": "Fotografi &\nVideografi"},
    {"icon": Icons.event, "label": "Event Organizer\n& Planner"},
    {"icon": Icons.brush, "label": "Makeup &\nFashion"},
    {"icon": Icons.music_note, "label": "Entertainment &\nPerformers"},
    {"icon": Icons.chair, "label": "Dekorasi &\nVenue"},
    {"icon": Icons.restaurant, "label": "Catering &\nF&B"},
    {"icon": Icons.tv, "label": "Teknologi &\nProduksi Acara"},
    {"icon": Icons.local_shipping, "label": "Transportasi &\nLogistik"},
    {"icon": Icons.handshake, "label": "Layanan Pendukung\nLainnya"},
  ];

  Future<List<Map<String, dynamic>>> _loadPortfolios() async {
    final String jsonString = await rootBundle.loadString('assets/data.json');
    final List<dynamic> jsonData = json.decode(jsonString);

    List<Map<String, dynamic>> portfolios = [];
    for (var kategori in jsonData) {
      if (kategori['penyedia'] != null) {
        for (var penyedia in kategori['penyedia']) {
          portfolios.add({
            'title': penyedia['nama'] ?? '',
            'desc': penyedia['deskripsi'] ?? '',
            'imgUrl': penyedia['image'] ?? '',
          });
        }
      }
    }
    return portfolios.take(8).toList();
  }

  Future<List<Map<String, dynamic>>> _loadFeeds() async {
    final String jsonString = await rootBundle.loadString('assets/data.json');
    final List<dynamic> jsonData = json.decode(jsonString);

    List<Map<String, dynamic>> feeds = [];
    for (var kategori in jsonData) {
      if (kategori['penyedia'] != null) {
        for (var penyedia in kategori['penyedia']) {
          feeds.add({
            'user': penyedia['nama'] ?? '',
            'text':
                penyedia['testimoni'] != null &&
                        penyedia['testimoni'].isNotEmpty
                    ? penyedia['testimoni'][0]['isi']
                    : '',
            'imgUrl': penyedia['image'] ?? '',
          });
        }
      }
    }
    return feeds.take(8).toList();
  }

  Future<List<Map<String, dynamic>>> _loadVendors() async {
    final String jsonString = await rootBundle.loadString('assets/data.json');
    final List<dynamic> jsonData = json.decode(jsonString);

    List<Map<String, dynamic>> allVendors = [];
    for (var kategori in jsonData) {
      if (kategori['penyedia'] != null) {
        for (var penyedia in kategori['penyedia']) {
          allVendors.add({
            'name': penyedia['nama'] ?? '',
            'rating': '⭐ ${penyedia['rating']?.toStringAsFixed(1) ?? ''}',
            'imgUrl': penyedia['image'] ?? '',
          });
        }
      }
    }

    allVendors.sort((a, b) {
      double ratingA = double.tryParse(a['rating'].replaceAll('⭐ ', '')) ?? 0.0;
      double ratingB = double.tryParse(b['rating'].replaceAll('⭐ ', '')) ?? 0.0;
      return ratingB.compareTo(ratingA);
    });

    return allVendors.take(8).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Home Page"),
        backgroundColor: Colors.pink,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.pink,
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: Colors.pink),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {},
            child: const Text("Masuk"),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {},
            child: const Text("Daftar"),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                "Rating Terbaik Minggu ini!",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 200,
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _loadVendors(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  final vendors = snapshot.data ?? [];
                  return ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      // ElevatedButton(
                      //   onPressed: () async {
                      //     final prefs = await SharedPreferences.getInstance();
                      //     await prefs.clear();
                      //     print("Preferences cleared!");
                      //   },
                      //   child: Text("Clear Prefs"),
                      // ),
                      ...vendors.map(
                        (vendor) => _buildVendorCard(
                          context,
                          vendor['name'] ?? '',
                          vendor['rating'] ?? '',
                          vendor['imgUrl'] ?? '',
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            SizedBox(height: 15),

            const Divider(),

            // --- KATEGORI VENDOR ---
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
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final category = _categories[index];
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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => const CategoryPage(
                            category: "",
                            useSavedPreferences: true,
                          ),
                    ),
                  );
                },
                child: const Text(
                  "Lihat Halaman Kategori",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const Divider(),

            // --- PORTOFOLIO & REVIEW ---
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                "Portofolio & Review",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 220,
              child: FutureBuilder<List<Map<String, dynamic>>>(
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
                    children:
                        portfolios
                            .map(
                              (item) => SizedBox(
                                width: 260,
                                child: _buildPortfolioCard(
                                  context,
                                  item['title'] ?? '',
                                  item['desc'] ?? '',
                                  item['imgUrl'] ?? '',
                                ),
                              ),
                            )
                            .toList(),
                  );
                },
              ),
            ),

            const Divider(),

            // --- FEED / INSPIRASI ---
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                "Inspirasi & Feed",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 220,
              child: FutureBuilder<List<Map<String, dynamic>>>(
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
                    children:
                        feeds
                            .map(
                              (item) => SizedBox(
                                width: 300,
                                child: _buildFeedItem(
                                  context,
                                  item['user'] ?? '',
                                  item['text'] ?? '',
                                  item['imgUrl'] ?? '',
                                ),
                              ),
                            )
                            .toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Widget Kategori ---
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
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => CategoryPage(
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

  // --- Widget Vendor Card ---
  static Widget _buildVendorCard(
    BuildContext context,
    String name,
    String rating,
    String imgPath,
  ) {
    return GestureDetector(
      onTap: () {
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

  // --- Widget Portfolio Card ---
  static Widget _buildPortfolioCard(
    BuildContext context,
    String name,
    String desc,
    String imgPath,
  ) {
    return GestureDetector(
      onTap: () {
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

  // --- Widget Feed ---
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
