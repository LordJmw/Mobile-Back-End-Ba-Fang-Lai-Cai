import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  final String IS_LOGGED_IN = "isLoggedIn";
  final String EMAIL = "email";

  Future<void> createLoginSession(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(IS_LOGGED_IN, true);
    await prefs.setString(EMAIL, email);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(IS_LOGGED_IN);
    await prefs.remove(EMAIL);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(IS_LOGGED_IN) ?? false;
  }

  Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(EMAIL);
  }
}