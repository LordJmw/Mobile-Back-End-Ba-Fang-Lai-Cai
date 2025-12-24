import 'dart:async';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:projek_uts_mbr/auth/logincostumer.dart';
import 'package:projek_uts_mbr/home/home.dart';
import 'package:projek_uts_mbr/l10n/app_localizations.dart';
import 'package:projek_uts_mbr/profile/userProfile.dart';
import 'package:projek_uts_mbr/profile/vendorProfile.dart';
import 'package:projek_uts_mbr/provider/language_provider.dart';
import 'package:projek_uts_mbr/services/notification_services.dart';
import 'package:projek_uts_mbr/services/sessionManager.dart';
import 'package:projek_uts_mbr/viewall.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  unawaited(MobileAds.instance.initialize());
  //load bahasa dari sharedPreference sebelum app berjalan
  final languageProvider = LanguageProvider();
  await languageProvider.loadLocale();

  AwesomeNotifications().initialize(
    // set the icon to null if you want to use the default app icon
    null,
    [
      NotificationChannel(
        channelGroupKey: 'basic_channel_group',
        channelKey: 'basic_channel',
        channelName: 'Basic notifications',
        channelDescription: 'Notification channel for basic tests',
        defaultColor: Color(0xFF9D50DD),
        ledColor: Colors.white,
      ),
    ],
    debug: true,
  );

  runApp(
    ChangeNotifierProvider.value(value: languageProvider, child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          locale: languageProvider.locale,
          supportedLocales: const [Locale('en'), Locale('id')],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const MyHomePage(),
        );
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  Future<bool> checkLoginStatus() async {
    SessionManager sessionManager = SessionManager();
    return await sessionManager.isLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: checkLoginStatus(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: Colors.pink)),
          );
        }

        final isLoggedIn = snapshot.data ?? false;
        return isLoggedIn ? const MainScreen() : LoginCustomer();
      },
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

  Future<void> _initNotification() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      bool allowed = await AwesomeNotifications()
          .requestPermissionToSendNotifications();
      if (allowed) {
        SessionManager().setNotificationEnabled(true);
      }
    }
  }

  @override
  void initState() {
    super.initState();

    _initNotification();
    setProfileSesuaiTipe();
    NotificationServices.checkAndTrigger();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.pink)),
      );
    }

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        selectedItemColor: Colors.pink,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: l10n.home),
          BottomNavigationBarItem(
            icon: Icon(Icons.all_inbox),
            label: l10n.viewAll,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: l10n.profile,
          ),
        ],
      ),
    );
  }
}
