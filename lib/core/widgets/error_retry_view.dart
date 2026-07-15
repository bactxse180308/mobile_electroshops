import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../constants/app_strings.dart';
import '../theme/app_theme.dart';

class ErrorRetryView extends StatelessWidget {
  final String? errorMessage;
  final String title;
  final VoidCallback onRetry;

  const ErrorRetryView({
    super.key,
    this.errorMessage,
    this.title = AppStrings.errCannotLoadData,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.p32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.wifiErrBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                size: 36,
                color: AppColors.destructive,
              ),
            ),
            const SizedBox(height: AppSizes.p16),
            Text(title, style: AppTextStyles.h3, textAlign: TextAlign.center),
            if (errorMessage != null && errorMessage!.isNotEmpty) ...[
              const SizedBox(height: AppSizes.p8),
              Text(
                errorMessage!,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.mutedForeground,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: AppSizes.p24),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.p24,
                  vertical: AppSizes.p12,
                ),
                decoration: BoxDecoration(
                  gradient: AppColors.heroGradient,
                  borderRadius: BorderRadius.circular(AppSizes.r12),
                ),
                child: const Text(
                  AppStrings.retry,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
