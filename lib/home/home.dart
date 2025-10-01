import 'package:flutter/material.dart';
import 'package:projek_uts_mbr/category.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.clear();
                      print("Preferences cleared!");
                    },
                    child: Text("Clear Prefs"),
                  ),
                  _buildVendorCard(
                    "Studio Photo A",
                    "⭐ 4.9",
                    "https://www.techmadeplain.com/img/2014/300x200.png",
                  ),
                  _buildVendorCard(
                    "EO WeddingX",
                    "⭐ 4.8",
                    "https://www.techmadeplain.com/img/2014/300x200.png",
                  ),
                  _buildVendorCard(
                    "Catering Lezat",
                    "⭐ 4.7",
                    "https://www.techmadeplain.com/img/2014/300x200.png",
                  ),
                ],
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
                          ), // ke halaman kategori
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
            _buildPortfolioCard(
              "Dekorasi Garden Party",
              "Dekorasi outdoor dengan konsep elegan dan lampu gantung.",
              "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQuRPz1VrZVdyXSeYIUeB2jEZXcTrLTPxeByA&s",
            ),
            _buildPortfolioCard(
              "Makeup Wisuda",
              "Natural makeup untuk momen wisuda, hasil flawless.",
              "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQuRPz1VrZVdyXSeYIUeB2jEZXcTrLTPxeByA&s",
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
            _buildFeedItem(
              "Studio Photo A",
              "Baru saja handle acara ulang tahun ke-17, hasil fotonya super keren!",
              "https://www.membergate.com/members/images/3559b.png",
            ),
            _buildFeedItem(
              "EO WeddingX",
              "Wedding outdoor ala Bali vibes 🌴✨",
              "https://www.membergate.com/members/images/3559b.png",
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
  static Widget _buildVendorCard(String name, String rating, String imgPath) {
    return Container(
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
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
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
    );
  }

  // --- Widget Portfolio Card ---
  static Widget _buildPortfolioCard(String title, String desc, String imgPath) {
    return Container(
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
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              imgPath,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
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
    );
  }

  // --- Widget Feed ---
  static Widget _buildFeedItem(String user, String text, String imgPath) {
    return Container(
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
                Text(user, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(text),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imgPath,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
