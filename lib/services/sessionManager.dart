import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  final String IS_LOGGED_IN = "isLoggedIn";
  final String EMAIL = "email";
  final String userType = "userType";

  Future<void> createLoginSession(String email, String type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(IS_LOGGED_IN, true);
    //untuk pas beli biar tau siapa yang beli
    await prefs.setString(EMAIL, email);
    await prefs.setString(userType, type);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(IS_LOGGED_IN);
    await prefs.remove(EMAIL);

    final keys = prefs.getKeys();
    for (var key in keys) {
      if (key.startsWith('category_') || key.startsWith('global_filter')) {
        await prefs.remove(key);
        print("Removed filter preference: $key");
      }
    }
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(IS_LOGGED_IN) ?? false;
  }

  Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(EMAIL);
  }

  Future<String?> getUserType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(userType);
  }
}
