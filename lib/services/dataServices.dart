import 'dart:convert';
import 'package:flutter/services.dart';

class Dataservices {
  Future<List<dynamic>> loadData() async {
    final String response = await rootBundle.loadString('assets/data.json');
    final data = await json.decode(response);
    // print(data);
    return data;
  }

  Future<Map<String, dynamic>> loadDataDariNama(String nama) async {
    final String response = await rootBundle.loadString('assets/data.json');
    final List<dynamic> data = await json.decode(response);
    List<dynamic> result = [];

    for (var kategori in data) {
      for (var penyedia in kategori['penyedia']) {
        if (penyedia['nama'] == nama) {
          return penyedia;
        }
      }
    }
    ;
    return {};
  }
}
