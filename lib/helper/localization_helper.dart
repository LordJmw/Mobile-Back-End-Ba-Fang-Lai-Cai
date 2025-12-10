import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

class LocalizationHelper {
  static final LocalizationHelper _instance = LocalizationHelper._internal();
  factory LocalizationHelper() => _instance;
  LocalizationHelper._internal();

  Map<String, dynamic>? _arbData;
  String? _currentLocale = 'id';

  void setLocale(String locale) {
    _currentLocale = locale;
    _arbData = null;
  }

  Future<void> _loadArbFile() async {
    if (_arbData != null) return;

    try {
      final String content = await rootBundle.loadString(
        'l10n/app_$_currentLocale.arb',
      );

      _arbData = json.decode(content);
    } catch (e) {
      print('Error loading ARB file: $e');

      final String content = await rootBundle.loadString('l10n/app_id.arb');

      _arbData = json.decode(content);
    }
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    await _loadArbFile();

    final List<Map<String, dynamic>> categories = [
      {"icon": Icons.camera_alt_outlined, "key": "category_1"},
      {"icon": Icons.event, "key": "category_2"},
      {"icon": Icons.brush, "key": "category_3"},
      {"icon": Icons.music_note, "key": "category_4"},
      {"icon": Icons.chair, "key": "category_5"},
      {"icon": Icons.restaurant, "key": "category_6"},
      {"icon": Icons.tv, "key": "category_7"},
      {"icon": Icons.local_shipping, "key": "category_8"},
      {"icon": Icons.handshake, "key": "category_9"},
    ];

    return categories.map((category) {
      final label = _arbData![category["key"]] ?? category["key"];
      return {"icon": category["icon"], "key": category["key"], "label": label};
    }).toList();
  }

  Future<String> getCategoryLabel(String key) async {
    await _loadArbFile();
    return _arbData![key] ?? key;
  }
}
