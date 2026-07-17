import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_button.dart';

class VNPayErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final VoidCallback onBack;

  const VNPayErrorView({
    super.key,
    required this.message,
    required this.onRetry,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.p24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 72, color: AppColors.destructive),
            const SizedBox(height: AppSizes.p20),
            const Text(
              'Không thể mở thanh toán',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.destructive,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.p12),
            Container(
              padding: const EdgeInsets.all(AppSizes.p16),
              decoration: BoxDecoration(
                color: AppColors.destructive.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppSizes.r12),
                border: Border.all(
                    color: AppColors.destructive.withValues(alpha: 0.25)),
              ),
              child: Text(
                message,
                style: const TextStyle(
                    color: AppColors.destructive,
                    fontSize: 13,
                    height: 1.5),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppSizes.p24),
            AppButton(
              label: 'Thử lại',
              variant: AppButtonVariant.gradient,
              size: AppButtonSize.lg,
              fullWidth: true,
              onPressed: onRetry,
            ),
            const SizedBox(height: AppSizes.p12),
            AppButton(
              label: 'Quay lại',
              variant: AppButtonVariant.secondary,
              size: AppButtonSize.lg,
              fullWidth: true,
              onPressed: onBack,
            ),
          ],
        ),
      ),
    );
  }
}
