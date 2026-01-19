import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:projek_uts_mbr/analytics/eventLogs.dart';
import 'package:projek_uts_mbr/auth/loginVendor.dart';
import 'package:projek_uts_mbr/databases/vendorDatabase.dart';
import 'package:projek_uts_mbr/l10n/app_localizations.dart';
import 'package:projek_uts_mbr/model/VendorModel.dart';
import 'package:projek_uts_mbr/model/purchaseHistoryModel.dart';
import 'package:projek_uts_mbr/provider/language_provider.dart';
import 'package:projek_uts_mbr/services/sessionManager.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import mocks
import 'loginVendor_test.mocks.dart';

class MockFirebaseAnalytics extends Mock implements FirebaseAnalytics {}

class MockAwesomeNotifications extends Mock implements AwesomeNotifications {}

void main() {
  late MockVendordatabase mockVendorDatabase;
  late MockSessionManager mockSessionManager;
  late FakeNavigatorObserver fakeNavigatorObserver;
  late FakeEventlogs fakeEventlogs;

  setUp(() {
    mockVendorDatabase = MockVendordatabase();
    mockSessionManager = MockSessionManager();
    fakeNavigatorObserver = FakeNavigatorObserver();
    fakeEventlogs = FakeEventlogs();
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() {
    reset(mockVendorDatabase);
    reset(mockSessionManager);
  });

  Widget createWidgetUnderTest() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        Provider<SessionManager>.value(value: mockSessionManager),
        Provider<Vendordatabase>.value(value: mockVendorDatabase),
      ],
      child: MaterialApp(
        home: LoginVendor(
          vendordatabase: mockVendorDatabase,
          sessionManager: mockSessionManager,
          eventlogs: fakeEventlogs,
        ),
        navigatorObservers: [fakeNavigatorObserver],
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
  }

  testWidgets('Widget LoginVendor berhasil dibangun dengan semua elemen UI', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    final localizations = await AppLocalizations.delegate.load(
      const Locale('en'),
    );

    expect(find.text(localizations.welcome), findsOneWidget);
    expect(find.text(localizations.loginToContinue), findsOneWidget);
    expect(find.text(localizations.email), findsOneWidget);
    expect(find.text(localizations.password), findsOneWidget);
    expect(find.text(localizations.login), findsOneWidget);
    expect(find.text(localizations.noAccountRegister), findsOneWidget);
    expect(find.text(localizations.loginAsCustomer), findsOneWidget);
  });

  testWidgets('Validasi form - email kosong menunjukkan error message', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), '');
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');

    await tester.tap(find.text('Login'));
    await tester.pump();

    expect(find.text('Email is required'), findsOneWidget);
  });

  testWidgets('Validasi form - password kosong menunjukkan error', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'test@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), '');

    await tester.tap(find.text('Login'));
    await tester.pump();

    expect(find.text('Password is required'), findsOneWidget);
  });

  testWidgets('Validasi form - format email tidak valid', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'bukan-email-format',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');

    await tester.tap(find.text('Login'));
    await tester.pump();

    expect(find.text('Invalid email format'), findsOneWidget);
  });

  testWidgets('Validasi form - password minimal 6 karakter', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'test@example.com',
    );
    await tester.enterText(
      find.byType(TextFormField).at(1),
      '12345',
    ); // 5 karakter

    await tester.tap(find.text('Login'));
    await tester.pump();

    expect(find.text('Minimum 6 characters'), findsOneWidget);
  });

  testWidgets('Login berhasil dengan email dan password valid', (
    WidgetTester tester,
  ) async {
    final mockPenyedia = Penyedia(
      nama: 'Test Vendor',
      deskripsi: 'A description',
      rating: 4.5,
      harga: Harga(
        basic: TipePaket(harga: 100, jasa: 'Basic service'),
        premium: TipePaket(harga: 200, jasa: 'Premium service'),
        custom: TipePaket(harga: 300, jasa: 'Custom service'),
      ),
      testimoni: [],
      email: 'vendor@example.com',
      password: 'password123',
      telepon: '1234567890',
      image: 'image.png',
    );

    when(
      mockVendorDatabase.LoginVendor(any, any),
    ).thenAnswer((_) => Future<Penyedia?>.value(mockPenyedia));

    when(
      mockSessionManager.createLoginSession(any, any),
    ).thenAnswer((_) async {});

    when(mockSessionManager.getUserType()).thenAnswer((_) async => 'vendor');

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'vendor@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');

    await tester.tap(find.text('Login'));
    await tester.pump(const Duration(milliseconds: 500));

    verify(
      mockVendorDatabase.LoginVendor('vendor@example.com', 'password123'),
    ).called(1);

    verify(mockSessionManager.createLoginSession(any, any)).called(1);

    expect(fakeNavigatorObserver.pushedRoutes.length, 2);

    expect(fakeNavigatorObserver.pushedRoutes[0], isA<MaterialPageRoute>());
  });

  testWidgets('Login gagal dengan email atau password salah', (
    WidgetTester tester,
  ) async {
    when(
      mockVendorDatabase.LoginVendor(any, any),
    ).thenAnswer((_) async => null);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'wrong@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'wrongpassword');

    await tester.tap(find.text('Login'));

    // ⬇️ WAJIB agar SnackBar muncul
    await tester.pumpAndSettle();

    verify(
      mockVendorDatabase.LoginVendor('wrong@example.com', 'wrongpassword'),
    ).called(1);

    verifyNever(mockSessionManager.createLoginSession(any, any));

    // 🔥 SnackBar assertion
    expect(
      find.byKey(const Key('invalid_credentials_snackbar')),
      findsOneWidget,
    );
  });

  testWidgets('Navigasi ke halaman register saat tombol register ditekan', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    final localizations = await AppLocalizations.delegate.load(
      const Locale('en'),
    );
    final buttonFinder = find.text(localizations.noAccountRegister);
    await tester.ensureVisible(buttonFinder);
    await tester.tap(buttonFinder);
    await tester.pumpAndSettle();

    expect(fakeNavigatorObserver.pushedRoutes.length, 1);
    expect(fakeNavigatorObserver.pushedRoutes[0], isA<MaterialPageRoute>());
  });

  testWidgets('Navigasi ke halaman login customer', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    final localizations = await AppLocalizations.delegate.load(
      const Locale('en'),
    );
    final buttonFinder = find.text(localizations.loginAsCustomer);
    await tester.ensureVisible(buttonFinder);
    await tester.tap(buttonFinder);
    await tester.pumpAndSettle();

    expect(fakeNavigatorObserver.pushedRoutes.length, 1);
    expect(fakeNavigatorObserver.pushedRoutes[0], isA<MaterialPageRoute>());
  });

  testWidgets('Field password memiliki obscure text untuk keamanan', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    final passwordFieldFinder = find.byType(TextFormField).at(1);
    final EditableText passwordEditableText = tester.widget(
      find.descendant(
        of: passwordFieldFinder,
        matching: find.byType(EditableText),
      ),
    );

    expect(passwordEditableText.obscureText, isTrue);
  });

  testWidgets('Tombol login memiliki style yang sesuai', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    final elevatedButtonFinder = find.byType(ElevatedButton);
    expect(elevatedButtonFinder, findsOneWidget);
  });

  testWidgets('Form berada dalam Card dengan elevation', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.byType(Card), findsOneWidget);
  });

  testWidgets('Layout menggunakan SingleChildScrollView untuk scrolling', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });

  testWidgets('Form memiliki GlobalKey untuk validasi', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    final formFinder = find.byType(Form);
    expect(formFinder, findsOneWidget);

    final form = tester.widget<Form>(formFinder);
    expect(form.key, isNotNull);
    expect(form.key, isA<GlobalKey<FormState>>());
  });

  testWidgets('Input fields menerima dan menampilkan input', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    final emailField = find.byType(TextFormField).at(0);
    final passwordField = find.byType(TextFormField).at(1);

    await tester.enterText(emailField, 'user@test.com');
    await tester.enterText(passwordField, 'mypassword123');

    await tester.pump();

    expect(find.text('user@test.com'), findsOneWidget);
    expect(find.text('mypassword123'), findsOneWidget);
  });
}

