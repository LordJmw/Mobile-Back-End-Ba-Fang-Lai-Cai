import 'dart:convert'; // Tambahkan ini

class PurchaseHistory {
  final int? id;
  final int customerId;
  final PurchaseDetails purchaseDetails;
  final DateTime purchaseDate;

  PurchaseHistory({
    this.id,
    required this.customerId,
    required this.purchaseDetails,
    required this.purchaseDate,
  });

  factory PurchaseHistory.fromMap(Map<String, dynamic> map) {
    // Handle purchase_details yang mungkin berupa String JSON atau Map
    Map<String, dynamic> purchaseDetailsMap;

    if (map['purchase_details'] is String) {
      // Jika berupa String, parse dulu menjadi Map
      purchaseDetailsMap = json.decode(map['purchase_details']);
    } else {
      // Jika sudah Map, langsung gunakan
      purchaseDetailsMap = Map<String, dynamic>.from(map['purchase_details']);
    }

    return PurchaseHistory(
      id: map['id'] as int?,
      customerId: map['customer_id'] as int,
      purchaseDetails: PurchaseDetails.fromJson(purchaseDetailsMap),
      purchaseDate: DateTime.parse(map['purchase_date'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_id': customerId,
      'purchase_details': json.encode(
        purchaseDetails.toMap(),
      ), // Konversi ke JSON string
      'purchase_date': purchaseDate.toIso8601String(),
    };
  }
}

class PurchaseDetails {
  final String vendor;
  final String packageName;
  final int price;
  final DateTime date;
  final String location;
  final String notes;
  final String status;

  PurchaseDetails({
    required this.vendor,
    required this.packageName,
    required this.price,
    required this.date,
    required this.location,
    required this.notes,
    required this.status,
  });

  factory PurchaseDetails.fromJson(Map<String, dynamic> map) {
    return PurchaseDetails(
      vendor: map['vendor'] ?? '',
      packageName: map['package'] ?? '',
      price: map['price'] is int
          ? map['price']
          : int.tryParse(map['price'].toString()) ?? 0,
      date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
      location: map['location'] ?? '',
      notes: map['notes'] ?? '',
      status: map['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'vendor': vendor,
      'package': packageName,
      'price': price,
      'date': date.toIso8601String(),
      'location': location,
      'notes': notes,
      'status': status,
    };
  }
}
