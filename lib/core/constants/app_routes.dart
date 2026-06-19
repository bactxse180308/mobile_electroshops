class AppRoutes {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String verifyOtp = '/verify-otp';
  static const String forgotPassword = '/forgot-password';
  static const String main = '/main';
  static const String orderSuccess = '/order-success';
  static const String checkout = '/checkout';
  static const String vnpayPayment = '/payment/vnpay';
  static const String vnpayResult = '/payment/vnpay/result';
  static const String orderHistory = '/orders';
  static const String storeMap = '/store-map';
  
  // Custom navigation parameters / sub-routes
  static const String mainCart = '/main-cart';
  static const String productDetailPrefix = '/products/';
  static const String orderDetailPrefix = '/orders/';

  static String productDetail(String id) => '$productDetailPrefix$id';
  static String orderDetail(String id) => '$orderDetailPrefix$id';
}
