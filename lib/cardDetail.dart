import 'package:flutter/material.dart';
import 'package:projek_uts_mbr/databases/vendorDatabase.dart';
import 'package:projek_uts_mbr/helper/semantics.dart';
import 'package:projek_uts_mbr/l10n/app_localizations.dart';
import 'package:projek_uts_mbr/model/VendorModel.dart';
import 'package:projek_uts_mbr/order.dart';
import 'package:projek_uts_mbr/provider/language_provider.dart';
import 'package:provider/provider.dart';

class Carddetail extends StatefulWidget {
  final String namaVendor;
  const Carddetail({super.key, required this.namaVendor});

  @override
  State<Carddetail> createState() => _CarddetailState();
}

class _CarddetailState extends State<Carddetail> {
  Vendormodel? vendor;
  bool loading = true;
  String errorMessage = '';

  String formatPrice(int price) {
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

  Future<void> loadData(String namaVendor, BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      setState(() {
        loading = true;
        errorMessage = '';
      });

      final vendorDb = Vendordatabase();
      final v = await vendorDb.getVendorByName(namaVendor);

      if (v == null) {
        throw Exception(l10n.vendorNotFoundInDatabase);
      }

      setState(() {
        vendor = v;
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
        errorMessage = '${l10n.failedToLoadVendor}: $e';
      });
    }
  }

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      loadData(widget.namaVendor, context);
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context).locale;
    final l10n = AppLocalizations.of(context)!;

    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (errorMessage.isNotEmpty) {
      return Scaffold(body: Center(child: Text(errorMessage)));
    }

    final harga = vendor!.penyedia.first.harga;
    final testimoniList = vendor!.penyedia.first.testimoni;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 241, 240, 240),
      appBar: AppBar(title: Text(l10n.vendorDetails), centerTitle: true),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 180,
                    color: Colors.grey[300],
                    child: Image.network(
                      vendor!.penyedia.first.image,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.image, size: 60),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Semantics(
                      excludeSemantics: true,
                      container: true,
                      label: tr(
                        'textButton', 
                        'detailVendor',
                        lang,
                        params: {
                          "name1" : vendor!.penyedia.first.nama, 
                          "name2": vendor!.penyedia.first.rating.toStringAsFixed(1), 
                          "name3":'${testimoniList.length}'}),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 36,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: NetworkImage(
                              vendor!.penyedia.first.image,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  vendor!.penyedia.first.nama,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
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
                                      "${vendor!.penyedia.first.rating.toStringAsFixed(1)} (${testimoniList.length} ulasan)",
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
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Semantics(
                      excludeSemantics: true,
                      container: true,
                      label:
                          tr(
                            'textButton',
                            'deskripsiVendorCard', 
                            lang, 
                            params: {
                              "name1" : vendor!.penyedia.first.nama.split(" ").first,
                              "name2":"${vendor!.penyedia.first.deskripsi}"}),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${l10n.about} ${vendor!.penyedia.first.nama.split(" ").first}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            vendor!.penyedia.first.deskripsi.isNotEmpty
                                ? vendor!.penyedia.first.deskripsi
                                : l10n.noDescriptionForVendor,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Semantics(
                            excludeSemantics: true,
                            container: true,
                            label: tr('button', 'orderNow', lang),
                            child: ElevatedButton(
                              onPressed: () {
                                if (harga.basic.harga == 0 &&
                                    harga.premium.harga == 0 &&
                                    harga.custom.harga == 0) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: Colors.red,
                                      content: Text(
                                        l10n.packagesDeletedByVendor,
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => OrderPage(
                                      namaVendor: widget.namaVendor,
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  223,
                                  83,
                                  129,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              child: Text(
                                l10n.orderNow,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Semantics(
                            excludeSemantics: true,
                            container: true,
                            label: tr('button', 'hubungiB', lang),
                            child: OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.pink,
                                side: const BorderSide(color: Colors.pink),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              child: Text(
                                l10n.contact,
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            _buildPaketCard(
              "Basic",
              harga.basic.harga,
              harga.basic.jasa,
              context,
            ),
            _buildPaketCard(
              "Premium",
              harga.premium.harga,
              harga.premium.jasa,
              context,
            ),
            _buildPaketCard(
              "Custom",
              harga.custom.harga,
              harga.custom.jasa,
              context,
            ),
            if (testimoniList.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.clientReviews,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...testimoniList.map((ulasan) {
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
                                              ulasan.nama,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Row(
                                              children: List.generate(
                                                5,
                                                (index) => Icon(
                                                  index < ulasan.rating
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
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    ulasan.isi,
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

  Widget _buildPaketCard(
    String tipe,
    int harga,
    String jasa,
    BuildContext context,
  ) {
    final lang = Provider.of<LanguageProvider>(context).locale;
    final jasaList = jasa.split(",");
    final l10n = AppLocalizations.of(context)!;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              tipe,
              style: const TextStyle(
                color: Colors.pink,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Rp ${formatPrice(harga)}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
            Text(l10n.perEvent),
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: jasaList.map((j) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check, color: Colors.green),
                    const SizedBox(width: 5),
                    Expanded(child: Text(j.trim())),
                  ],
                );
              }).toList(),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: Semantics(
                excludeSemantics: true,
                container: true,
                label: tr('button', 'pilihPaket', lang),
                child: ElevatedButton(
                  onPressed: () {
                    if (harga == 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.red,
                          content: Text(l10n.packagesDeletedByVendor),
                        ),
                      );
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderPage(
                          namaVendor: widget.namaVendor,
                          paketDipilih: tipe,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 223, 83, 129),
                  ),
                  child: Text(
                    l10n.selectPackage,
                    style: TextStyle(color: Colors.white),
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
