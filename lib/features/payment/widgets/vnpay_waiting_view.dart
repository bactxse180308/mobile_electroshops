import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_button.dart';

class VNPayWaitingView extends StatelessWidget {
  final bool browserOpened;
  final VoidCallback onOpenBrowser;
  final VoidCallback onCheckResult;

  const VNPayWaitingView({
    super.key,
    required this.browserOpened,
    required this.onOpenBrowser,
    required this.onCheckResult,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.p24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.open_in_browser_rounded,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSizes.p24),

            Text(
              browserOpened
                  ? 'Trình duyệt đang mở\nthanh toán VNPay'
                  : 'Mở trình duyệt thanh toán',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.secondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.p12),

            Text(
              browserOpened
                  ? 'Vui lòng hoàn tất giao dịch trên trình duyệt.\n'
                      'Sau khi thanh toán xong, quay lại app\nhoặc nhấn "Kiểm tra kết quả" bên dưới.'
                  : 'Nhấn nút bên dưới để mở trình duyệt\nvà tiến hành thanh toán VNPay.',
              style: const TextStyle(
                color: AppColors.mutedForeground,
                fontSize: 14,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.p32),

            if (browserOpened) ...[
              AppButton(
                label: 'Kiểm tra kết quả thanh toán',
                variant: AppButtonVariant.gradient,
                size: AppButtonSize.lg,
                fullWidth: true,
                onPressed: onCheckResult,
              ),
              const SizedBox(height: AppSizes.p12),
              AppButton(
                label: 'Mở lại trình duyệt',
                variant: AppButtonVariant.secondary,
                size: AppButtonSize.lg,
                fullWidth: true,
                onPressed: onOpenBrowser,
              ),
            ] else ...[
              AppButton(
                label: 'Mở trình duyệt thanh toán',
                variant: AppButtonVariant.gradient,
                size: AppButtonSize.lg,
                fullWidth: true,
                onPressed: onOpenBrowser,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
