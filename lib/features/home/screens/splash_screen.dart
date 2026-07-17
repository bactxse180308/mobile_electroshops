import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/order_provider.dart';
import '../../../services/deep_link_service.dart';
import '../../../services/payment_result_resolver.dart';
import '../../payment/screens/vnpay_result_screen.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _scaleAnim = Tween<double>(begin: 0.5, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _controller.forward();

    Timer(const Duration(milliseconds: 1800), () async {
      if (!mounted) return;
      final isLoggedIn = await context.read<AuthProvider>().tryAutoLogin();
      if (!mounted) return;

      final pendingUri = await DeepLinkService.instance.consumePendingLink();
      if (!mounted) return;

      if (pendingUri != null && isLoggedIn) {
        final orderIdStr = pendingUri.queryParameters['orderId'];
        final statusStr = pendingUri.queryParameters['status'];
        final txnRefStr = pendingUri.queryParameters['txnRef'];

        if (orderIdStr != null) {
          final orderId = int.tryParse(orderIdStr);
          if (orderId != null) {
            _handleColdStartPaymentResult(orderId, statusStr, txnRefStr);
            return;
          }
        }
      }

      if (isLoggedIn) {
        Navigator.pushReplacementNamed(context, AppRoutes.main);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
      }
    });
  }

  Future<void> _handleColdStartPaymentResult(int orderId, String? statusStr, String? txnRefStr) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );

    final authProvider = context.read<AuthProvider>();
    final orderProvider = context.read<OrderProvider>();
    final token = authProvider.accessToken ?? '';

    final resolution = await PaymentResultResolver.resolve(
      orderId: orderId,
      token: token,
      statusStr: statusStr,
      txnRefStr: txnRefStr,
      orderProvider: orderProvider,
      fallbackOrder: null,
    );

    if (!mounted) return;
    Navigator.pop(context); // Close loading dialog

    if (resolution == null) {
      Navigator.pushReplacementNamed(context, AppRoutes.main);
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => VNPayResultScreen(
          isSuccess: resolution.isSuccess,
          order: resolution.order,
          result: resolution.result,
          syncWarning: resolution.syncWarning,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.heroGradient),
        child: Stack(
          children: [
            Positioned(top: -80, left: -64, child: _orb(256, AppColors.primary.withValues(alpha: 0.4))),
            Positioned(bottom: 40, right: -64, child: _orb(288, AppColors.accent.withValues(alpha: 0.3))),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ScaleTransition(
                    scale: _scaleAnim,
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: Container(
                        width: 112,
                        height: 112,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                        ),
                        child: const Icon(Icons.bolt, size: 56, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.p24),
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                        children: [
                          TextSpan(text: 'Electro', style: TextStyle(color: Colors.white)),
                          TextSpan(text: 'Shop', style: TextStyle(color: AppColors.accent)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.p8),
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: const Text(
                      AppStrings.splashTagline,
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 56,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (i) => _dot(i)),
                  ),
                  const SizedBox(height: AppSizes.p12),
                  const Text('v2.4.0', style: TextStyle(color: Colors.white38, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _orb(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }

  Widget _dot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (_, value, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: 6,
          height: 6,
          decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
        );
      },
    );
  }
}
