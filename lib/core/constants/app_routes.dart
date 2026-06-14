class AppRoutes {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String verifyOtp = '/verify-otp';
  static const String forgotPassword = '/forgot-password';
  static const String main = '/main';
  static const String orderSuccess = '/order-success';
  
  // Custom navigation parameters / sub-routes
  static const String mainCart = '/main-cart';
  static const String productDetailPrefix = '/products/';
  static const String orderDetailPrefix = '/orders/';

  static String productDetail(String id) => '$productDetailPrefix$id';
  static String orderDetail(String id) => '$orderDetailPrefix$id';
}
