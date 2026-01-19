import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:projek_uts_mbr/profile/vendorProfile.dart';
import 'package:projek_uts_mbr/provider/language_provider.dart';
import 'package:projek_uts_mbr/l10n/app_localizations.dart';

void main() {
  Widget createTestWidget() {
    return ChangeNotifierProvider(
      create: (_) => LanguageProvider(),
      child: MaterialApp(
        locale: const Locale('id'),
        supportedLocales: const [Locale('id')],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const Vendorprofile(),
      ),
    );
  }

  testWidgets('Halaman profil vendor dapat ditampilkan tanpa error', (
    tester,
  ) async {
    await tester.pumpWidget(createTestWidget());
    expect(find.byType(Vendorprofile), findsOneWidget);
  });

  testWidgets('Menampilkan appbar', (tester) async {
    await tester.pumpWidget(createTestWidget());
    expect(find.byType(AppBar), findsOneWidget);
  });

  testWidgets('Menampilkan indikator loading di awal', (tester) async {
    await tester.pumpWidget(createTestWidget());
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('Menampilkan judul Profil Vendor pada AppBar', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pump();
    expect(find.text('Profil Vendor'), findsOneWidget);
  });

  testWidgets('Menampilkan tombol ikon pengaturan', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byIcon(Icons.settings), findsOneWidget);
  });
}
