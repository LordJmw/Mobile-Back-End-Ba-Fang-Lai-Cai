class PurchaseHistory {
  final int? id;
  final int customerId;
  final String purchaseDetails;
  final DateTime purchaseDate;

  PurchaseHistory({
    this.id,
    required this.customerId,
    required this.purchaseDetails,
    required this.purchaseDate,
  });

  factory PurchaseHistory.fromMap(Map<String, dynamic> map) {
    return PurchaseHistory(
      id: map['id'] as int?,
      customerId: map['customer_id'] as int,
      purchaseDetails: map['purchase_details'] as String,
      purchaseDate: DateTime.parse(map['purchase_date'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_id': customerId,
      'purchase_details': purchaseDetails,
      'purchase_date': purchaseDate.toIso8601String(),
    };
  }
}
