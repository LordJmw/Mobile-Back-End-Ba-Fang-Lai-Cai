// To parse this JSON data, do
//
//     final vendormodel = vendormodelFromJson(jsonString);

import 'dart:convert';

List<Vendormodel> vendormodelFromJson(String str) => List<Vendormodel>.from(
  json.decode(str).map((x) => Vendormodel.fromJson(x)),
);

String vendormodelToJson(List<Vendormodel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Vendormodel {
  String kategori;
  List<Penyedia> penyedia;

  Vendormodel({required this.kategori, required this.penyedia});

  factory Vendormodel.fromJson(Map<String, dynamic> json) => Vendormodel(
    kategori: json["kategori"] ?? "",
    penyedia: json["penyedia"] == null
        ? []
        : List<Penyedia>.from(
            json["penyedia"].map((x) => Penyedia.fromJson(x)),
          ),
  );

  Map<String, dynamic> toJson() => {
    "kategori": kategori,
    "penyedia": List<dynamic>.from(penyedia.map((x) => x.toJson())),
  };
}

class Penyedia {
  String nama;
  String deskripsi;
  double rating;
  Harga harga;
  List<Testimoni> testimoni;
  String email;
  String password;
  String telepon;
  String image;

  Penyedia({
    required this.nama,
    required this.deskripsi,
    required this.rating,
    required this.harga,
    required this.testimoni,
    required this.email,
    required this.password,
    required this.telepon,
    required this.image,
  });

  factory Penyedia.fromJson(Map<String, dynamic> json) => Penyedia(
    nama: json["nama"],
    deskripsi: json["deskripsi"],
    rating: json["rating"]?.toDouble(),
    harga: Harga.fromJson(json["harga"]),
    testimoni: List<Testimoni>.from(
      json["testimoni"].map((x) => Testimoni.fromJson(x)),
    ),
    email: json["email"],
    password: json["password"],
    telepon: json["telepon"],
    image: json["image"],
  );

  Map<String, dynamic> toJson() => {
    "nama": nama,
    "deskripsi": deskripsi,
    "rating": rating,
    "harga": harga.toJson(),
    "testimoni": List<dynamic>.from(testimoni.map((x) => x.toJson())),
    "email": email,
    "password": password,
    "telepon": telepon,
    "image": image,
  };
}

class Harga {
  TipePaket basic;
  TipePaket premium;
  TipePaket custom;

  Harga({required this.basic, required this.premium, required this.custom});

  factory Harga.fromJson(Map<String, dynamic> json) => Harga(
    basic: TipePaket.fromJson(json["basic"]),
    premium: TipePaket.fromJson(json["premium"]),
    custom: TipePaket.fromJson(json["custom"]),
  );

  Map<String, dynamic> toJson() => {
    "basic": basic.toJson(),
    "premium": premium.toJson(),
    "custom": custom.toJson(),
  };
}

class TipePaket {
  int harga;
  String jasa;

  TipePaket({required this.harga, required this.jasa});

  factory TipePaket.fromJson(Map<String, dynamic> json) =>
      TipePaket(harga: json["harga"], jasa: json["jasa"]);

  Map<String, dynamic> toJson() => {"harga": harga, "jasa": jasa};
}

class Testimoni {
  String nama;
  String isi;
  int rating;

  Testimoni({required this.nama, required this.isi, required this.rating});

  factory Testimoni.fromJson(Map<String, dynamic> json) =>
      Testimoni(nama: json["nama"], isi: json["isi"], rating: json["rating"]);

  Map<String, dynamic> toJson() => {"nama": nama, "isi": isi, "rating": rating};
}
