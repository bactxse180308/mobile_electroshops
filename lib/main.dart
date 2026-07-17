import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile_electroshops/core/constants/app_strings.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/cart_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/order_provider.dart';
import 'providers/payment_provider.dart';
import 'providers/favorite_provider.dart';
import 'providers/home_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/admin_chat_provider.dart';
import 'services/chat_api.dart';
import 'services/admin_chat_api.dart';
import 'services/chat_socket.dart';
import 'core/utils/api_config.dart';
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
import 'features/order/screens/order_success_screen.dart';
import 'features/order/screens/order_detail_screen.dart';
import 'features/checkout/screens/checkout_screen.dart';
import 'features/payment/screens/vnpay_payment_screen.dart';
import 'features/payment/screens/vnpay_result_screen.dart';

Future<String?> _readAccessToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('access_token');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('[ENV] Không tìm thấy .env, dùng dart-define fallback: $e');
  }
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(
          create: (_) => ChatProvider(
            api: ChatApi(),
            socket: ChatSocket(wsUrl: ApiConfig.wsUrl, tokenProvider: _readAccessToken),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => AdminChatProvider(
            api: AdminChatApi(),
            socket: ChatSocket(wsUrl: ApiConfig.wsUrl, tokenProvider: _readAccessToken),
          ),
        ),
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
