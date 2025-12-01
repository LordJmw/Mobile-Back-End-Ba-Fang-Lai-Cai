import 'dart:convert';

class PurchaseHistory {
  final int? id;
  final String customerId;
  final PurchaseDetails purchaseDetails;
  final DateTime purchaseDate;

  PurchaseHistory({
    this.id,
    required this.customerId,
    required this.purchaseDetails,
    required this.purchaseDate,
  });

  factory PurchaseHistory.fromMap(Map<String, dynamic> map) {
    Map<String, dynamic> purchaseDetailsMap;

    if (map['purchase_details'] is String) {
      purchaseDetailsMap = json.decode(map['purchase_details']);
    } else {
      purchaseDetailsMap = Map<String, dynamic>.from(map['purchase_details']);
    }

    return PurchaseHistory(
      id: map['id'] as int?,
      customerId: map['customer_id'],
      purchaseDetails: PurchaseDetails.fromJson(purchaseDetailsMap),
      purchaseDate: DateTime.parse(map['purchase_date'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'purchase_details': json.encode(purchaseDetails.toJson()),
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

  Map<String, dynamic> toJson() {
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
