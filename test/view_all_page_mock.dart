import 'package:mockito/mockito.dart';
import 'package:projek_uts_mbr/databases/vendorDatabase.dart';
import 'package:projek_uts_mbr/model/VendorModel.dart';

// Mock class sederhana
class MockVendordatabase extends Mock implements Vendordatabase {}

class ViewAllPageMock {
  static MockVendordatabase buildMockVendorDatabase() {
    final mockDb = MockVendordatabase();

    // Data dummy vendor
    final vendorKategori = [
      Vendormodel(
        kategori: 'Fotografi & Videografi',
        penyedia: [
          Penyedia(
            nama: 'LensArt Studio',
            deskripsi: 'Fotografi dan videografi modern',
            rating: 4.2,
            harga: Harga(
              basic: TipePaket(harga: 1200000, jasa: 'Paket basic'),
              premium: TipePaket(harga: 3500000, jasa: 'Paket premium'),
              custom: TipePaket(harga: 5000000, jasa: 'Paket custom'),
            ),
            testimoni: [Testimoni(nama: 'Andi', isi: 'Bagus', rating: 4)],
            email: 'lensart@mail.com',
            password: 'password',
            telepon: '08123456789',
            image: 'https://picsum.photos/200',
          ),
          Penyedia(
            nama: 'Golden Frame',
            deskripsi: 'Mengabadikan momen',
            rating: 3.9,
            harga: Harga(
              basic: TipePaket(harga: 1000000, jasa: 'Paket basic'),
              premium: TipePaket(harga: 3000000, jasa: 'Paket premium'),
              custom: TipePaket(harga: 4500000, jasa: 'Paket custom'),
            ),
            testimoni: [Testimoni(nama: 'Lina', isi: 'Keren', rating: 4)],
            email: 'golden@mail.com',
            password: 'password',
            telepon: '08987654321',
            image: 'https://picsum.photos/201',
          ),
        ],
      ),
    ];

    // Semua penyedia dalam satu list
    final semuaPenyedia = vendorKategori
        .expand((kategori) => kategori.penyedia)
        .toList();

    // ===========================================
    // MOCK METHOD TANPA anyNamed - VERSI SEDERHANA
    // ===========================================

    // 1. Mock getData() tanpa parameter
    when(mockDb.getData()).thenAnswer((_) async => vendorKategori);

    // 2. Mock searchVendors dengan parameter khusus
    // Untuk query "lens" (case insensitive)
    when(mockDb.searchVendors('lens')).thenAnswer((_) async {
      return semuaPenyedia
          .where((p) => p.nama.toLowerCase().contains('lens'))
          .toList();
    });

    // Untuk query "golden" (case insensitive)
    when(mockDb.searchVendors('golden')).thenAnswer((_) async {
      return semuaPenyedia
          .where((p) => p.nama.toLowerCase().contains('golden'))
          .toList();
    });

    // Untuk query kosong atau null - return semua
    when(mockDb.searchVendors('')).thenAnswer((_) async => semuaPenyedia);
    when(mockDb.searchVendors('')).thenAnswer((_) async => semuaPenyedia);

    // Untuk query yang tidak ditemukan
    when(mockDb.searchVendors('tidakada')).thenAnswer((_) async => []);

    // Untuk query "studio" (bagian dari nama)
    when(mockDb.searchVendors('studio')).thenAnswer((_) async {
      return semuaPenyedia
          .where((p) => p.nama.toLowerCase().contains('studio'))
          .toList();
    });

    // Untuk query "frame" (bagian dari nama)
    when(mockDb.searchVendors('frame')).thenAnswer((_) async {
      return semuaPenyedia
          .where((p) => p.nama.toLowerCase().contains('frame'))
          .toList();
    });

    return mockDb;
  }
}
