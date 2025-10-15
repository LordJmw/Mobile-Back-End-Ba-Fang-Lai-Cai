class CustomerModel {
  final int? id;
  final String nama;
  final String email;
  final String password;
  final String telepon;
  final String alamat;

  CustomerModel({
    this.id,
    required this.nama,
    required this.email,
    required this.password,
    required this.telepon,
    required this.alamat,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'email': email,
      'password': password,
      'telepon': telepon,
      'alamat': alamat,
    };
  }

  factory CustomerModel.fromJson(Map<String, dynamic> map) {
    return CustomerModel(
      id: map['id'],
      nama: map['nama'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      telepon: map['telepon'] ?? '',
      alamat: map['alamat'] ?? '',
    );
  }
}
