import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/top_app_bar.dart';
import '../widgets/floating_input.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ElectroAppBar(title: AppStrings.forgotTitle),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.key_outlined, size: 28, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            const Text(AppStrings.forgotTitle, style: AppTextStyles.h2),
            const SizedBox(height: 6),
            const Text(
              AppStrings.forgotSubtitle,
              style: TextStyle(fontSize: 14, color: AppColors.mutedForeground, height: 1.5),
            ),
            const SizedBox(height: 24),
            const FloatingInput(label: AppStrings.emailLabel, keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 24),
            AppButton(
              label: AppStrings.forgotSendButton,
              variant: AppButtonVariant.gradient,
              size: AppButtonSize.lg,
              fullWidth: true,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text(AppStrings.forgotSuccess), backgroundColor: AppColors.success),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
