import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/widgets/app_button.dart';
import '../../../models/api_models.dart';
import 'order_detail_screen.dart';

class OrderSuccessScreen extends StatefulWidget {
  final OrderResponse? order;
  const OrderSuccessScreen({super.key, this.order});

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _scale = Tween<double>(begin: 0.5, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _fade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orderIdStr = widget.order != null ? widget.order!.orderId.toString() : 'ES2025002847';

    return Scaffold(
      body: Stack(
        children: [
          // Confetti-like decorations
          ...List.generate(12, (i) {
            final colors = [AppColors.primary, AppColors.accent, AppColors.success, AppColors.destructive, const Color(0xFFA78BFA)];
            return Positioned(
              top: 60.0 + (i * 40) % 300,
              left: (i * 73) % MediaQuery.of(context).size.width.toInt() * 1.0,
              child: Container(
                width: 8, height: 8,
                decoration: BoxDecoration(
                  color: colors[i % colors.length].withOpacity(0.6),
                  shape: i % 2 == 0 ? BoxShape.circle : BoxShape.rectangle,
                  borderRadius: i % 2 != 0 ? BorderRadius.circular(2) : null,
                ),
              ),
            );
          }),

          Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ScaleTransition(
                      scale: _scale,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 112, height: 112,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.success.withOpacity(0.15),
                            ),
                          ),
                          Container(
                            width: 80, height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppColors.successGradient,
                              boxShadow: [BoxShadow(color: AppColors.success.withValues(alpha: 0.25), blurRadius: 20, offset: const Offset(0, 8))],
                            ),
                            child: const Icon(Icons.check, size: 40, color: Colors.white),
                          ),
                          Positioned(
                            top: 0, right: 0,
                            child: Icon(Icons.auto_awesome, size: 20, color: AppColors.accent),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSizes.p24),
                    FadeTransition(
                      opacity: _fade,
                      child: const Text(AppStrings.orderSuccessTitle, style: AppTextStyles.h1),
                    ),
                    const SizedBox(height: AppSizes.p8),
                    FadeTransition(
                      opacity: _fade,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: AppSizes.p32),
                        child: Text(
                          AppStrings.orderSuccessMsg,
                          style: TextStyle(fontSize: 14, color: AppColors.mutedForeground, height: 1.5),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.p20),
                    FadeTransition(
                      opacity: _fade,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSizes.p20, vertical: AppSizes.p12),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.4), style: BorderStyle.solid),
                          color: AppColors.primary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(AppSizes.r12),
                        ),
                        child: Column(
                          children: [
                            const Text(AppStrings.orderCode, style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                            const SizedBox(height: AppSizes.p4),
                            Text(
                              widget.order != null ? '#${widget.order!.orderId}' : AppStrings.mockOrderCode,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary, letterSpacing: 2, fontFamily: 'monospace'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(AppSizes.p24, 0, AppSizes.p24, AppSizes.p32 + MediaQuery.of(context).padding.bottom),
                child: Column(
                  children: [
                    AppButton(
                      label: AppStrings.viewOrderButton,
                      variant: AppButtonVariant.gradient,
                      size: AppButtonSize.lg,
                      fullWidth: true,
                      onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(
                        builder: (_) => OrderDetailScreen(orderId: orderIdStr),
                      )),
                    ),
                    const SizedBox(height: AppSizes.p12),
                    AppButton(
                      label: AppStrings.continueShopping,
                      variant: AppButtonVariant.secondary,
                      size: AppButtonSize.lg,
                      fullWidth: true,
                      onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.main),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
