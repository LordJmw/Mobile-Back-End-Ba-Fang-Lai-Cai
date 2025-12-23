class DiscountService {
  static bool isDiscountActive = false;
  static double discountPercent = 0.0;

  static void activateDiscount(double percent) {
    isDiscountActive = true;
    discountPercent = percent;
  }

  static void deactivateDiscount() {
    isDiscountActive = false;
    discountPercent = 0.0;
  }

  static double applyDiscount(double originalPrice) {
    if (!isDiscountActive) return originalPrice;

    return originalPrice - (originalPrice * discountPercent);
  }
}
