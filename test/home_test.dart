import 'package:flutter/foundation.dart';
// Mengimpor package material dari Flutter untuk widget UI
import 'package:flutter/material.dart';
// Mengimpor package untuk mock gambar jaringan dalam pengujian
// import 'package:network_image_mock/network_image_mock.dart';
// Mengimpor package flutter_test untuk pengujian widget
import 'package:flutter_test/flutter_test.dart';
// Mengimpor anotasi mockito untuk membuat mock class
import 'package:mockito/annotations.dart';
// Mengimpor mockito untuk fungsi mocking seperti when() dan verify()
import 'package:mockito/mockito.dart';
import 'package:network_image_mock/network_image_mock.dart';
// Mengimpor database vendor dari proyek
import 'package:projek_uts_mbr/databases/vendorDatabase.dart';
// Mengimpor halaman home yang akan diuji
import 'package:projek_uts_mbr/home/home.dart';
// Mengimpor lokalisasi aplikasi untuk teks multi-bahasa
import 'package:projek_uts_mbr/l10n/app_localizations.dart';
// Mengimpor model vendor untuk data vendor
import 'package:projek_uts_mbr/model/VendorModel.dart';
// Mengimpor provider bahasa untuk pengaturan bahasa
import 'package:projek_uts_mbr/provider/language_provider.dart';
// Mengimpor session manager untuk manajemen sesi pengguna
import 'package:projek_uts_mbr/services/sessionManager.dart';
// Mengimpor provider untuk state management
import 'package:provider/provider.dart';
// Mengimpor sqflite_common_ffi untuk database SQLite dalam pengujian
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// Mengimpor shared_preferences untuk penyimpanan data lokal
import 'package:shared_preferences/shared_preferences.dart';

// Mengimpor file mock yang di-generate oleh mockito
import 'home_test.mocks.dart';

