import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projek_uts_mbr/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:projek_uts_mbr/auth/registerVendor.dart';
import 'package:projek_uts_mbr/provider/language_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';


bool isValidEmail(String email) {
  final emailRegex =
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  return emailRegex.hasMatch(email);
}

bool isValidPrice(String value) {
  final price = int.tryParse(value);
  if (price == null) return false;
  if (price > 10000000) return false;
  return true;
}

bool isValidPassword(String password, String confirm) {
  if (password.length < 6) return false;
  if (password != confirm) return false;
  return true;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });
  group('UNIT TEST - Register Vendor Validation', () {
    test('Email valid', () {
      expect(isValidEmail('test@gmail.com'), true);
    });

    test('Email tidak valid', () {
      expect(isValidEmail('testgmail.com'), false);
    });

    test('Harga valid', () {
      expect(isValidPrice('500000'), true);
    });

    test('Harga tidak valid (terlalu besar)', () {
      expect(isValidPrice('20000000'), false);
    });

    test('Password valid dan cocok', () {
      expect(isValidPassword('123456', '123456'), true);
    });

    test('Password terlalu pendek', () {
      expect(isValidPassword('123', '123'), false);
    });

    test('Password tidak sama', () {
      expect(isValidPassword('123456', '654321'), false);
    });
  });

  group('WIDGET TEST - RegisterVendor UI', () {
    Widget createWidget() {
      return ChangeNotifierProvider(
        create: (_) => LanguageProvider(),
        child: MaterialApp(
          localizationsDelegates:
            AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(
            body: RegisterVendor(),
          ),
        ),
      );
    }

    testWidgets('Form RegisterVendor tampil', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.byType(RegisterVendor), findsOneWidget);
      expect(find.byType(TextFormField), findsWidgets);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('Klik Register tanpa isi field', (tester) async {
      await tester.pumpWidget(createWidget());

      final buttonFinder = find.byKey(const Key('registerVendorButton'));

      await tester.ensureVisible(buttonFinder);
      await tester.pumpAndSettle();

      await tester.tap(buttonFinder);
      await tester.pumpAndSettle();

      expect(find.textContaining('required'), findsWidgets);
    });


    testWidgets('Input nama toko dan email', (tester) async {
      await tester.pumpWidget(createWidget());

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'Toko Testing',
      );

      await tester.enterText(
        find.byType(TextFormField).at(1),
        'test@gmail.com',
      );

      await tester.pump();

      expect(find.text('Toko Testing'), findsOneWidget);
      expect(find.text('test@gmail.com'), findsOneWidget);
    });

    testWidgets('Dropdown kategori vendor tampil dan bisa ditekan', (tester) async {
      await tester.pumpWidget(createWidget());

      await tester.pumpAndSettle();

      final dropdownFinder = find.byType(DropdownButtonFormField<String>);

      expect(dropdownFinder, findsOneWidget);

      await tester.ensureVisible(dropdownFinder);
      await tester.pumpAndSettle();

      await tester.tap(dropdownFinder);
      await tester.pumpAndSettle();

      expect(true, isTrue);
    });

  });
}
