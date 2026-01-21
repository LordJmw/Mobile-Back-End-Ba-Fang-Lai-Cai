import 'package:flutter_test/flutter_test.dart';
import 'package:projek_uts_mbr/viewall.dart';
import 'package:projek_uts_mbr/model/VendorModel.dart';

void main() {
  // ===== helper dummy data =====
  TipePaket paket() => TipePaket(harga: 100000, jasa: 'Basic');

  Harga harga() => Harga(basic: paket(), premium: paket(), custom: paket());

  List<Testimoni> testimoni() => [
    Testimoni(nama: 'User', isi: 'Bagus', rating: 5),
  ];

  Penyedia buatPenyedia(String nama) => Penyedia(
    nama: nama,
    deskripsi: 'Deskripsi $nama',
    rating: 4.5,
    harga: harga(),
    testimoni: testimoni(),
    email: '$nama@mail.com',
    password: '123',
    telepon: '0811',
    image: '$nama.png',
  );

  // ================== TEST ==================

  test('1. flattenVendorData menggabungkan semua penyedia', () {
    final data = [
      Vendormodel(kategori: 'Catering', penyedia: [buatPenyedia('A')]),
      Vendormodel(kategori: 'Dekorasi', penyedia: [buatPenyedia('B')]),
    ];

    final result = flattenVendorData(data);

    expect(result.length, 2);
  });

  test('2. flattenVendorData mengembalikan list kosong jika input kosong', () {
    final result = flattenVendorData([]);
    expect(result, isEmpty);
  });

  test(
    '3. flattenVendorData tetap berjalan jika salah satu kategori kosong',
    () {
      final data = [
        Vendormodel(kategori: 'Catering', penyedia: []),
        Vendormodel(kategori: 'Fotografi', penyedia: [buatPenyedia('C')]),
      ];

      final result = flattenVendorData(data);

      expect(result.length, 1);
      expect(result.first.nama, 'C');
    },
  );

  test('4. filterVendorByQuery memfilter berdasarkan nama', () {
    final vendors = [
      buatPenyedia('Wedding Organizer'),
      buatPenyedia('Catering Enak'),
    ];

    final result = filterVendorByQuery({
      'vendors': vendors,
      'query': 'wedding',
    });

    expect(result.length, 1);
    expect(result.first.nama, 'Wedding Organizer');
  });

  test('5. filterVendorByQuery memfilter berdasarkan deskripsi', () {
    final vendor = buatPenyedia('Dekorasi');
    vendor.deskripsi = 'Dekorasi mewah elegan';

    final result = filterVendorByQuery({
      'vendors': [vendor],
      'query': 'mewah',
    });

    expect(result.length, 1);
  });

  test('6. filterVendorByQuery mengembalikan kosong jika tidak cocok', () {
    final vendors = [buatPenyedia('Sound System'), buatPenyedia('Lighting')];

    final result = filterVendorByQuery({
      'vendors': vendors,
      'query': 'catering',
    });

    expect(result, isEmpty);
  });
}
