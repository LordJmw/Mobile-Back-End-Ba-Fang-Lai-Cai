import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projek_uts_mbr/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:projek_uts_mbr/auth/register.dart';
import 'package:projek_uts_mbr/auth/registerCustomer.dart';
import 'package:projek_uts_mbr/auth/registerVendor.dart';
import 'package:projek_uts_mbr/provider/language_provider.dart';

class testLanguageProvider extends LanguageProvider {
  @override
  Locale get locale => const Locale('id'); 
}

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });
  
  Widget wrapWithProvider(Widget child) { 
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<LanguageProvider>(
        create: (_) => testLanguageProvider(),
      ),
    ],
    child: MaterialApp(
      locale: const Locale('id'),
      supportedLocales: const [
        Locale('id'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        AppLocalizations.delegate, // ⬅️ WAJIB
      ],
      home: Scaffold(
        body: child,
      ),
    ),
  );
}
// membungkus widget yang diuji dengan seluruh dependency yang dibutuhkan, agar widget dapat dibangun dan diuji seperti di aplikasi asli.
// Karena widget RegisterCustomer dan RegisterVendor TIDAK berdiri sendiri mereka bergantung kepada provider locale dll 

  group('RegisterPage Test (Switch Customer & Vendor)', () {
    testWidgets(
        'Default halaman menampilkan Register Customer',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithProvider(const RegisterPage()),
      );

      expect(find.text('Register Customer'), findsOneWidget);
      expect(find.text('Register Vendor'), findsOneWidget);
    });

    testWidgets(
        'Klik Register Vendor menampilkan form Vendor',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithProvider(const RegisterPage()),
      );

      await tester.tap(find.text('Register Vendor'));
      await tester.pumpAndSettle();

      expect(find.byType(RegisterVendor), findsOneWidget);
    });

    testWidgets(
        'Klik Register Customer menampilkan form Customer',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithProvider(const RegisterPage()),
      );

      await tester.tap(find.text('Register Customer'));
      await tester.pumpAndSettle();

      expect(find.byType(RegisterCustomer), findsOneWidget);
    });
  });

  group('RegisterCustomer Form Validation Test', () {
    testWidgets(
        'Menampilkan semua field Register Customer',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithProvider(const RegisterCustomer()),
      );

      expect(find.byType(TextFormField), findsNWidgets(6));
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets(
        'Submit form kosong menampilkan error validasi',
        (WidgetTester tester) async {
      await tester.pumpWidget(wrapWithProvider(const RegisterCustomer()));
      await tester.pumpAndSettle();

      final submitButton = find.byType(ElevatedButton);

      await tester.ensureVisible(submitButton);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();
    });

    testWidgets(
        'Email tidak valid ditolak',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithProvider(const RegisterCustomer()),
      );

      // Field email (index ke-1)
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'emailsalah',
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.textContaining('email'), findsWidgets);
    });
  });

  group('RegisterVendor Form Validation Test', () {
    testWidgets(
        'Menampilkan form Register Vendor',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithProvider(const RegisterVendor()),
      );

      expect(find.textContaining('Vendor'), findsWidgets);
      expect(find.byType(TextFormField), findsWidgets);
    });

    testWidgets(
      'Submit form kosong menampilkan error',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          wrapWithProvider(const RegisterVendor()),
        );
        await tester.pumpAndSettle();

        final submitButton = find.byType(ElevatedButton);

        await tester.ensureVisible(submitButton);
        await tester.tap(submitButton);
        await tester.pumpAndSettle();

        expect(find.textContaining('wajib'), findsWidgets);
      },
    );


    testWidgets(
      'Password kurang dari 6 karakter ditolak',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          wrapWithProvider(const RegisterVendor()),
        );
        await tester.pumpAndSettle();

        final passwordField = find.byType(TextFormField).last;

        await tester.ensureVisible(passwordField);
        await tester.enterText(passwordField, '123');
        await tester.pumpAndSettle();

        final submitButton = find.byType(ElevatedButton);

        await tester.ensureVisible(submitButton);
        await tester.tap(submitButton);
        await tester.pumpAndSettle();

        expect(find.textContaining('6'), findsWidgets);
      },
    );

  });
}
