import 'package:projek_uts_mbr/model/CustomerModel.dart';
import 'package:projek_uts_mbr/databases/customerDatabase.dart';

class PremiumService {
  final CustomerDatabase _customerDb = CustomerDatabase();

  Future<bool> upgradeToPremium({
    required String customerEmail,
    required DateTime expiryDate,
    required String paymentMethod,
  }) async {
    try {
      final customer = await _customerDb.getCustomerByEmail(customerEmail);
      if (customer == null) {
        print('Customer with email $customerEmail not found');
        return false;
      }

      if (customer.isPremiumActive) {
        print('Customer $customerEmail already has active premium');
        return false;
      }

      print("Upgrading $customerEmail to premium until $expiryDate");

      final success = await _customerDb.updateCustomerPremiumStatus(
        customerEmail: customerEmail,
        isPremiumUser: true,
        expiryDate: expiryDate,
        startDate: DateTime.now(),
      );

      if (success) {
        print('Successfully upgraded $customerEmail to premium');
      } else {
        print('Failed to update premium status for $customerEmail');
      }

      return success;
    } catch (e) {
      print('Error upgrading to premium: $e');
      return false;
    }
  }

  Future<bool> checkIfPremiumActive(String customerEmail) async {
    try {
      return CustomerDatabase().isUserPremium();
    } catch (e) {
      print('Error checking premium status: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getPremiumInfo(String customerEmail) async {
    try {
      final customer = await _customerDb.getCustomerByEmail(customerEmail);
      if (customer == null || !customer.isPremiumUser) return null;

      return {
        'isPremium': customer.isPremiumUser,
        'isActive': customer.isPremiumActive,
        'expiryDate': customer.premiumExpiryDate,
        'startDate': customer.premiumStartDate,
        'daysLeft': customer.premiumDaysLeft,
        'statusText': customer.premiumStatusText,
      };
    } catch (e) {
      print('Error getting premium info: $e');
      return null;
    }
  }
}
