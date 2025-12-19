class CustomerModel {
  final String? id;
  final String nama;
  final String email;
  final String password;
  final String telepon;
  final String alamat;
  final String? fotoProfil;
  final bool isPremiumUser;
  final DateTime? premiumExpiryDate;
  final DateTime? premiumStartDate;

  CustomerModel({
    this.id,
    required this.nama,
    required this.email,
    required this.password,
    required this.telepon,
    required this.alamat,
    this.fotoProfil,
    this.isPremiumUser = false,
    this.premiumExpiryDate,
    this.premiumStartDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'email': email,
      'password': password,
      'telepon': telepon,
      'alamat': alamat,
      'fotoProfil': fotoProfil,
      'isPremiumUser': isPremiumUser,
      'premiumExpiryDate': premiumExpiryDate?.toIso8601String(),
      'premiumStartDate': premiumStartDate?.toIso8601String(),
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
      fotoProfil: map['fotoProfil'],
      isPremiumUser: map['isPremiumUser'] ?? false,
      premiumExpiryDate: map['premiumExpiryDate'] != null
          ? DateTime.tryParse(map['premiumExpiryDate'])
          : null,
      premiumStartDate: map['premiumStartDate'] != null
          ? DateTime.tryParse(map['premiumStartDate'])
          : null,
    );
  }

  //ini supaya kalau mau update customer pemanggilannya lebih singkat
  CustomerModel copyWith({
    String? id,
    String? nama,
    String? email,
    String? password,
    String? telepon,
    String? alamat,
    String? fotoProfil,
    bool? isPremiumUser,
    DateTime? premiumExpiryDate,
    DateTime? premiumStartDate,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      email: email ?? this.email,
      password: password ?? this.password,
      telepon: telepon ?? this.telepon,
      alamat: alamat ?? this.alamat,
      fotoProfil: fotoProfil ?? this.fotoProfil,
      isPremiumUser: isPremiumUser ?? this.isPremiumUser,
      premiumExpiryDate: premiumExpiryDate ?? this.premiumExpiryDate,
      premiumStartDate: premiumStartDate ?? this.premiumStartDate,
    );
  }

  bool get isPremiumActive {
    if (!isPremiumUser) return false;

    return DateTime.now().isBefore(premiumExpiryDate!);
  }

  bool get isPremiumExpired {
    if (!isPremiumUser || premiumExpiryDate == null) return false;
    return DateTime.now().isAfter(premiumExpiryDate!);
  }

  String get premiumStatusText {
    if (!isPremiumUser) return 'Free User';
    if (isPremiumExpired) return 'Premium Expired';
    final daysLeft = premiumDaysLeft;
    if (daysLeft != null && daysLeft > 0) {
      return 'Premium Active • $daysLeft days left';
    }
    return 'Premium Active';
  }

  int? get premiumDaysLeft {
    if (!isPremiumUser || premiumExpiryDate == null) return null;
    final now = DateTime.now();
    if (now.isAfter(premiumExpiryDate!)) return 0;
    return premiumExpiryDate!.difference(now).inDays;
  }
}
