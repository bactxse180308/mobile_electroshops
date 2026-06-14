import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/cart_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/auth_provider.dart';
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
      title: 'ElectroShop',
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
        return null;
      },
    );
  }
}
