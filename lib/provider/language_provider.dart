import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('id');
  bool _isLoading = true;

  Locale get locale => _locale;
  bool get isLoading => _isLoading;

  Future<void> loadLocale() async {
    if (_isLoading) {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString('language') ?? 'id';
      _locale = Locale(languageCode);
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale newLocale) async {
    _locale = newLocale;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', newLocale.languageCode);

    notifyListeners();
  }

  String getLanguageName() {
    switch (_locale.languageCode) {
      case 'id':
        return 'Indonesia';
      case 'en':
        return 'English';
      default:
        return 'Indonesia';
    }
  }

  Locale getLocaleFromName(String languageName) {
    switch (languageName) {
      case 'Indonesia':
        return const Locale('id');
      case 'English':
        return const Locale('en');
      default:
        return const Locale('id');
    }
  }
}
