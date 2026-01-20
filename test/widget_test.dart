import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:projek_uts_mbr/auth/loginCostumer.dart';
import 'package:projek_uts_mbr/databases/vendorDatabase.dart';
import 'package:projek_uts_mbr/l10n/app_localizations.dart';
import 'package:projek_uts_mbr/main.dart';
import 'package:projek_uts_mbr/provider/language_provider.dart';
import 'package:projek_uts_mbr/services/sessionManager.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'home_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late MockVendordatabase mockVendordatabase;
  late MockSessionManager mockSessionManager;
  late MockLanguageProvider mockLanguageProvider;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockVendordatabase = MockVendordatabase();
    mockSessionManager = MockSessionManager();
    mockLanguageProvider = MockLanguageProvider();

    when(mockVendordatabase.initDataAwal()).thenAnswer((_) async => {});
    when(mockVendordatabase.updatePasswords()).thenAnswer((_) async => {});
    when(mockVendordatabase.getData()).thenAnswer((_) async => []);

    when(mockSessionManager.isLoggedIn()).thenAnswer((_) async => false);
    when(mockSessionManager.getEmail()).thenAnswer((_) async => null);
    when(mockSessionManager.getUserType()).thenAnswer((_) async => 'customer');

    when(mockLanguageProvider.locale).thenReturn(const Locale('id'));
  });

  testWidgets('Renders Login page when not logged in', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<SessionManager>.value(value: mockSessionManager),
          Provider<Vendordatabase>.value(value: mockVendordatabase),
          ChangeNotifierProvider<LanguageProvider>.value(
            value: mockLanguageProvider,
          ),
        ],
        child: MaterialApp(
          locale: mockLanguageProvider.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const MyHomePage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(LoginCustomer), findsOneWidget);
  });
}
