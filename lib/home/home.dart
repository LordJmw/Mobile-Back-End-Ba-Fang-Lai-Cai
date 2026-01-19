import 'package:flutter/material.dart';
import 'package:projek_uts_mbr/analytics/eventLogs.dart';
import 'package:projek_uts_mbr/helper/localization_helper.dart';
import 'package:projek_uts_mbr/helper/semantics.dart';
import 'package:projek_uts_mbr/l10n/app_localizations.dart';
import 'package:projek_uts_mbr/provider/language_provider.dart';
import 'package:projek_uts_mbr/services/sessionManager.dart';
import 'package:projek_uts_mbr/category/category_consts.dart';
import 'package:projek_uts_mbr/main.dart';
import 'package:projek_uts_mbr/cardDetail.dart';
import 'package:projek_uts_mbr/category/category.dart';
import 'package:projek_uts_mbr/databases/vendorDatabase.dart';
import 'package:projek_uts_mbr/model/VendorModel.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

List<Vendormodel> sortVendorByRating(List<Vendormodel> vendors) {
  vendors.sort(
    (a, b) => b.penyedia.first.rating.compareTo(a.penyedia.first.rating),
  );
  return vendors.take(8).toList();
}

List<Vendormodel> loadPortFeedsCompute(List<Vendormodel> vendors) {
  return vendors.take(8).toList();
}

class HomePage extends StatefulWidget {
  final Future<R> Function<Q, R>(ComputeCallback<Q, R>, Q) computeFunc;
  const HomePage({super.key, this.computeFunc = compute});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late SessionManager _sessionManager;
  final LocalizationHelper _localizationHelper = LocalizationHelper();
  Vendordatabase? _vendordatabase;

  bool _isLoggedIn = false;
  String? _email;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_vendordatabase == null) {
      _vendordatabase = Provider.of<Vendordatabase>(context);
      _vendordatabase!.initDataAwal();
      _vendordatabase!.updatePasswords();
    }
    _sessionManager = Provider.of<SessionManager>(context);
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final isLoggedIn = await _sessionManager.isLoggedIn();
    final email = await _sessionManager.getEmail();
    setState(() {
      _isLoggedIn = isLoggedIn;
      _email = email;
    });
  }

  Future<List<Vendormodel>> _loadVendors() async {
    List<Vendormodel> allVendors = await _vendordatabase!.getData();

    return widget.computeFunc(sortVendorByRating, allVendors);
  }

  Future<List<Vendormodel>> _loadPortfolios() async {
    List<Vendormodel> allVendors = await _vendordatabase!.getData();
    return widget.computeFunc(loadPortFeedsCompute, allVendors);
  }

  Future<List<Vendormodel>> _loadFeeds() async {
    List<Vendormodel> allVendors = await _vendordatabase!.getData();
    return widget.computeFunc(loadPortFeedsCompute, allVendors);
  }

  String _getFirstTestimonial(List<Testimoni> list) {
    if (list.isEmpty) return "";
    try {
      return list.first.isi;
    } catch (_) {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context).locale;
    final l10n = AppLocalizations.of(context)!;

    final categories = CategoryConst.getLocalizedCategories(l10n);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: Text(l10n.appTitle), backgroundColor: Colors.pink),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n.bestRatedThisWeek,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            SizedBox(
              height: 200,
              child: FutureBuilder<List<Vendormodel>>(
                future: _loadVendors(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final vendors = snapshot.data!;
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: vendors.length,
                    itemBuilder: (context, index) {
                      final vendor = vendors[index];
                      return Semantics(
                        label: tr(
                          'button',
                          'vendorCardLabel',
                          lang,
                          params: {
                            "name1": vendor.penyedia.first.nama,
                            "name2": '${vendor.penyedia.first.rating}',
                          },
                        ),
                        hint: tr(
                          'button',
                          'vendorCardHint',
                          lang,
                          params: {"name": vendor.penyedia.first.nama},
                        ),
                        child: _buildVendorCard(
                          context,
                          vendor.penyedia.first.nama,
                          "⭐ ${vendor.penyedia.first.rating}",
                          vendor.penyedia.first.image,
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            const Divider(),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n.categoryVendor,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  return _buildCategory(
                    cat['icon'],
                    cat['label'],
                    cat['code'],
                    lang,
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            Center(
              child: Semantics(
                label: tr('button', 'viewAllKategoriButtonLabel', lang),
                hint: tr('button', 'viewAllKategoriButtonHint', lang),
                excludeSemantics: true,
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
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            const Divider(),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n.portfolioAndReview,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            SizedBox(
              height: 220,
              child: FutureBuilder<List<Vendormodel>>(
                future: _loadPortfolios(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final portfolios = snapshot.data!;
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
                          lang,
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),

            const Divider(),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n.inspirationAndFeed,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            SizedBox(
              height: 220,
              child: FutureBuilder<List<Vendormodel>>(
                future: _loadFeeds(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final feeds = snapshot.data!;
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
                          lang,
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

  Widget _buildCategory(IconData icon, String label, String code, Locale lang) {
    return Semantics(
      label: tr('button', 'kategoriButtonLabel', lang, params: {"name": label}),
      hint: tr('button', 'kategoriButtonHint', lang, params: {"name": label}),
      excludeSemantics: true,
      child: SizedBox(
        width: 90,
        child: Column(
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
                await Eventlogs().categoryIconButtonClicked(label, "HomePage");
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CategoryPage(
                      category: code,
                      useSavedPreferences: false,
                    ),
                  ),
                );
              },
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
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
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Image.network(
                imgPath,
                key: const Key('vendorCardImage'),
                height: 100,
                width: 160,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
              child: Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: Text(rating, key: const Key('vendorCardRating')),
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
    Locale lang,
  ) {
    return Semantics(
      label: tr(
        'button',
        'portofolioCardLabel',
        lang,
        params: {"name1": name, "name2": desc},
      ),
      hint: tr('button', 'portofolioCardHint', lang, params: {"name": name}),
      excludeSemantics: true,
      child: GestureDetector(
        onTap: () async {
          await Eventlogs().portNReview(context, name, desc, imgPath);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Carddetail(namaVendor: name),
            ),
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
            mainAxisSize: MainAxisSize.min,
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
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      desc,
                      style: const TextStyle(fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildFeedItem(
    BuildContext context,
    String user,
    String text,
    String imgPath,
    Locale lang,
  ) {
    return Semantics(
      label:
          tr('button', 'komentarCardLabel', lang, params: {"name": user}) +
          text,
      hint: tr('button', 'komentarCardHint', lang, params: {"name": user}),
      excludeSemantics: true,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Carddetail(namaVendor: user),
            ),
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
      ),
    );
  }
}