class FakeNavigatorObserver extends NavigatorObserver {
  final List<Route<dynamic>> pushedRoutes = [];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushedRoutes.add(route);
    super.didPush(route, previousRoute);
  }
}

class FakeEventlogs implements Eventlogs {
  @override
  FirebaseAnalytics get analytics => MockFirebaseAnalytics();

  @override
  Future<void> bestInWeek(
    BuildContext context,
    String name,
    String rating,
    String imgPath,
  ) async {}

  @override
  Future<void> beliPaket(
    String namaVendor,
    String selectedPackage,
    String selectedPrice,
    String selectedDate,
    String location,
    String email,
  ) async {}

  @override
  Future<void> categoryIconButtonClicked(
    String categoryName,
    String screenName,
  ) async {}

  @override
  Future<void> deletePaket(int? purchaseId, String vendorName) async {}

  @override
  Future<void> editPaket(
    int? purchaseId,
    String customerId,
    PurchaseDetails purchaseDetails,
    DateTime purchaseDate,
  ) async {}

  @override
  Future<void> HargaFilter(RangeValues harga) async {}

  @override
  Future<void> LihatHalKategori() async {}

  @override
  Future<void> logLoginActivity(String email, String userType) async {}

  @override
  Future<void> logProfileEdited(String email, String userType) async {}

  @override
  Future<void> logRegisterActivity(
    String email,
    String userType,
    String alamat,
    String telepon,
  ) async {}

  @override
  Future<void> logSearchBarUsed(String query) async {}

  @override
  Future<void> logVendorLoginActivity(String email, String userType) async {}

  @override
  Future<void> logVendorRegisterActivity(
    String email,
    String userType,
    String kategori,
    String namaVendor,
  ) async {}

  @override
  Future<void> logViewAllCardClick(
    String vendorName,
    String vendorRating,
  ) async {}

  @override
  Future<void> portNReview(
    BuildContext context,
    String name,
    String desc,
    String imgPath,
  ) async {}

  @override
  Future<void> ratingFilter(int rating) async {}
}
