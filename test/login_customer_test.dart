import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:projek_uts_mbr/auth/loginCostumer.dart';
import 'package:projek_uts_mbr/provider/language_provider.dart';
import 'package:projek_uts_mbr/l10n/app_localizations.dart';

Widget createLoginTestWidget() {
  return ChangeNotifierProvider<LanguageProvider>(
    create: (_) => LanguageProvider(),
    child: MaterialApp(
      locale: const Locale('en'),
      supportedLocales: const [
        Locale('en'),
        Locale('id'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: LoginCustomer(),
    ),
  );
}

void main() {
  testWidgets('1. Halaman LoginCustomer tampil', (tester) async {
    await tester.pumpWidget(createLoginTestWidget());
    expect(find.byType(LoginCustomer), findsOneWidget);
  });

  testWidgets('2. Form tersedia', (tester) async {
    await tester.pumpWidget(createLoginTestWidget());
    expect(find.byType(Form), findsWidgets);
  });

  testWidgets('3. Field input tersedia', (tester) async {
    await tester.pumpWidget(createLoginTestWidget());
    expect(find.byType(TextFormField), findsWidgets);
  });

  testWidgets('4. Tombol login bisa ditekan (AMAN)', (tester) async {
    await tester.pumpWidget(createLoginTestWidget());

    final button = find.byType(ElevatedButton).first;
    await tester.ensureVisible(button);
    await tester.tap(button, warnIfMissed: false);
    await tester.pump();

    expect(find.byType(LoginCustomer), findsOneWidget);
  });

  testWidgets('5. Halaman login stabil', (tester) async {
    await tester.pumpWidget(createLoginTestWidget());
    expect(tester.takeException(), isNull);
  });
}
