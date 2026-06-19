import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_electroshops/core/constants/app_strings.dart';
import 'package:provider/provider.dart';
import 'providers/cart_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/order_provider.dart';
import 'providers/payment_provider.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_routes.dart';
import 'features/home/screens/splash_screen.dart';
import 'features/home/screens/onboarding_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/auth/screens/otp_verification_screen.dart';
import 'features/auth/screens/forgot_password_screen.dart';
import 'features/home/screens/main_screen.dart';
import 'features/product/screens/product_detail_screen.dart';
import 'features/cart/screens/order_success_screen.dart';
import 'features/cart/screens/order_detail_screen.dart';
import 'features/cart/screens/checkout_screen.dart';
import 'features/cart/screens/vnpay_payment_screen.dart';
import 'features/cart/screens/vnpay_result_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProxyProvider<CartProvider, AuthProvider>(
          create: (_) => AuthProvider(),
          update: (_, cartProvider, authProvider) {
            authProvider!.setCartProvider(cartProvider);
            return authProvider;
          },
        ),
      ],
      child: const ElectroShopApp(),
    ),
  );
}

class ElectroShopApp extends StatelessWidget {
  const ElectroShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: appTheme(),
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (_) => const SplashScreen(),
        AppRoutes.onboarding: (_) => const OnboardingScreen(),
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.register: (_) => const RegisterScreen(),
        AppRoutes.verifyOtp: (_) => const OtpVerificationScreen(),
        AppRoutes.forgotPassword: (_) => const ForgotPasswordScreen(),
        AppRoutes.main: (_) => const MainScreen(),
        AppRoutes.orderSuccess: (_) => const OrderSuccessScreen(),
        AppRoutes.checkout: (_) => const CheckoutScreen(),
      },
      onGenerateRoute: (settings) {
        final name = settings.name ?? '';
        if (name.startsWith(AppRoutes.productDetailPrefix)) {
          final id = name.replaceFirst(AppRoutes.productDetailPrefix, '');
          return MaterialPageRoute(builder: (_) => ProductDetailScreen(productId: id));
        }
        if (name.startsWith(AppRoutes.orderDetailPrefix)) {
          final id = name.replaceFirst(AppRoutes.orderDetailPrefix, '');
          return MaterialPageRoute(builder: (_) => OrderDetailScreen(orderId: id));
        }
        if (name == AppRoutes.mainCart) {
          return MaterialPageRoute(builder: (_) => const MainScreen(initialIndex: 2));
        }
        if (name == AppRoutes.vnpayPayment) {
          final args = settings.arguments as VNPayPaymentScreenArgs;
          return MaterialPageRoute(
            builder: (_) => VNPayPaymentScreen(
              order: args.order,
              paymentUrl: args.paymentUrl,
              token: args.token,
            ),
          );
        }
        if (name == AppRoutes.vnpayResult) {
          final args = settings.arguments as VNPayResultScreenArgs;
          return MaterialPageRoute(
            builder: (_) => VNPayResultScreen(
              isSuccess: args.isSuccess,
              order: args.order,
              result: args.result,
              syncWarning: args.syncWarning,
            ),
          );
        }
        return null;
      },
    );
  }
}
