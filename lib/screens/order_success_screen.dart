import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_button.dart';
import 'order_detail_screen.dart';

class OrderSuccessScreen extends StatefulWidget {
  const OrderSuccessScreen({super.key});

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
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppColors.successGradient,
                              boxShadow: [BoxShadow(color: Color(0x4010B981), blurRadius: 20, offset: Offset(0, 8))],
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
                    const SizedBox(height: 24),
                    FadeTransition(
                      opacity: _fade,
                      child: const Text('Đặt hàng thành công!', style: AppTextStyles.h1),
                    ),
                    const SizedBox(height: 8),
                    FadeTransition(
                      opacity: _fade,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          'Cảm ơn bạn đã mua sắm tại ElectroShop. Chúng tôi sẽ xử lý đơn hàng trong thời gian sớm nhất.',
                          style: TextStyle(fontSize: 14, color: AppColors.mutedForeground, height: 1.5),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    FadeTransition(
                      opacity: _fade,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.primary.withOpacity(0.4), style: BorderStyle.solid),
                          color: AppColors.primary.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: const [
                            Text('Mã đơn hàng', style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                            SizedBox(height: 4),
                            Text('#ES2025002847', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary, letterSpacing: 2, fontFamily: 'monospace')),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(24, 0, 24, 32 + MediaQuery.of(context).padding.bottom),
                child: Column(
                  children: [
                    AppButton(
                      label: 'Xem đơn hàng',
                      variant: AppButtonVariant.gradient,
                      size: AppButtonSize.lg,
                      fullWidth: true,
                      onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(
                        builder: (_) => const OrderDetailScreen(orderId: 'ES2025002847'),
                      )),
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      label: 'Tiếp tục mua sắm',
                      variant: AppButtonVariant.secondary,
                      size: AppButtonSize.lg,
                      fullWidth: true,
                      onPressed: () => Navigator.pushReplacementNamed(context, '/main'),
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
