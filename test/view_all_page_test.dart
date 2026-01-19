import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:projek_uts_mbr/viewall.dart';
import 'package:projek_uts_mbr/databases/vendorDatabase.dart';
import 'package:projek_uts_mbr/provider/language_provider.dart';
import 'package:projek_uts_mbr/l10n/app_localizations.dart';

import 'view_all_page_mock.dart';

void main() {
  late Vendordatabase mockDb;
  late LanguageProvider languageProvider;

  setUp(() {
    mockDb = ViewAllPageMock.buildMockVendorDatabase();
    languageProvider = LanguageProvider();
    languageProvider.setLocale(const Locale('id', ''));
  });

  Widget buildTestWidget() {
    return MultiProvider(
      providers: [
        Provider<Vendordatabase>.value(value: mockDb),
        ChangeNotifierProvider<LanguageProvider>.value(value: languageProvider),
      ],
      child: MaterialApp(
        home: const ViewAllPage(),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en', ''), Locale('id', '')],
        locale: const Locale('id', ''),
      ),
    );
  }

  testWidgets(
    'Menampilkan TextField pencarian dan GridView setelah data dimuat',
    (tester) async {
      await tester.pumpWidget(buildTestWidget());

      // Tunggu loading selesai
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(GridView), findsOneWidget);

      expect(find.text('LensArt Studio'), findsOneWidget);
      expect(find.text('Golden Frame'), findsOneWidget);
    },
  );

  testWidgets('Fungsi search memfilter vendor berdasarkan teks', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle(const Duration(seconds: 1));

    final textField = find.byType(TextField);
    expect(textField, findsOneWidget);

    await tester.enterText(textField, 'lens');
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(find.text('LensArt Studio'), findsOneWidget);
    expect(find.text('Golden Frame'), findsNothing);
  });

  testWidgets('Search kosong mengembalikan semua vendor', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle(const Duration(seconds: 1));

    final textField = find.byType(TextField);
    expect(textField, findsOneWidget);

    await tester.enterText(textField, '');
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(find.text('LensArt Studio'), findsOneWidget);
    expect(find.text('Golden Frame'), findsOneWidget);
  });

  testWidgets('Search dengan teks tidak ditemukan', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle(const Duration(seconds: 1));

    final textField = find.byType(TextField);
    await tester.enterText(textField, 'tidakada');
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(find.text('LensArt Studio'), findsNothing);
    expect(find.text('Golden Frame'), findsNothing);
  });
}
