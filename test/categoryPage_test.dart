import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projek_uts_mbr/category/category.dart';
import 'package:projek_uts_mbr/model/VendorModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // Setup sebelum setiap test
  setUp(() {
    // Reset SharedPreferences sebelum setiap test
    SharedPreferences.setMockInitialValues({});
  });

  // TEST 2: getBasicPrice mengambil harga basic dari vendor
  test('getBasicPrice should return basic price from vendor', () {
    // Mock vendor dengan harga
    final vendor = Penyedia(
      nama: 'Test Vendor',
      deskripsi: 'Test Description',
      rating: 4.5,
      harga: Harga(
        basic: TipePaket(harga: 1000000, jasa: 'Basic Service'),
        premium: TipePaket(harga: 2000000, jasa: 'Premium Service'),
        custom: TipePaket(harga: 3000000, jasa: 'Custom Service'),
      ),
      testimoni: [],
      email: 'test@email.com',
      password: 'password',
      telepon: '08123456789',
      image: 'test.jpg',
    );

    final price = getBasicPrice(vendor);
    expect(price, 1000000); // Harus mengambil harga dari basic package
  });

  // TEST 4: Filter data berdasarkan rentang harga
  test('Filter should filter by price range correctly', () async {
    // Setup initial data
    final testData = [
      Vendormodel(
        kategori: 'Fotografi & Videografi',
        penyedia: [
          Penyedia(
            nama: 'Vendor 1',
            deskripsi: 'Description 1',
            rating: 4.5,
            harga: Harga(
              basic: TipePaket(harga: 500000, jasa: 'Basic'),
              premium: TipePaket(harga: 1000000, jasa: 'Premium'),
              custom: TipePaket(harga: 1500000, jasa: 'Custom'),
            ),
            testimoni: [],
            email: 'vendor1@email.com',
            password: 'pass1',
            telepon: '0811111111',
            image: 'test1.jpg',
          ),
          Penyedia(
            nama: 'Vendor 2',
            deskripsi: 'Description 2',
            rating: 4.0,
            harga: Harga(
              basic: TipePaket(harga: 2000000, jasa: 'Basic'),
              premium: TipePaket(harga: 3000000, jasa: 'Premium'),
              custom: TipePaket(harga: 4000000, jasa: 'Custom'),
            ),
            testimoni: [],
            email: 'vendor2@email.com',
            password: 'pass2',
            telepon: '0822222222',
            image: 'test2.jpg',
          ),
        ],
      ),
    ];

    // Simulasi filter logic
    final rentangHarga = RangeValues(0, 1000000);
    final jumlahBintang = 0;
    final layananDipilih = List.filled(9, false);
    layananDipilih[0] = true; // Fotografi

    final selectedService = ['Fotografi & Videografi'];

    List<Penyedia> result = [];
    for (var vendorModel in testData) {
      for (var penyedia in vendorModel.penyedia) {
        final kategoriName = vendorModel.kategori;
        final hargaBasic = penyedia.harga.basic.harga;
        final rating = penyedia.rating;

        bool matchesPrice =
            hargaBasic >= rentangHarga.start && hargaBasic <= rentangHarga.end;
        bool matchesRating = jumlahBintang == 0 || rating >= jumlahBintang;
        bool matchesService =
            selectedService.isEmpty || selectedService.contains(kategoriName);

        if (matchesPrice && matchesRating && matchesService) {
          result.add(penyedia);
        }
      }
    }

    expect(result.length, 1);
    expect(result[0].nama, 'Vendor 1');
  });

  // TEST 5: Filter data berdasarkan rating minimal
  test('Filter should filter by minimum rating correctly', () async {
    final testData = [
      Vendormodel(
        kategori: 'Fotografi & Videografi',
        penyedia: [
          Penyedia(
            nama: 'Vendor High Rating',
            deskripsi: 'High rated vendor',
            rating: 4.8,
            harga: Harga(
              basic: TipePaket(harga: 500000, jasa: 'Basic'),
              premium: TipePaket(harga: 1000000, jasa: 'Premium'),
              custom: TipePaket(harga: 1500000, jasa: 'Custom'),
            ),
            testimoni: [],
            email: 'high@email.com',
            password: 'pass',
            telepon: '0811111111',
            image: 'high.jpg',
          ),
          Penyedia(
            nama: 'Vendor Low Rating',
            deskripsi: 'Low rated vendor',
            rating: 3.2,
            harga: Harga(
              basic: TipePaket(harga: 300000, jasa: 'Basic'),
              premium: TipePaket(harga: 600000, jasa: 'Premium'),
              custom: TipePaket(harga: 900000, jasa: 'Custom'),
            ),
            testimoni: [],
            email: 'low@email.com',
            password: 'pass',
            telepon: '0822222222',
            image: 'low.jpg',
          ),
        ],
      ),
    ];

    // Filter dengan rating minimal 4
    final rentangHarga = RangeValues(0, 10000000);
    final jumlahBintang = 4;
    final selectedService = ['Fotografi & Videografi'];

    List<Penyedia> result = [];
    for (var vendorModel in testData) {
      for (var penyedia in vendorModel.penyedia) {
        final kategoriName = vendorModel.kategori;
        final hargaBasic = penyedia.harga.basic.harga;
        final rating = penyedia.rating;

        bool matchesPrice =
            hargaBasic >= rentangHarga.start && hargaBasic <= rentangHarga.end;
        bool matchesRating = jumlahBintang == 0 || rating >= jumlahBintang;
        bool matchesService =
            selectedService.isEmpty || selectedService.contains(kategoriName);

        if (matchesPrice && matchesRating && matchesService) {
          result.add(penyedia);
        }
      }
    }

    expect(result.length, 1);
    expect(result[0].nama, 'Vendor High Rating');
    expect(result[0].rating, greaterThanOrEqualTo(4.0));
  });

  // TEST 6: Filter data berdasarkan kategori spesifik
  test('Filter should filter by specific category correctly', () async {
    final testData = [
      Vendormodel(
        kategori: 'Fotografi & Videografi',
        penyedia: [
          Penyedia(
            nama: 'Photography Vendor',
            deskripsi: 'Photography services',
            rating: 4.5,
            harga: Harga(
              basic: TipePaket(harga: 500000, jasa: 'Basic'),
              premium: TipePaket(harga: 1000000, jasa: 'Premium'),
              custom: TipePaket(harga: 1500000, jasa: 'Custom'),
            ),
            testimoni: [],
            email: 'photo@email.com',
            password: 'pass',
            telepon: '0811111111',
            image: 'photo.jpg',
          ),
        ],
      ),
      Vendormodel(
        kategori: 'Catering & F&B',
        penyedia: [
          Penyedia(
            nama: 'Catering Vendor',
            deskripsi: 'Catering services',
            rating: 4.5,
            harga: Harga(
              basic: TipePaket(harga: 500000, jasa: 'Basic'),
              premium: TipePaket(harga: 1000000, jasa: 'Premium'),
              custom: TipePaket(harga: 1500000, jasa: 'Custom'),
            ),
            testimoni: [],
            email: 'catering@email.com',
            password: 'pass',
            telepon: '0822222222',
            image: 'catering.jpg',
          ),
        ],
      ),
    ];

    // Hanya pilih kategori Fotografi
    final rentangHarga = RangeValues(0, 10000000);
    final jumlahBintang = 0;
    final selectedService = ['Fotografi & Videografi'];

    List<Penyedia> result = [];
    for (var vendorModel in testData) {
      for (var penyedia in vendorModel.penyedia) {
        final kategoriName = vendorModel.kategori;
        final hargaBasic = penyedia.harga.basic.harga;
        final rating = penyedia.rating;

        bool matchesPrice =
            hargaBasic >= rentangHarga.start && hargaBasic <= rentangHarga.end;
        bool matchesRating = jumlahBintang == 0 || rating >= jumlahBintang;
        bool matchesService =
            selectedService.isEmpty || selectedService.contains(kategoriName);

        if (matchesPrice && matchesRating && matchesService) {
          result.add(penyedia);
        }
      }
    }

    expect(result.length, 1);
    expect(result[0].nama, 'Photography Vendor');
  });

  // TEST 7: Filter tanpa kategori terpilih (semua kategori)
  test('Filter should return all vendors when no category selected', () async {
    final testData = [
      Vendormodel(
        kategori: 'Fotografi & Videografi',
        penyedia: [
          Penyedia(
            nama: 'Vendor 1',
            deskripsi: 'Description 1',
            rating: 4.5,
            harga: Harga(
              basic: TipePaket(harga: 500000, jasa: 'Basic'),
              premium: TipePaket(harga: 1000000, jasa: 'Premium'),
              custom: TipePaket(harga: 1500000, jasa: 'Custom'),
            ),
            testimoni: [],
            email: 'vendor1@email.com',
            password: 'pass1',
            telepon: '0811111111',
            image: 'test1.jpg',
          ),
        ],
      ),
      Vendormodel(
        kategori: 'Catering & F&B',
        penyedia: [
          Penyedia(
            nama: 'Vendor 2',
            deskripsi: 'Description 2',
            rating: 4.0,
            harga: Harga(
              basic: TipePaket(harga: 300000, jasa: 'Basic'),
              premium: TipePaket(harga: 600000, jasa: 'Premium'),
              custom: TipePaket(harga: 900000, jasa: 'Custom'),
            ),
            testimoni: [],
            email: 'vendor2@email.com',
            password: 'pass2',
            telepon: '0822222222',
            image: 'test2.jpg',
          ),
        ],
      ),
    ];

    // Tidak ada kategori yang dipilih
    final rentangHarga = RangeValues(0, 10000000);
    final jumlahBintang = 0;
    final selectedService = [];

    List<Penyedia> result = [];
    for (var vendorModel in testData) {
      for (var penyedia in vendorModel.penyedia) {
        final kategoriName = vendorModel.kategori;
        final hargaBasic = penyedia.harga.basic.harga;
        final rating = penyedia.rating;

        bool matchesPrice =
            hargaBasic >= rentangHarga.start && hargaBasic <= rentangHarga.end;
        bool matchesRating = jumlahBintang == 0 || rating >= jumlahBintang;
        bool matchesService =
            selectedService.isEmpty || selectedService.contains(kategoriName);

        if (matchesPrice && matchesRating && matchesService) {
          result.add(penyedia);
        }
      }
    }

    // Harus mendapatkan semua vendor karena tidak ada filter kategori
    expect(result.length, 2);
  });

  // TEST 8: Filter dengan multiple kategori terpilih
  test('Filter should work with multiple categories selected', () async {
    final testData = [
      Vendormodel(
        kategori: 'Fotografi & Videografi',
        penyedia: [
          Penyedia(
            nama: 'Photography Vendor',
            deskripsi: 'Photography services',
            rating: 4.5,
            harga: Harga(
              basic: TipePaket(harga: 500000, jasa: 'Basic'),
              premium: TipePaket(harga: 1000000, jasa: 'Premium'),
              custom: TipePaket(harga: 1500000, jasa: 'Custom'),
            ),
            testimoni: [],
            email: 'photo@email.com',
            password: 'pass',
            telepon: '0811111111',
            image: 'photo.jpg',
          ),
        ],
      ),
      Vendormodel(
        kategori: 'Catering & F&B',
        penyedia: [
          Penyedia(
            nama: 'Catering Vendor',
            deskripsi: 'Catering services',
            rating: 4.2,
            harga: Harga(
              basic: TipePaket(harga: 300000, jasa: 'Basic'),
              premium: TipePaket(harga: 600000, jasa: 'Premium'),
              custom: TipePaket(harga: 900000, jasa: 'Custom'),
            ),
            testimoni: [],
            email: 'catering@email.com',
            password: 'pass',
            telepon: '0822222222',
            image: 'catering.jpg',
          ),
        ],
      ),
      Vendormodel(
        kategori: 'Event Organizer & Planner',
        penyedia: [
          Penyedia(
            nama: 'EO Vendor',
            deskripsi: 'EO services',
            rating: 4.8,
            harga: Harga(
              basic: TipePaket(harga: 1000000, jasa: 'Basic'),
              premium: TipePaket(harga: 2000000, jasa: 'Premium'),
              custom: TipePaket(harga: 3000000, jasa: 'Custom'),
            ),
            testimoni: [],
            email: 'eo@email.com',
            password: 'pass',
            telepon: '0833333333',
            image: 'eo.jpg',
          ),
        ],
      ),
    ];

    // Pilih dua kategori
    final rentangHarga = RangeValues(0, 2000000);
    final jumlahBintang = 0;
    final selectedService = [
      'Fotografi & Videografi',
      'Event Organizer & Planner',
    ];

    List<Penyedia> result = [];
    for (var vendorModel in testData) {
      for (var penyedia in vendorModel.penyedia) {
        final kategoriName = vendorModel.kategori;
        final hargaBasic = penyedia.harga.basic.harga;
        final rating = penyedia.rating;

        bool matchesPrice =
            hargaBasic >= rentangHarga.start && hargaBasic <= rentangHarga.end;
        bool matchesRating = jumlahBintang == 0 || rating >= jumlahBintang;
        bool matchesService =
            selectedService.isEmpty || selectedService.contains(kategoriName);

        if (matchesPrice && matchesRating && matchesService) {
          result.add(penyedia);
        }
      }
    }

    expect(result.length, 2);
    expect(result.any((v) => v.nama == 'Photography Vendor'), true);
    expect(result.any((v) => v.nama == 'EO Vendor'), true);
    expect(result.any((v) => v.nama == 'Catering Vendor'), false);
  });

  // TEST 9: Filter dengan semua kondisi terpenuhi
  test('Filter should work with all conditions', () async {
    final testData = [
      Vendormodel(
        kategori: 'Fotografi & Videografi',
        penyedia: [
          Penyedia(
            nama: 'Perfect Match',
            deskripsi: 'Matches all conditions',
            rating: 4.7,
            harga: Harga(
              basic: TipePaket(harga: 750000, jasa: 'Basic'),
              premium: TipePaket(harga: 1500000, jasa: 'Premium'),
              custom: TipePaket(harga: 2250000, jasa: 'Custom'),
            ),
            testimoni: [],
            email: 'perfect@email.com',
            password: 'pass',
            telepon: '0811111111',
            image: 'perfect.jpg',
          ),
          Penyedia(
            nama: 'Wrong Price',
            deskripsi: 'Wrong price range',
            rating: 4.7,
            harga: Harga(
              basic: TipePaket(harga: 2500000, jasa: 'Basic'),
              premium: TipePaket(harga: 3500000, jasa: 'Premium'),
              custom: TipePaket(harga: 4500000, jasa: 'Custom'),
            ),
            testimoni: [],
            email: 'wrong@email.com',
            password: 'pass',
            telepon: '0822222222',
            image: 'wrong.jpg',
          ),
          Penyedia(
            nama: 'Wrong Rating',
            deskripsi: 'Wrong rating',
            rating: 3.5,
            harga: Harga(
              basic: TipePaket(harga: 750000, jasa: 'Basic'),
              premium: TipePaket(harga: 1500000, jasa: 'Premium'),
              custom: TipePaket(harga: 2250000, jasa: 'Custom'),
            ),
            testimoni: [],
            email: 'wrongrating@email.com',
            password: 'pass',
            telepon: '0833333333',
            image: 'wrongrating.jpg',
          ),
        ],
      ),
    ];

    // Filter ketat: harga 500k-1jt, rating min 4.5, kategori fotografi
    final rentangHarga = RangeValues(500000, 1000000);
    final jumlahBintang = 4;
    final selectedService = ['Fotografi & Videografi'];

    List<Penyedia> result = [];
    for (var vendorModel in testData) {
      for (var penyedia in vendorModel.penyedia) {
        final kategoriName = vendorModel.kategori;
        final hargaBasic = penyedia.harga.basic.harga;
        final rating = penyedia.rating;

        bool matchesPrice =
            hargaBasic >= rentangHarga.start && hargaBasic <= rentangHarga.end;
        bool matchesRating = jumlahBintang == 0 || rating >= jumlahBintang;
        bool matchesService =
            selectedService.isEmpty || selectedService.contains(kategoriName);

        if (matchesPrice && matchesRating && matchesService) {
          result.add(penyedia);
        }
      }
    }

    expect(result.length, 1);
    expect(result[0].nama, 'Perfect Match');
  });

  // TEST 10: getBasicPrice dengan struktur harga yang valid
  test('getBasicPrice should handle valid harga structure', () {
    final vendor = Penyedia(
      nama: 'Test Vendor',
      deskripsi: 'Test Description',
      rating: 4.5,
      harga: Harga(
        basic: TipePaket(harga: 1500000, jasa: 'Paket Basic'),
        premium: TipePaket(harga: 2500000, jasa: 'Paket Premium'),
        custom: TipePaket(harga: 0, jasa: 'Custom Request'),
      ),
      testimoni: [],
      email: 'test@email.com',
      password: 'password',
      telepon: '08123456789',
      image: 'test.jpg',
    );

    final price = getBasicPrice(vendor);
    expect(price, 1500000);
    expect(vendor.harga.basic.jasa, 'Paket Basic');
  });
}
