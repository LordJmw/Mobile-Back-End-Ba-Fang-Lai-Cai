import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:projek_uts_mbr/order.dart';
import 'package:projek_uts_mbr/provider/language_provider.dart';
import 'package:projek_uts_mbr/services/discount_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:projek_uts_mbr/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  /// DISCOUNT
  group('Unit Test Diskon', () {
    setUp(() {
      DiscountService.deactivateDiscount();
    });

    test('Diskon tidak aktif mengembalikan harga asli', () {
      final price = DiscountService.applyDiscount(100000);
      expect(price, 100000);
    });

    test('Aktivasi diskon mengubah status menjadi aktif', () {
      DiscountService.activateDiscount(0.1);
      expect(DiscountService.isDiscountActive, true);
    });

    test('Persentase diskon tersimpan dengan benar', () {
      DiscountService.activateDiscount(0.2);
      expect(DiscountService.discountPercent, 0.2);
    });

    test('Perhitungan diskon sesuai', () {
      DiscountService.activateDiscount(0.10);
      final price = DiscountService.applyDiscount(100000);
      expect(price, 90000);
    });

    test('Menonaktifkan diskon mereset state', () {
      DiscountService.activateDiscount(0.1);
      DiscountService.deactivateDiscount();
      expect(DiscountService.isDiscountActive, false);
      expect(DiscountService.discountPercent, 0.0);
    });
  });

  Widget makeTestableWidget({
    String vendor = 'Vendor Test',
    bool isTestMode = true,
  }) {
    return ChangeNotifierProvider(
      create: (_) => LanguageProvider(),
      child: MaterialApp(
        locale: const Locale('id'),
        supportedLocales: const [Locale('id'), Locale('en')],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: OrderPage(namaVendor: vendor, isTestMode: isTestMode),
      ),
    );
  }

  //
  group('Widget OrderPage', () {
    testWidgets('OrderPage tampil tanpa error', (tester) async {
      await tester.pumpWidget(makeTestableWidget());
      expect(find.byType(OrderPage), findsOneWidget);
    });

    testWidgets('Menampilkan loading indicator', (tester) async {
      await tester.pumpWidget(makeTestableWidget(isTestMode: false));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('AppBar ditampilkan', (tester) async {
      await tester.pumpWidget(makeTestableWidget());
      await tester.pump();
      expect(find.byType(AppBar), findsOneWidget);
    });
  });

  // FORM INPUT
  group('OrderPage - Form Input', () {
    testWidgets('TextField lokasi tampil', (tester) async {
      await tester.pumpWidget(makeTestableWidget());
      await tester.pump();

      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('User bisa mengisi lokasi', (tester) async {
      await tester.pumpWidget(makeTestableWidget());
      await tester.pump();

      final locationField = find.byType(TextField).first;

      await tester.enterText(locationField, 'Jakarta');
      await tester.pump();

      expect(find.text('Jakarta'), findsOneWidget);
    });
  });

  // BUTTON & UI
  group('OrderPage - Button & UI', () {
    testWidgets('Tombol bayar tampil', (tester) async {
      await tester.pumpWidget(makeTestableWidget());
      await tester.pump();
      final payButtonFinder = find.byKey(const Key('payButton'));
      await tester.ensureVisible(payButtonFinder);
      expect(payButtonFinder, findsOneWidget);
    });

    testWidgets('Tombol iklan tampil untuk user non-premium', (tester) async {
      await tester.pumpWidget(makeTestableWidget());
      await tester.pump();
      expect(find.textContaining('Iklan'), findsWidgets);
    });
  });

  // SCROLL
  group('OrderPage - Scroll', () {
    testWidgets('Page bisa di-scroll tanpa crash', (tester) async {
      await tester.pumpWidget(makeTestableWidget());
      await tester.pump();

      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -300),
      );
      await tester.pump();

      expect(true, isTrue);
    });
  });
}
