import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:projek_uts_mbr/auth/logincostumer.dart';
import 'package:projek_uts_mbr/cardDetail.dart';
import 'package:projek_uts_mbr/category.dart';
import 'package:projek_uts_mbr/home/home.dart';
import 'package:projek_uts_mbr/l10n/app_localizations.dart';

import 'package:projek_uts_mbr/profile/userProfile.dart';
import 'package:projek_uts_mbr/profile/vendorProfile.dart';
import 'package:projek_uts_mbr/auth/register.dart';
import 'package:projek_uts_mbr/services/sessionManager.dart';
import 'package:projek_uts_mbr/viewall.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  bool _showBottomNavBar = true;

  void setBottomNavVisibility(bool visible) {
    setState(() {
      _showBottomNavBar = visible;
    });
  }

  Future<bool> checkLoginStatus() async {
    SessionManager sessionManager = SessionManager();
    return await sessionManager.isLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: Locale('id'),
      localizationsDelegates: [
        AppLocalizations.delegate, // Add this line
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en'), // English
        Locale('id'),
      ],
      home: FutureBuilder<bool>(
        future: checkLoginStatus(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: Colors.pink),
              ),
            );
          }

          final isLoggedIn = snapshot.data ?? false;
          return isLoggedIn ? const MainScreen() : LoginCustomer();
        },
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  bool loading = true;
  List<Widget> _pages = [];

  Future<String?> getUserType() async {
    SessionManager sessionManager = SessionManager();
    return await sessionManager.getUserType();
  }

  setProfileSesuaiTipe() async {
    String? userType = await getUserType();
    print('User type from session: $userType');
    setState(() {
      if (userType == "customer") {
        _pages = [const HomePage(), const ViewAllPage(), const UserProfile()];
      } else {
        _pages = [const HomePage(), const ViewAllPage(), const Vendorprofile()];
      }
      loading = false;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    setProfileSesuaiTipe();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.pink)),
      );
    }

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.pink,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.all_inbox),
            label: 'Lihat Semua',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
