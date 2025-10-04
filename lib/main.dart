import 'package:flutter/material.dart';
import 'package:projek_uts_mbr/cardDetail.dart';
import 'package:projek_uts_mbr/category.dart';
import 'package:projek_uts_mbr/home/home.dart';
import 'package:projek_uts_mbr/profile/vendorProfile.dart';
import 'package:projek_uts_mbr/register.dart';
import 'package:projek_uts_mbr/searchPage.dart';

void main() {
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainScreen(
        showBottomNavBar: _showBottomNavBar,
        setBottomNavVisibility: setBottomNavVisibility,
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  final bool showBottomNavBar;
  final Function(bool) setBottomNavVisibility;

  const MainScreen({
    super.key,
    required this.showBottomNavBar,
    required this.setBottomNavVisibility,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const SearchPage(),
    const Vendorprofile(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar:
          widget.showBottomNavBar
              ? BottomNavigationBar(
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
                selectedItemColor: Colors.pink,
                unselectedItemColor: Colors.grey,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.search),
                    label: 'Search',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: 'Profile',
                  ),
                ],
              )
              : null,
    );
  }
}
