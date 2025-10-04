class Vendormodel {
  final String nama;
  final String deskripsi;
  final double rating;
  final String harga;
  final String testimoni;
  final String email;
  final String telepon;
  final String image;
  final String kategori;

  Vendormodel({
    required this.nama,
    required this.deskripsi,
    required this.rating,
    required this.harga,
    required this.testimoni,
    required this.email,
    required this.telepon,
    required this.image,
    required this.kategori,
  });

  //agar hasil kueri diubah ke tipe data yang sesuai
  static Vendormodel fromMap(Map<String, dynamic> map) {
    return Vendormodel(
      nama: map['nama'],
      deskripsi: map['deskripsi'],
      rating: (map['rating'] as num).toDouble(),
      harga: map['harga'],
      testimoni: map['testimoni'],
      email: map['email'],
      telepon: map['telepon'],
      image: map['image'],
      kategori: map['kategori'],
    );
  }

  //untuk insert ke sqlite
  Map<String, dynamic> toMap() {
    return {
      'nama': nama,
      'deskripsi': deskripsi,
      'rating': rating,
      'harga': harga,
      'testimoni': testimoni,
      'email': email,
      'telepon': telepon,
      'image': image,
      'kategori': kategori,
    };
  }
}
