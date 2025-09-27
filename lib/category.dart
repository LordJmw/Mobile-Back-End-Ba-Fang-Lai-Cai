import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

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

Future<List<dynamic>> loadData() async {
  final String response = await rootBundle.loadString('assets/data.json');
  final data = await json.decode(response);
  print(data);
  return data;
}

class _CategoryPageState extends State<CategoryPage> {
  RangeValues _rentangHarga = RangeValues(0, 10000000);
  List<bool> _starIsclicked = [false, false, false, false, false];
  int _jumlahBintang = 0;
  List<bool> _layananDipilih = [false, false, false, false, false, false];
  List<String> _layanan = [
    'Fotografi & Videograf',
    "Event Organizer & Planner",
    "Live Band for Wedding & Parties",
    "Dekorasi dan Venue",
    "Catering",
    "Transportation",
  ];

  List<dynamic> data = [];
  bool loading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData().then(
      (res) => {
        setState(() {
          data = res;
          loading = false;
        }),
      },
    );
  }

  List<Map<String, dynamic>> filterData() {
    //list ubah jadi map dengan key index nya di list
    //dan value nilainya pada index itu di list, lalu filter berdasarkan key(index)
    //yang true, baru map lagi untuk dapay value dari pasangan index dan value yang dipilih
    //jadi kita pakai entry.value aja, udah dapat satu bilai ini, konversi lagi ke list
    //dapatlah list yang isinya kategori yang dipilih
    final selectedService =
        _layanan
            .asMap()
            .entries
            .where((entry) => _layananDipilih[entry.key])
            .map((entry) => entry.value)
            .toList();

    List<Map<String, dynamic>> result = [];

    for (var kategori in data) {
      for (var penyedia in kategori["penyedia"]) {
        final hargaBasic = penyedia["harga"]["basic"];
        final rating = penyedia["rating"];
        final kategoriName = kategori["kategori"];

        bool matchesPrice =
            hargaBasic >= _rentangHarga.start &&
            hargaBasic <= _rentangHarga.end;

        bool matchesRating = _jumlahBintang == 0 || rating >= _jumlahBintang;

        bool matchesService =
            selectedService.isEmpty || selectedService.contains(kategoriName);

        if (matchesPrice && matchesRating && matchesService) {
          result.add(penyedia);
        }

        final noFilters =
            _jumlahBintang == 0 &&
            selectedService.isEmpty &&
            _rentangHarga.start == 0 &&
            _rentangHarga.end == 10000000;

        if (noFilters && result.length > 10) {
          return result.take(10).toList();
        }
      }
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    return Scaffold(
      backgroundColor: Colors.white,
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
                              children: [
                                Row(
                                  children: List.generate(5, (index) {
                                    return IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      icon: Icon(
                                        Icons.star,
                                        color:
                                            _starIsclicked[index]
                                                ? Colors.amber
                                                : Colors.grey,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _starIsclicked[index] =
                                              !_starIsclicked[index];
                                          _starIsclicked[index]
                                              ? _jumlahBintang += 1
                                              : _jumlahBintang -= 1;
                                        });
                                      },
                                    );
                                  }),
                                ),

                                SizedBox(width: 10),
                                Text(
                                  _jumlahBintang > 0
                                      ? "$_jumlahBintang bintang ke atas"
                                      : "Semua",
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 139, 139, 139),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Jenis Layanan",
                              style: TextStyle(fontSize: width > 500 ? 15 : 13),
                            ),
                            Wrap(
                              spacing: 10,
                              runSpacing: 5,

                              children: List.generate(5, (index) {
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
                      ),
                    ),
                    SizedBox(height: 15),
                    loading
                        ? const CircularProgressIndicator()
                        : Column(
                          children:
                              filterData().map((penyedia) {
                                return Card(
                                  elevation: 3,
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Image.network(
                                        penyedia["image"],
                                        height: 180,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              penyedia["nama"],
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
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
                                                  "${penyedia["rating"]} (120 ulasan)",
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              "Rp ${formatPrice(penyedia["harga"]["basic"])}",
                                              style: const TextStyle(
                                                fontSize: 15,
                                                color: Colors.pink,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                        ),
                    SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: () {},
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(
                          Color.fromARGB(255, 223, 83, 129),
                        ),
                      ),
                      child: Text(
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
