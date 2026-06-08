import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_button.dart';
import '../widgets/floating_input.dart';
import '../widgets/top_app_bar.dart';

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
        const SnackBar(content: Text('Mã OTP phải gồm 6 chữ số.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await context.read<AuthProvider>().verifyOtp(email, otp);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Xác thực tài khoản thành công! Bây giờ bạn có thể đăng nhập.')),
        );
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
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
          const SnackBar(content: Text('Đã gửi lại mã OTP mới. Vui lòng kiểm tra email.')),
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
      appBar: const ElectroAppBar(title: 'Xác thực tài khoản'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text('Nhập mã xác thực', style: AppTextStyles.h1),
            const SizedBox(height: 8),
            Text(
              'Một mã OTP 6 số đã được gửi đến hòm thư $email. Vui lòng nhập mã để kích hoạt tài khoản của bạn.',
              style: const TextStyle(fontSize: 14, color: AppColors.mutedForeground, height: 1.4),
            ),
            const SizedBox(height: 32),
            FloatingInput(
              label: 'Mã xác thực OTP',
              controller: _otpController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            AppButton(
              label: _isLoading ? null : 'Xác nhận kích hoạt',
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
                  const Text('Không nhận được mã OTP?', style: TextStyle(fontSize: 13, color: AppColors.mutedForeground)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _isLoading ? null : () => _handleResend(email),
                    child: const Text(
                      'Gửi lại mã OTP',
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
