import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/widgets/app_button.dart';
import '../widgets/floating_input.dart';
import '../../../core/widgets/top_app_bar.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _otpController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _handleVerify(String email) async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.errOtpDigits)),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await context.read<AuthProvider>().verifyOtp(email, otp);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.otpVerifySuccess)),
        );
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
      }
    } catch (e) {
      if (mounted) {
        final errStr = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errStr)),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleResend(String email) async {
    setState(() => _isLoading = true);
    try {
      await context.read<AuthProvider>().sendOtp(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.otpResendSuccess)),
        );
      }
    } catch (e) {
      if (mounted) {
        final errStr = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errStr)),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = (ModalRoute.of(context)?.settings.arguments as String?) ?? '';

    return Scaffold(
      appBar: const ElectroAppBar(title: AppStrings.otpTitle),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text(AppStrings.otpEnterCode, style: AppTextStyles.h1),
            const SizedBox(height: 8),
            Text(
              '${AppStrings.otpInstructionPrefix}$email${AppStrings.otpInstructionSuffix}',
              style: const TextStyle(fontSize: 14, color: AppColors.mutedForeground, height: 1.4),
            ),
            const SizedBox(height: 32),
            FloatingInput(
              label: AppStrings.otpEnterCode,
              controller: _otpController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            AppButton(
              label: _isLoading ? null : AppStrings.otpVerifyButton,
              variant: AppButtonVariant.gradient,
              size: AppButtonSize.lg,
              fullWidth: true,
              disabled: _isLoading,
              onPressed: _isLoading ? null : () => _handleVerify(email),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 32),
            Center(
              child: Column(
                children: [
                  const Text(AppStrings.otpNotReceived, style: TextStyle(fontSize: 13, color: AppColors.mutedForeground)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _isLoading ? null : () => _handleResend(email),
                    child: const Text(
                      AppStrings.otpResendCode,
                      style: TextStyle(fontSize: 14, color: AppColors.primary, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
