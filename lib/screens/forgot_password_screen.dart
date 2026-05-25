import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_button.dart';
import '../widgets/floating_input.dart';
import '../widgets/top_app_bar.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ElectroAppBar(title: 'Quên mật khẩu'),
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
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.key_outlined, size: 28, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            const Text('Khôi phục mật khẩu', style: AppTextStyles.h2),
            const SizedBox(height: 6),
            const Text(
              'Nhập email đã đăng ký, chúng tôi sẽ gửi mã OTP để bạn đặt lại mật khẩu.',
              style: TextStyle(fontSize: 14, color: AppColors.mutedForeground, height: 1.5),
            ),
            const SizedBox(height: 24),
            const FloatingInput(label: 'Email', keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 24),
            AppButton(
              label: 'Gửi mã OTP',
              variant: AppButtonVariant.gradient,
              size: AppButtonSize.lg,
              fullWidth: true,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã gửi mã OTP đến email của bạn'), backgroundColor: AppColors.success),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
