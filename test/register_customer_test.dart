import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:projek_uts_mbr/auth/registerCustomer.dart';
import 'package:projek_uts_mbr/provider/language_provider.dart';
import 'package:projek_uts_mbr/l10n/app_localizations.dart';

Widget createRegisterTestWidget() {
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
      home: RegisterCustomer(),
    ),
  );
}

void main() {
  testWidgets('1. Halaman RegisterCustomer tampil', (tester) async {
    await tester.pumpWidget(createRegisterTestWidget());
    expect(find.byType(RegisterCustomer), findsOneWidget);
  });

  testWidgets('2. Form tersedia', (tester) async {
    await tester.pumpWidget(createRegisterTestWidget());
    expect(find.byType(Form), findsWidgets);
  });

  testWidgets('3. Field input tersedia', (tester) async {
    await tester.pumpWidget(createRegisterTestWidget());
    expect(find.byType(TextFormField), findsWidgets);
  });

  testWidgets('4. Tombol register bisa ditekan (AMAN)', (tester) async {
    await tester.pumpWidget(createRegisterTestWidget());

    final button = find.byType(ElevatedButton).first;
    await tester.ensureVisible(button);
    await tester.tap(button, warnIfMissed: false);
    await tester.pump();

    expect(find.byType(RegisterCustomer), findsOneWidget);
  });

  testWidgets('5. Halaman register stabil', (tester) async {
    await tester.pumpWidget(createRegisterTestWidget());
    expect(tester.takeException(), isNull);
  });
}
