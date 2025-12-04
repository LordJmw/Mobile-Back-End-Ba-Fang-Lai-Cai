import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

class LocalizationHelper {
  // Singleton instance
  static final LocalizationHelper _instance = LocalizationHelper._internal();
  factory LocalizationHelper() => _instance;
  LocalizationHelper._internal();

  // Cache untuk menyimpan data ARB
  Map<String, dynamic>? _arbData;
  String? _currentLocale = 'id'; // default locale

  // Set current locale
  void setLocale(String locale) {
    _currentLocale = locale;
    _arbData = null; // Reset cache saat locale berubah
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

      // fallback
      final String content = await rootBundle.loadString('l10n/app_id.arb');

      _arbData = json.decode(content);
    }
  }

  // Get category labels dari ARB
  Future<List<Map<String, dynamic>>> getCategories() async {
    await _loadArbFile();

    // Key kategori di ARB dengan format category_1, category_2, etc.
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

    // Convert ke Map dengan label dari ARB
    return categories.map((category) {
      final label = _arbData![category["key"]] ?? category["key"];
      return {"icon": category["icon"], "key": category["key"], "label": label};
    }).toList();
  }

  // Get single category label by key
  Future<String> getCategoryLabel(String key) async {
    await _loadArbFile();
    return _arbData![key] ?? key;
  }
}
