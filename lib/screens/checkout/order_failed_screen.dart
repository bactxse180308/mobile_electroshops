import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_button.dart';

class OrderFailedScreen extends StatelessWidget {
  final int orderId;
  final String paymentStatus;

  const OrderFailedScreen({
    super.key,
    required this.orderId,
    required this.paymentStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.destructive.withOpacity(0.12),
              ),
              child: const Icon(
                Icons.error_outline,
                size: 44,
                color: AppColors.destructive,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Thanh toán thất bại',
              style: AppTextStyles.h1,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Mã đơn hàng #$orderId',
              style: const TextStyle(fontSize: 13, color: AppColors.mutedForeground),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Trạng thái: $paymentStatus',
              style: const TextStyle(fontSize: 13, color: AppColors.mutedForeground),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            AppButton(
              label: 'Quay về trang chủ',
              variant: AppButtonVariant.gradient,
              size: AppButtonSize.lg,
              fullWidth: true,
              onPressed: () => Navigator.pushNamedAndRemoveUntil(
                context,
                '/main',
                (route) => false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
