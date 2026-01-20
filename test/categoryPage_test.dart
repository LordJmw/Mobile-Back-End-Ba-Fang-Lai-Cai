import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projek_uts_mbr/category/category.dart';
import 'package:projek_uts_mbr/model/VendorModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('Constructor CategoryPage dapat dibuat', () {
    expect(() {
      CategoryPage(category: 'FOTOGRAFI', useSavedPreferences: false);
    }, returnsNormally);
  });

  test('getBasicPrice mengambil harga basic dari vendor', () {
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
    expect(price, 1000000);
  });

  test('getBasicPrice menangani harga 0 atau negatif', () {
    final vendor = Penyedia(
      nama: 'Free Vendor',
      deskripsi: 'Free Service',
      rating: 4.0,
      harga: Harga(
        basic: TipePaket(harga: 0, jasa: 'Free'),
        premium: TipePaket(harga: -1000, jasa: 'Invalid'),
        custom: TipePaket(harga: 500000, jasa: 'Paid'),
      ),
      testimoni: [],
      email: 'free@email.com',
      password: 'password',
      telepon: '08123456789',
      image: 'free.jpg',
    );

    final price = getBasicPrice(vendor);
    expect(price, 500000);
  });

  test('formatPrice memformat mata uang Indonesia', () {
    expect(formatPrice(1000), '1.000');
    expect(formatPrice(10000), '10.000');
    expect(formatPrice(1000000), '1.000.000');
    expect(formatPrice(1234567), '1.234.567');
    expect(formatPrice(0), '0');
    expect(formatPrice(999), '999');
  });

  test('Filter berdasarkan rentang harga', () {
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

    final rentangHarga = RangeValues(0, 1000000);
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
    expect(result[0].nama, 'Vendor 1');
  });

  test('Filter berdasarkan rating minimal', () {
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

  test('Filter tanpa kategori terpilih mengembalikan semua vendor', () {
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

    expect(result.length, 2);
  });

  test('Filter dengan kondisi default mengembalikan semua data', () {
    final testData = [
      Vendormodel(
        kategori: 'Fotografi & Videografi',
        penyedia: List.generate(
          25,
          (index) => Penyedia(
            nama: 'Vendor $index',
            deskripsi: 'Description $index',
            rating: 4.0 + (index % 5) * 0.2,
            harga: Harga(
              basic: TipePaket(harga: (index + 1) * 100000, jasa: 'Basic'),
              premium: TipePaket(harga: (index + 1) * 200000, jasa: 'Premium'),
              custom: TipePaket(harga: (index + 1) * 300000, jasa: 'Custom'),
            ),
            testimoni: [],
            email: 'vendor$index@email.com',
            password: 'pass$index',
            telepon: '081111111$index',
            image: 'test$index.jpg',
          ),
        ),
      ),
    ];

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

    expect(result.length, 25);
  });

  test('Filter dengan rentang harga tidak valid', () {
    final testData = [
      Vendormodel(
        kategori: 'Fotografi & Videografi',
        penyedia: [
          Penyedia(
            nama: 'Expensive Vendor',
            deskripsi: 'Very expensive',
            rating: 4.5,
            harga: Harga(
              basic: TipePaket(harga: 50000000, jasa: 'Basic'),
              premium: TipePaket(harga: 100000000, jasa: 'Premium'),
              custom: TipePaket(harga: 150000000, jasa: 'Custom'),
            ),
            testimoni: [],
            email: 'expensive@email.com',
            password: 'pass',
            telepon: '0811111111',
            image: 'expensive.jpg',
          ),
        ],
      ),
    ];

    final rentangHarga = RangeValues(10000000, 20000000);
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

    expect(result.length, 0);
  });

  test('getBasicPrice dengan struktur harga custom', () {
    final vendor = Penyedia(
      nama: 'Custom Only Vendor',
      deskripsi: 'Only custom packages',
      rating: 4.0,
      harga: Harga(
        basic: TipePaket(harga: 0, jasa: 'Not available'),
        premium: TipePaket(harga: -1, jasa: 'Not available'),
        custom: TipePaket(harga: 500000, jasa: 'Custom Package'),
      ),
      testimoni: [],
      email: 'custom@email.com',
      password: 'password',
      telepon: '08123456789',
      image: 'custom.jpg',
    );

    final price = getBasicPrice(vendor);
    expect(price, 500000);
  });

  test('CategoryPage membuat state dengan benar', () {
    final widget = CategoryPage(
      category: 'FOTOGRAFI',
      useSavedPreferences: false,
    );

    final state = widget.createState();
    expect(state, isNotNull);
    expect(state.runtimeType.toString(), '_CategoryPageState');
  });

  test('Parameter CategoryPage tersimpan dengan benar', () {
    final categoryPage = CategoryPage(
      category: 'FOTOGRAFI',
      useSavedPreferences: false,
    );

    expect(categoryPage.category, 'FOTOGRAFI');
    expect(categoryPage.useSavedPreferences, false);
  });
}