// Anotasi untuk membuat mock class dari Vendordatabase, SessionManager, dan LanguageProvider
@GenerateMocks([Vendordatabase, SessionManager, LanguageProvider])
void main() {
  // Memastikan binding widget test sudah diinisialisasi
  TestWidgetsFlutterBinding.ensureInitialized();
  // Menginisialisasi FFI untuk sqflite (database)
  sqfliteFfiInit();
  // Mengatur factory database menggunakan FFI
  databaseFactory = databaseFactoryFfi;

  // Fungsi palsu untuk menggantikan compute() dalam pengujian
  // Menjalankan callback secara langsung tanpa isolate terpisah
  Future<R> fakeCompute<Q, R>(ComputeCallback<Q, R> callback, Q message) async {
    return await callback(message);
  }

  // Grup pengujian untuk HomePage
  group('HomePage', () {
    // Deklarasi variabel mock yang akan digunakan dalam pengujian
    late MockVendordatabase mockVendordatabase;
    late MockSessionManager mockSessionManager;
    late MockLanguageProvider mockLanguageProvider;

    // Fungsi setUp dijalankan sebelum setiap test case
    setUp(() {
      // Mengatur nilai awal mock untuk SharedPreferences
      SharedPreferences.setMockInitialValues({});
      // Membuat instance mock untuk database vendor
      mockVendordatabase = MockVendordatabase();
      // Membuat instance mock untuk session manager
      mockSessionManager = MockSessionManager();
      // Membuat instance mock untuk language provider
      mockLanguageProvider = MockLanguageProvider();

      // Mengatur mock untuk initDataAwal() agar mengembalikan Future kosong
      when(mockVendordatabase.initDataAwal()).thenAnswer((_) async => {});
      // Mengatur mock untuk updatePasswords() agar mengembalikan Future kosong
      when(mockVendordatabase.updatePasswords()).thenAnswer((_) async => {});

      // Mengatur mock untuk isLoggedIn() agar mengembalikan false (tidak login)
      when(mockSessionManager.isLoggedIn()).thenAnswer((_) async => false);
      // Mengatur mock untuk getEmail() agar mengembalikan null
      when(mockSessionManager.getEmail()).thenAnswer((_) async => null);

      // Mengatur mock untuk locale agar mengembalikan bahasa Indonesia
      when(mockLanguageProvider.locale).thenReturn(const Locale('id'));
    });

    // Test case: Memverifikasi teks "Rating Terbaik Minggu Ini!" ditampilkan
    testWidgets('displays "Rating Terbaik Minggu Ini!" text', (
      WidgetTester tester,
    ) async {
      // Mengatur mock getData() untuk mengembalikan list kosong
      when(mockVendordatabase.getData()).thenAnswer((_) async => []);
      // Membangun widget dengan provider yang diperlukan
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            // Menyediakan mock SessionManager
            Provider<SessionManager>.value(value: mockSessionManager),
            // Menyediakan mock Vendordatabase
            Provider<Vendordatabase>.value(value: mockVendordatabase),
            // Menyediakan mock LanguageProvider dengan ChangeNotifier
            ChangeNotifierProvider<LanguageProvider>.value(
              value: mockLanguageProvider,
            ),
          ],
          child: MaterialApp(
            // Mengatur delegate lokalisasi
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            // Mengatur locale yang didukung
            supportedLocales: AppLocalizations.supportedLocales,
            // Menampilkan HomePage dengan fungsi compute palsu
            home: HomePage(computeFunc: fakeCompute),
          ),
        ),
      );

      // Memproses satu frame untuk membangun widget
      await tester.pump();

      // Memverifikasi bahwa teks "Rating Terbaik Minggu Ini!" ditemukan
      expect(
        find.text(
          AppLocalizations.of(
            tester.element(find.byType(HomePage)),
          )!.bestRatedThisWeek,
        ),
        findsOneWidget,
      );
    });

    // Test case: Memverifikasi teks "Kategori Vendor" ditampilkan
    testWidgets('displays "Kategori Vendor" text', (WidgetTester tester) async {
      // Mengatur mock getData() untuk mengembalikan list kosong
      when(mockVendordatabase.getData()).thenAnswer((_) async => []);
      // Membangun widget dengan provider yang diperlukan
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            // Menyediakan mock SessionManager
            Provider<SessionManager>.value(value: mockSessionManager),
            // Menyediakan mock Vendordatabase
            Provider<Vendordatabase>.value(value: mockVendordatabase),
            // Menyediakan mock LanguageProvider dengan ChangeNotifier
            ChangeNotifierProvider<LanguageProvider>.value(
              value: mockLanguageProvider,
            ),
          ],
          child: MaterialApp(
            // Mengatur delegate lokalisasi
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            // Mengatur locale yang didukung
            supportedLocales: AppLocalizations.supportedLocales,
            // Menampilkan HomePage dengan fungsi compute palsu
            home: HomePage(computeFunc: fakeCompute),
          ),
        ),
      );

      // Memproses semua frame hingga animasi selesai
      await tester.pumpAndSettle();

      // Memverifikasi bahwa teks "Kategori Vendor" ditemukan
      expect(
        find.text(
          AppLocalizations.of(
            tester.element(find.byType(HomePage)),
          )!.categoryVendor,
        ),
        findsOneWidget,
      );
    });

    // Test case: Memverifikasi 9 tombol kategori dengan ikon ditampilkan
    testWidgets('displays 9 category elevated buttons with icons', (
      WidgetTester tester,
    ) async {
      // Mendapatkan instance binding untuk mengatur ukuran layar
      final binding = TestWidgetsFlutterBinding.instance;
      // Mengatur ukuran layar fisik untuk pengujian (3000x1800 piksel)
      binding.window.physicalSizeTestValue = const Size(3000, 1800);
      // Mengatur rasio piksel perangkat menjadi 1.0
      binding.window.devicePixelRatioTestValue = 1.0;
      // Menambahkan tearDown untuk membersihkan pengaturan setelah test
      addTearDown(() {
        // Menghapus pengaturan ukuran layar test
        binding.window.clearPhysicalSizeTestValue();
        // Menghapus pengaturan rasio piksel test
        binding.window.clearDevicePixelRatioTestValue();
      });

      // Mengatur mock getData() untuk mengembalikan list kosong
      when(mockVendordatabase.getData()).thenAnswer((_) async => []);
      // Membangun widget dengan provider yang diperlukan
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            // Menyediakan mock SessionManager
            Provider<SessionManager>.value(value: mockSessionManager),
            // Menyediakan mock Vendordatabase
            Provider<Vendordatabase>.value(value: mockVendordatabase),
            // Menyediakan mock LanguageProvider dengan ChangeNotifier
            ChangeNotifierProvider<LanguageProvider>.value(
              value: mockLanguageProvider,
            ),
          ],
          child: MaterialApp(
            // Mengatur delegate lokalisasi
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            // Mengatur locale yang didukung
            supportedLocales: AppLocalizations.supportedLocales,
            // Menampilkan HomePage dengan fungsi compute palsu
            home: HomePage(computeFunc: fakeCompute),
          ),
        ),
      );

      // Memproses semua frame hingga animasi selesai
      await tester.pumpAndSettle();

      // Mencari semua ElevatedButton yang memiliki Icon sebagai child langsung (tombol kategori)
      final elevatedButtons = tester.widgetList<ElevatedButton>(
        find.byType(ElevatedButton),
      );

      // Variabel penghitung untuk tombol kategori
      int categoryButtonCount = 0;
      // Iterasi melalui semua tombol yang ditemukan
      for (final button in elevatedButtons) {
        // Tombol kategori memiliki Icon sebagai child-nya
        if (button.child is Icon) {
          categoryButtonCount++;
        }
      }

      // Memverifikasi bahwa ada tepat 9 tombol kategori
      expect(categoryButtonCount, equals(9));
    });

    // Test case: Memverifikasi semua 9 label kategori ditampilkan di bawah ikon
    testWidgets('displays all 9 category labels below icons', (
      WidgetTester tester,
    ) async {
      // Mendapatkan instance binding untuk mengatur ukuran layar
      final binding = TestWidgetsFlutterBinding.instance;
      // Mengatur ukuran layar fisik untuk pengujian (3000x1800 piksel)
      binding.window.physicalSizeTestValue = const Size(3000, 1800);
      // Mengatur rasio piksel perangkat menjadi 1.0
      binding.window.devicePixelRatioTestValue = 1.0;
      // Menambahkan tearDown untuk membersihkan pengaturan setelah test
      addTearDown(() {
        // Menghapus pengaturan ukuran layar test
        binding.window.clearPhysicalSizeTestValue();
        // Menghapus pengaturan rasio piksel test
        binding.window.clearDevicePixelRatioTestValue();
      });

      // Mengatur mock getData() untuk mengembalikan list kosong
      when(mockVendordatabase.getData()).thenAnswer((_) async => []);
      // Membangun widget dengan provider yang diperlukan
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            // Menyediakan mock SessionManager
            Provider<SessionManager>.value(value: mockSessionManager),
            // Menyediakan mock Vendordatabase
            Provider<Vendordatabase>.value(value: mockVendordatabase),
            // Menyediakan mock LanguageProvider dengan ChangeNotifier
            ChangeNotifierProvider<LanguageProvider>.value(
              value: mockLanguageProvider,
            ),
          ],
          child: MaterialApp(
            // Mengatur delegate lokalisasi
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            // Mengatur locale yang didukung
            supportedLocales: AppLocalizations.supportedLocales,
            // Menampilkan HomePage dengan fungsi compute palsu
            home: HomePage(computeFunc: fakeCompute),
          ),
        ),
      );

      // Memproses semua frame hingga animasi selesai
      await tester.pumpAndSettle();

      // Mendapatkan semua label kategori yang diharapkan dari AppLocalizations
      final appLocalizations = AppLocalizations.of(
        tester.element(find.byType(HomePage)),
      )!;

      // Daftar label kategori yang diharapkan
      final expectedLabels = [
        appLocalizations.categoryPhotography, // Fotografi
        appLocalizations.categoryEventOrganizer, // Event Organizer
        appLocalizations.categoryMakeupFashion, // Makeup & Fashion
        appLocalizations.categoryEntertainment, // Hiburan
        appLocalizations.categoryDecorVenue, // Dekorasi & Venue
        appLocalizations.categoryCateringFB, // Katering & F&B
        appLocalizations
            .categoryTechEventProduction, // Teknologi & Produksi Event
        appLocalizations
            .categoryTransportationLogistics, // Transportasi & Logistik
        appLocalizations.categorySupportServices, // Layanan Pendukung
      ];

      // Memverifikasi bahwa ada 9 label yang diharapkan
      expect(expectedLabels.length, equals(9));

      // Memeriksa bahwa setiap label kategori yang diharapkan ditampilkan di bawah ikon kategori
      // Label kategori dibungkus dalam FittedBox sesuai implementasi _buildCategory
      for (final label in expectedLabels) {
        expect(
          find.text(label),
          findsAtLeastNWidgets(1),
          reason: 'Label kategori "$label" harus ditampilkan di bawah ikonnya',
        );
      }

      // Memverifikasi bahwa semua label kategori ditemukan dalam widget tree
      // dengan memeriksa bahwa setiap label yang diharapkan muncul setidaknya sekali
      int categoryLabelsFound = 0;
      for (final expectedLabel in expectedLabels) {
        final labelFinder = find.text(expectedLabel);
        if (labelFinder.evaluate().isNotEmpty) {
          categoryLabelsFound++;
        }
      }

      // Memverifikasi bahwa semua 9 label kategori ditemukan
      expect(
        categoryLabelsFound,
        equals(9),
        reason: 'Semua 9 label kategori harus ditemukan di bawah ikon kategori',
      );
    });

    // Test case: Memverifikasi 8 kartu vendor dimuat dan ditampilkan
    testWidgets('loads and displays 8 vendor cards', (
      WidgetTester tester,
    ) async {
      // Mendapatkan instance binding untuk mengatur ukuran layar
      final binding = TestWidgetsFlutterBinding.instance;
      // Mengatur ukuran layar fisik untuk pengujian (3000x1800 piksel)
      binding.window.physicalSizeTestValue = const Size(3000, 1800);
      // Mengatur rasio piksel perangkat menjadi 1.0
      binding.window.devicePixelRatioTestValue = 1.0;
      // Menambahkan tearDown untuk membersihkan pengaturan setelah test
      addTearDown(() {
        // Menghapus pengaturan ukuran layar test
        binding.window.clearPhysicalSizeTestValue();
        // Menghapus pengaturan rasio piksel test
        binding.window.clearDevicePixelRatioTestValue();
      });

      // Membungkus pengujian dengan mockNetworkImagesFor untuk mock gambar jaringan
      mockNetworkImagesFor(() async {
        // Membuat 8 vendor mock untuk pengujian
        final mockVendors = List.generate(8, (i) {
          return Vendormodel(
            kategori: 'Test Kategori', // Kategori vendor
            penyedia: [
              Penyedia(
                nama: 'Test Vendor ${i + 1}', // Nama vendor
                deskripsi: 'Deskripsi', // Deskripsi vendor
                rating: 4.5, // Rating vendor
                harga: Harga(
                  basic: TipePaket(harga: 100, jasa: 'basic'), // Paket basic
                  premium: TipePaket(
                    harga: 200,
                    jasa: 'premium',
                  ), // Paket premium
                  custom: TipePaket(harga: 300, jasa: 'custom'), // Paket custom
                ),
                testimoni: [], // Daftar testimoni kosong
                email: 'test@test.com', // Email vendor
                password: 'password', // Password vendor
                telepon: '123', // Nomor telepon vendor
                image: 'https://via.placeholder.com/150', // URL gambar vendor
              ),
            ],
          );
        });

        // Mengatur mock getData() untuk mengembalikan daftar vendor mock
        when(mockVendordatabase.getData()).thenAnswer((_) async => mockVendors);

        // Membangun widget dengan provider yang diperlukan
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              // Menyediakan mock SessionManager
              Provider<SessionManager>.value(value: mockSessionManager),
              // Menyediakan mock Vendordatabase
              Provider<Vendordatabase>.value(value: mockVendordatabase),
              // Menyediakan mock LanguageProvider dengan ChangeNotifier
              ChangeNotifierProvider<LanguageProvider>.value(
                value: mockLanguageProvider,
              ),
            ],
            child: MaterialApp(
              // Mengatur delegate lokalisasi
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              // Mengatur locale yang didukung
              supportedLocales: AppLocalizations.supportedLocales,
              // Menampilkan HomePage dengan fungsi compute palsu
              home: HomePage(computeFunc: fakeCompute),
            ),
          ),
        );
        // Memproses satu frame untuk memulai FutureBuilder
        await tester.pump();
        // Menunggu FutureBuilder selesai dan rebuild
        await tester.pumpAndSettle();

        // Memverifikasi bahwa ada tepat 8 kartu vendor dengan key 'vendorCardRating'
        expect(find.byKey(const Key('vendorCardRating')), findsNWidgets(8));
      });
    });

    // Test case: Memverifikasi 8 gambar vendor dimuat dan ditampilkan
    testWidgets('loads and displays 8 vendor images', (
      WidgetTester tester,
    ) async {
      // Mendapatkan instance binding untuk mengatur ukuran layar
      final binding = TestWidgetsFlutterBinding.instance;
      // Mengatur ukuran layar fisik untuk pengujian (3000x1800 piksel)
      binding.window.physicalSizeTestValue = const Size(3000, 1800);
      // Mengatur rasio piksel perangkat menjadi 1.0
      binding.window.devicePixelRatioTestValue = 1.0;
      // Menambahkan tearDown untuk membersihkan pengaturan setelah test
      addTearDown(() {
        // Menghapus pengaturan ukuran layar test
        binding.window.clearPhysicalSizeTestValue();
        // Menghapus pengaturan rasio piksel test
        binding.window.clearDevicePixelRatioTestValue();
      });

      // Membungkus pengujian dengan mockNetworkImagesFor untuk mock gambar jaringan
      mockNetworkImagesFor(() async {
        // Membuat 8 vendor mock untuk pengujian
        final mockVendors = List.generate(8, (i) {
          return Vendormodel(
            kategori: 'Test Kategori', // Kategori vendor
            penyedia: [
              Penyedia(
                nama: 'Test Vendor ${i + 1}', // Nama vendor
                deskripsi: 'Deskripsi', // Deskripsi vendor
                rating: 4.5, // Rating vendor
                harga: Harga(
                  basic: TipePaket(harga: 100, jasa: 'basic'), // Paket basic
                  premium: TipePaket(
                    harga: 200,
                    jasa: 'premium',
                  ), // Paket premium
                  custom: TipePaket(harga: 300, jasa: 'custom'), // Paket custom
                ),
                testimoni: [], // Daftar testimoni kosong
                email: 'test@test.com', // Email vendor
                password: 'password', // Password vendor
                telepon: '123', // Nomor telepon vendor
                image: 'https://via.placeholder.com/150', // URL gambar vendor
              ),
            ],
          );
        });

        // Mengatur mock getData() untuk mengembalikan daftar vendor mock
        when(mockVendordatabase.getData()).thenAnswer((_) async => mockVendors);

        // Aksi: Membangun widget dengan provider yang diperlukan
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              // Menyediakan mock SessionManager
              Provider<SessionManager>.value(value: mockSessionManager),
              // Menyediakan mock Vendordatabase
              Provider<Vendordatabase>.value(value: mockVendordatabase),
              // Menyediakan mock LanguageProvider dengan ChangeNotifier
              ChangeNotifierProvider<LanguageProvider>.value(
                value: mockLanguageProvider,
              ),
            ],
            child: MaterialApp(
              // Mengatur delegate lokalisasi
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              // Mengatur locale yang didukung
              supportedLocales: AppLocalizations.supportedLocales,
              // Menampilkan HomePage dengan fungsi compute palsu
              home: HomePage(computeFunc: fakeCompute),
            ),
          ),
        );
        // Memproses satu frame untuk memulai FutureBuilder
        await tester.pump();
        // Menunggu FutureBuilder selesai dan rebuild
        await tester.pumpAndSettle();

        // Memverifikasi bahwa ada tepat 8 gambar vendor dengan key 'vendorCardImage'
        expect(find.byKey(const Key('vendorCardImage')), findsNWidgets(8));
      });
    });

    // Test case: Memverifikasi teks bagian "Portfolio dan Review" ditampilkan
    testWidgets('displays "Portfolio and Review" section text', (
      WidgetTester tester,
    ) async {
      // Mengatur mock getData() untuk mengembalikan list kosong
      when(mockVendordatabase.getData()).thenAnswer((_) async => []);
      // Membangun widget dengan provider yang diperlukan
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            // Menyediakan mock SessionManager
            Provider<SessionManager>.value(value: mockSessionManager),
            // Menyediakan mock Vendordatabase
            Provider<Vendordatabase>.value(value: mockVendordatabase),
            // Menyediakan mock LanguageProvider dengan ChangeNotifier
            ChangeNotifierProvider<LanguageProvider>.value(
              value: mockLanguageProvider,
            ),
          ],
          child: MaterialApp(
            // Mengatur delegate lokalisasi
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            // Mengatur locale yang didukung
            supportedLocales: AppLocalizations.supportedLocales,
            // Menampilkan HomePage dengan fungsi compute palsu
            home: HomePage(computeFunc: fakeCompute),
          ),
        ),
      );

      // Memproses semua frame hingga animasi selesai
      await tester.pumpAndSettle();

      // Memverifikasi bahwa teks "Portfolio dan Review" ditemukan
      expect(
        find.text(
          AppLocalizations.of(
            tester.element(find.byType(HomePage)),
          )!.portfolioAndReview,
        ),
        findsOneWidget,
      );
    });

    // Test case: Memverifikasi teks bagian "Inspirasi dan Feed" ditampilkan
    testWidgets('displays "Inspiration and Feed" section text', (
      WidgetTester tester,
    ) async {
      // Mengatur mock getData() untuk mengembalikan list kosong
      when(mockVendordatabase.getData()).thenAnswer((_) async => []);
      // Membangun widget dengan provider yang diperlukan
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            // Menyediakan mock SessionManager
            Provider<SessionManager>.value(value: mockSessionManager),
            // Menyediakan mock Vendordatabase
            Provider<Vendordatabase>.value(value: mockVendordatabase),
            // Menyediakan mock LanguageProvider dengan ChangeNotifier
            ChangeNotifierProvider<LanguageProvider>.value(
              value: mockLanguageProvider,
            ),
          ],
          child: MaterialApp(
            // Mengatur delegate lokalisasi
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            // Mengatur locale yang didukung
            supportedLocales: AppLocalizations.supportedLocales,
            // Menampilkan HomePage dengan fungsi compute palsu
            home: HomePage(computeFunc: fakeCompute),
          ),
        ),
      );

      // Memproses semua frame hingga animasi selesai
      await tester.pumpAndSettle();

      // Memverifikasi bahwa teks "Inspirasi dan Feed" ditemukan
      expect(
        find.text(
          AppLocalizations.of(
            tester.element(find.byType(HomePage)),
          )!.inspirationAndFeed,
        ),
        findsOneWidget,
      );
    });

    // Test case: Memverifikasi tombol "Lihat Halaman Kategori" ditampilkan
    testWidgets('displays "View Category Page" button', (
      WidgetTester tester,
    ) async {
      // Mengatur mock getData() untuk mengembalikan list kosong
      when(mockVendordatabase.getData()).thenAnswer((_) async => []);
      // Membangun widget dengan provider yang diperlukan
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            // Menyediakan mock SessionManager
            Provider<SessionManager>.value(value: mockSessionManager),
            // Menyediakan mock Vendordatabase
            Provider<Vendordatabase>.value(value: mockVendordatabase),
            // Menyediakan mock LanguageProvider dengan ChangeNotifier
            ChangeNotifierProvider<LanguageProvider>.value(
              value: mockLanguageProvider,
            ),
          ],
          child: MaterialApp(
            // Mengatur delegate lokalisasi
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            // Mengatur locale yang didukung
            supportedLocales: AppLocalizations.supportedLocales,
            // Menampilkan HomePage dengan fungsi compute palsu
            home: HomePage(computeFunc: fakeCompute),
          ),
        ),
      );

      // Memproses semua frame hingga animasi selesai
      await tester.pumpAndSettle();

      // Memverifikasi bahwa teks "Lihat Halaman Kategori" ditemukan
      expect(
        find.text(
          AppLocalizations.of(
            tester.element(find.byType(HomePage)),
          )!.viewCategoryPage,
        ),
        findsOneWidget,
      );

      // Memverifikasi bahwa itu adalah ElevatedButton dengan child Text
      final buttonFinder = find.widgetWithText(
        ElevatedButton,
        AppLocalizations.of(
          tester.element(find.byType(HomePage)),
        )!.viewCategoryPage,
      );
      // Memverifikasi tombol ditemukan
      expect(buttonFinder, findsOneWidget);
    });

    // Test case: Memverifikasi kartu portfolio ditampilkan
    testWidgets('displays portfolio cards', (WidgetTester tester) async {
      // Mendapatkan instance binding untuk mengatur ukuran layar
      final binding = TestWidgetsFlutterBinding.instance;
      // Mengatur ukuran layar fisik untuk pengujian (3000x1800 piksel)
      binding.window.physicalSizeTestValue = const Size(3000, 1800);
      // Mengatur rasio piksel perangkat menjadi 1.0
      binding.window.devicePixelRatioTestValue = 1.0;
      // Menambahkan tearDown untuk membersihkan pengaturan setelah test
      addTearDown(() {
        // Menghapus pengaturan ukuran layar test
        binding.window.clearPhysicalSizeTestValue();
        // Menghapus pengaturan rasio piksel test
        binding.window.clearDevicePixelRatioTestValue();
      });

      // Membungkus pengujian dengan mockNetworkImagesFor untuk mock gambar jaringan
      mockNetworkImagesFor(() async {
        // Membuat 8 vendor mock untuk pengujian
        final mockVendors = List.generate(8, (i) {
          return Vendormodel(
            kategori: 'Test Kategori', // Kategori vendor
            penyedia: [
              Penyedia(
                nama: 'Test Vendor ${i + 1}', // Nama vendor
                deskripsi:
                    'Deskripsi Portfolio ${i + 1}', // Deskripsi portfolio
                rating: 4.5, // Rating vendor
                harga: Harga(
                  basic: TipePaket(harga: 100, jasa: 'basic'), // Paket basic
                  premium: TipePaket(
                    harga: 200,
                    jasa: 'premium',
                  ), // Paket premium
                  custom: TipePaket(harga: 300, jasa: 'custom'), // Paket custom
                ),
                testimoni: [], // Daftar testimoni kosong
                email: 'test@test.com', // Email vendor
                password: 'password', // Password vendor
                telepon: '123', // Nomor telepon vendor
                image: 'https://via.placeholder.com/150', // URL gambar vendor
              ),
            ],
          );
        });

        // Mengatur mock getData() untuk mengembalikan daftar vendor mock
        when(mockVendordatabase.getData()).thenAnswer((_) async => mockVendors);

        // Membangun widget dengan provider yang diperlukan
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              // Menyediakan mock SessionManager
              Provider<SessionManager>.value(value: mockSessionManager),
              // Menyediakan mock Vendordatabase
              Provider<Vendordatabase>.value(value: mockVendordatabase),
              // Menyediakan mock LanguageProvider dengan ChangeNotifier
              ChangeNotifierProvider<LanguageProvider>.value(
                value: mockLanguageProvider,
              ),
            ],
            child: MaterialApp(
              // Mengatur delegate lokalisasi
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              // Mengatur locale yang didukung
              supportedLocales: AppLocalizations.supportedLocales,
              // Menampilkan HomePage dengan fungsi compute palsu
              home: HomePage(computeFunc: fakeCompute),
            ),
          ),
        );

        // Memproses satu frame untuk memulai FutureBuilder
        await tester.pump();
        // Menunggu FutureBuilder selesai dan rebuild
        await tester.pumpAndSettle();

        // Kartu portfolio menampilkan nama vendor, jadi kita harus menemukan nama vendor
        // di bagian portfolio
        for (int i = 1; i <= 8; i++) {
          expect(find.text('Test Vendor $i'), findsAtLeastNWidgets(1));
        }

        // Memverifikasi kita dapat menemukan container kartu portfolio (SizedBox dengan lebar 260)
        final portfolioCardFinders = tester.widgetList<SizedBox>(
          find.byType(SizedBox),
        );
        // Variabel penghitung untuk kartu portfolio
        int portfolioCardCount = 0;
        // Iterasi melalui semua SizedBox yang ditemukan
        for (final sizedBox in portfolioCardFinders) {
          // Kartu portfolio memiliki lebar 260.0
          if (sizedBox.width == 260.0) {
            portfolioCardCount++;
          }
        }

        // Memverifikasi bahwa setidaknya ada 8 kartu portfolio
        expect(
          portfolioCardCount,
          greaterThanOrEqualTo(8),
          reason: 'Harus menampilkan setidaknya 8 kartu portfolio',
        );
      });
    });

    // Test case: Memverifikasi gambar portfolio ditampilkan
    testWidgets('displays portfolio images', (WidgetTester tester) async {
      // Mendapatkan instance binding untuk mengatur ukuran layar
      final binding = TestWidgetsFlutterBinding.instance;
      // Mengatur ukuran layar fisik untuk pengujian (3000x1800 piksel)
      binding.window.physicalSizeTestValue = const Size(3000, 1800);
      // Mengatur rasio piksel perangkat menjadi 1.0
      binding.window.devicePixelRatioTestValue = 1.0;
      // Menambahkan tearDown untuk membersihkan pengaturan setelah test
      addTearDown(() {
        // Menghapus pengaturan ukuran layar test
        binding.window.clearPhysicalSizeTestValue();
        // Menghapus pengaturan rasio piksel test
        binding.window.clearDevicePixelRatioTestValue();
      });

      // Membungkus pengujian dengan mockNetworkImagesFor untuk mock gambar jaringan
      mockNetworkImagesFor(() async {
        // Membuat 8 vendor mock untuk pengujian
        final mockVendors = List.generate(8, (i) {
          return Vendormodel(
            kategori: 'Test Kategori', // Kategori vendor
            penyedia: [
              Penyedia(
                nama: 'Test Vendor ${i + 1}', // Nama vendor
                deskripsi: 'Deskripsi', // Deskripsi vendor
                rating: 4.5, // Rating vendor
                harga: Harga(
                  basic: TipePaket(harga: 100, jasa: 'basic'), // Paket basic
                  premium: TipePaket(
                    harga: 200,
                    jasa: 'premium',
                  ), // Paket premium
                  custom: TipePaket(harga: 300, jasa: 'custom'), // Paket custom
                ),
                testimoni: [], // Daftar testimoni kosong
                email: 'test@test.com', // Email vendor
                password: 'password', // Password vendor
                telepon: '123', // Nomor telepon vendor
                image: 'https://via.placeholder.com/150', // URL gambar vendor
              ),
            ],
          );
        });

        // Mengatur mock getData() untuk mengembalikan daftar vendor mock
        when(mockVendordatabase.getData()).thenAnswer((_) async => mockVendors);

        // Membangun widget dengan provider yang diperlukan
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              // Menyediakan mock SessionManager
              Provider<SessionManager>.value(value: mockSessionManager),
              // Menyediakan mock Vendordatabase
              Provider<Vendordatabase>.value(value: mockVendordatabase),
              // Menyediakan mock LanguageProvider dengan ChangeNotifier
              ChangeNotifierProvider<LanguageProvider>.value(
                value: mockLanguageProvider,
              ),
            ],
            child: MaterialApp(
              // Mengatur delegate lokalisasi
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              // Mengatur locale yang didukung
              supportedLocales: AppLocalizations.supportedLocales,
              // Menampilkan HomePage dengan fungsi compute palsu
              home: HomePage(computeFunc: fakeCompute),
            ),
          ),
        );

        // Memproses satu frame untuk memulai FutureBuilder
        await tester.pump();
        // Menunggu FutureBuilder selesai dan rebuild
        await tester.pumpAndSettle();

        // Kartu portfolio berisi gambar, mencari semua widget Image
        // Kita harus memiliki 8 gambar portfolio + 8 gambar kartu vendor = 16 gambar
        // Tapi mari kita verifikasi gambar portfolio ada (setidaknya 8 widget Image)
        final imageFinders = find.byType(Image);
        // Memverifikasi bahwa setidaknya ada 8 gambar portfolio
        expect(
          imageFinders,
          findsAtLeastNWidgets(8),
          reason: 'Harus menampilkan setidaknya 8 gambar portfolio',
        );
      });
    });

    // Test case: Memverifikasi item feed ditampilkan
    testWidgets('displays feed items', (WidgetTester tester) async {
      // Mendapatkan instance binding untuk mengatur ukuran layar
      final binding = TestWidgetsFlutterBinding.instance;
      // Mengatur ukuran layar fisik untuk pengujian (3000x1800 piksel)
      binding.window.physicalSizeTestValue = const Size(3000, 1800);
      // Mengatur rasio piksel perangkat menjadi 1.0
      binding.window.devicePixelRatioTestValue = 1.0;
      // Menambahkan tearDown untuk membersihkan pengaturan setelah test
      addTearDown(() {
        // Menghapus pengaturan ukuran layar test
        binding.window.clearPhysicalSizeTestValue();
        // Menghapus pengaturan rasio piksel test
        binding.window.clearDevicePixelRatioTestValue();
      });

      // Membungkus pengujian dengan mockNetworkImagesFor untuk mock gambar jaringan
      mockNetworkImagesFor(() async {
        // Membuat 8 vendor mock untuk pengujian
        final mockVendors = List.generate(8, (i) {
          return Vendormodel(
            kategori: 'Test Kategori', // Kategori vendor
            penyedia: [
              Penyedia(
                nama: 'Test Vendor ${i + 1}', // Nama vendor
                deskripsi: 'Deskripsi Feed ${i + 1}', // Deskripsi feed
                rating: 4.5, // Rating vendor
                harga: Harga(
                  basic: TipePaket(harga: 100, jasa: 'basic'), // Paket basic
                  premium: TipePaket(
                    harga: 200,
                    jasa: 'premium',
                  ), // Paket premium
                  custom: TipePaket(harga: 300, jasa: 'custom'), // Paket custom
                ),
                testimoni: [], // Daftar testimoni kosong
                email: 'test@test.com', // Email vendor
                password: 'password', // Password vendor
                telepon: '123', // Nomor telepon vendor
                image: 'https://via.placeholder.com/150', // URL gambar vendor
              ),
            ],
          );
        });

        // Mengatur mock getData() untuk mengembalikan daftar vendor mock
        when(mockVendordatabase.getData()).thenAnswer((_) async => mockVendors);

        // Membangun widget dengan provider yang diperlukan
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              // Menyediakan mock SessionManager
              Provider<SessionManager>.value(value: mockSessionManager),
              // Menyediakan mock Vendordatabase
              Provider<Vendordatabase>.value(value: mockVendordatabase),
              // Menyediakan mock LanguageProvider dengan ChangeNotifier
              ChangeNotifierProvider<LanguageProvider>.value(
                value: mockLanguageProvider,
              ),
            ],
            child: MaterialApp(
              // Mengatur delegate lokalisasi
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              // Mengatur locale yang didukung
              supportedLocales: AppLocalizations.supportedLocales,
              // Menampilkan HomePage dengan fungsi compute palsu
              home: HomePage(computeFunc: fakeCompute),
            ),
          ),
        );

        // Memproses satu frame untuk memulai FutureBuilder
        await tester.pump();
        // Menunggu FutureBuilder selesai dan rebuild
        await tester.pumpAndSettle();

        // Item feed menampilkan nama vendor, verifikasi mereka muncul
        // Item feed berada dalam SizedBox dengan lebar 300
        final feedItemFinders = tester.widgetList<SizedBox>(
          find.byType(SizedBox),
        );
        // Variabel penghitung untuk item feed
        int feedItemCount = 0;
        // Iterasi melalui semua SizedBox yang ditemukan
        for (final sizedBox in feedItemFinders) {
          // Item feed memiliki lebar 300.0
          if (sizedBox.width == 300.0) {
            feedItemCount++;
          }
        }

        // Memverifikasi bahwa setidaknya ada 8 item feed
        expect(
          feedItemCount,
          greaterThanOrEqualTo(8),
          reason: 'Harus menampilkan setidaknya 8 item feed',
        );
      });
    });

    // Test case: Memverifikasi gambar feed ditampilkan
    testWidgets('displays feed images', (WidgetTester tester) async {
      // Mendapatkan instance binding untuk mengatur ukuran layar
      final binding = TestWidgetsFlutterBinding.instance;
      // Mengatur ukuran layar fisik untuk pengujian (3000x1800 piksel)
      binding.window.physicalSizeTestValue = const Size(3000, 1800);
      // Mengatur rasio piksel perangkat menjadi 1.0
      binding.window.devicePixelRatioTestValue = 1.0;
      // Menambahkan tearDown untuk membersihkan pengaturan setelah test
      addTearDown(() {
        // Menghapus pengaturan ukuran layar test
        binding.window.clearPhysicalSizeTestValue();
        // Menghapus pengaturan rasio piksel test
        binding.window.clearDevicePixelRatioTestValue();
      });

      // Membungkus pengujian dengan mockNetworkImagesFor untuk mock gambar jaringan
      mockNetworkImagesFor(() async {
        // Membuat 8 vendor mock untuk pengujian
        final mockVendors = List.generate(8, (i) {
          return Vendormodel(
            kategori: 'Test Kategori', // Kategori vendor
            penyedia: [
              Penyedia(
                nama: 'Test Vendor ${i + 1}', // Nama vendor
                deskripsi: 'Deskripsi', // Deskripsi vendor
                rating: 4.5, // Rating vendor
                harga: Harga(
                  basic: TipePaket(harga: 100, jasa: 'basic'), // Paket basic
                  premium: TipePaket(
                    harga: 200,
                    jasa: 'premium',
                  ), // Paket premium
                  custom: TipePaket(harga: 300, jasa: 'custom'), // Paket custom
                ),
                testimoni: [], // Daftar testimoni kosong
                email: 'test@test.com', // Email vendor
                password: 'password', // Password vendor
                telepon: '123', // Nomor telepon vendor
                image: 'https://via.placeholder.com/150', // URL gambar vendor
              ),
            ],
          );
        });

        // Mengatur mock getData() untuk mengembalikan daftar vendor mock
        when(mockVendordatabase.getData()).thenAnswer((_) async => mockVendors);

        // Membangun widget dengan provider yang diperlukan
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              // Menyediakan mock SessionManager
              Provider<SessionManager>.value(value: mockSessionManager),
              // Menyediakan mock Vendordatabase
              Provider<Vendordatabase>.value(value: mockVendordatabase),
              // Menyediakan mock LanguageProvider dengan ChangeNotifier
              ChangeNotifierProvider<LanguageProvider>.value(
                value: mockLanguageProvider,
              ),
            ],
            child: MaterialApp(
              // Mengatur delegate lokalisasi
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              // Mengatur locale yang didukung
              supportedLocales: AppLocalizations.supportedLocales,
              // Menampilkan HomePage dengan fungsi compute palsu
              home: HomePage(computeFunc: fakeCompute),
            ),
          ),
        );

        // Memproses satu frame untuk memulai FutureBuilder
        await tester.pump();
        // Menunggu FutureBuilder selesai dan rebuild
        await tester.pumpAndSettle();

        // Item feed berisi gambar, verifikasi widget Image ada
        // Total gambar: 8 kartu vendor + 8 portfolio + 8 feed = setidaknya 16
        final imageFinders = find.byType(Image);
        // Memverifikasi bahwa setidaknya ada 16 gambar (vendor + portfolio + feed)
        expect(
          imageFinders,
          findsAtLeastNWidgets(16),
          reason:
              'Harus menampilkan setidaknya 16 gambar (vendor + portfolio + feed)',
        );
      });
    });

    // Test case: Memverifikasi indikator loading untuk portfolio ditampilkan
    testWidgets('shows loading indicator for portfolios', (
      WidgetTester tester,
    ) async {
      // Menggunakan Future dengan delay untuk memastikan state loading terlihat
      when(mockVendordatabase.getData()).thenAnswer((_) async {
        // Menunda 100 milidetik untuk mensimulasikan loading
        await Future.delayed(const Duration(milliseconds: 100));
        return [];
      });

      // Membangun widget dengan provider yang diperlukan
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            // Menyediakan mock SessionManager
            Provider<SessionManager>.value(value: mockSessionManager),
            // Menyediakan mock Vendordatabase
            Provider<Vendordatabase>.value(value: mockVendordatabase),
            // Menyediakan mock LanguageProvider dengan ChangeNotifier
            ChangeNotifierProvider<LanguageProvider>.value(
              value: mockLanguageProvider,
            ),
          ],
          child: MaterialApp(
            // Mengatur delegate lokalisasi
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            // Mengatur locale yang didukung
            supportedLocales: AppLocalizations.supportedLocales,
            // Menampilkan HomePage dengan fungsi compute palsu
            home: HomePage(computeFunc: fakeCompute),
          ),
        ),
      );

      // Memproses satu frame untuk memulai FutureBuilder
      await tester.pump();

      // Sebelum data dimuat, harus melihat CircularProgressIndicator
      // Ada 3 FutureBuilder: vendors, portfolios, feeds
      expect(find.byType(CircularProgressIndicator), findsAtLeastNWidgets(1));

      // Menunggu data dimuat dengan timeout 5 detik
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Setelah loading, CircularProgressIndicator harus hilang
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    // Test case: Memverifikasi indikator loading untuk feed ditampilkan
    testWidgets('shows loading indicator for feeds', (
      WidgetTester tester,
    ) async {
      // Menggunakan Future dengan delay untuk memastikan state loading terlihat
      when(mockVendordatabase.getData()).thenAnswer((_) async {
        // Menunda 100 milidetik untuk mensimulasikan loading
        await Future.delayed(const Duration(milliseconds: 100));
        return [];
      });

      // Membangun widget dengan provider yang diperlukan
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            // Menyediakan mock SessionManager
            Provider<SessionManager>.value(value: mockSessionManager),
            // Menyediakan mock Vendordatabase
            Provider<Vendordatabase>.value(value: mockVendordatabase),
            // Menyediakan mock LanguageProvider dengan ChangeNotifier
            ChangeNotifierProvider<LanguageProvider>.value(
              value: mockLanguageProvider,
            ),
          ],
          child: MaterialApp(
            // Mengatur delegate lokalisasi
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            // Mengatur locale yang didukung
            supportedLocales: AppLocalizations.supportedLocales,
            // Menampilkan HomePage dengan fungsi compute palsu
            home: HomePage(computeFunc: fakeCompute),
          ),
        ),
      );

      // Memproses satu frame untuk memulai FutureBuilder
      await tester.pump();

      // Sebelum data dimuat, harus melihat CircularProgressIndicator untuk feed
      // Ada 3 FutureBuilder: vendors, portfolios, feeds
      expect(find.byType(CircularProgressIndicator), findsAtLeastNWidgets(1));

      // Menunggu data dimuat dengan timeout 5 detik
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Setelah loading, CircularProgressIndicator harus hilang
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });
}
