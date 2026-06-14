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

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _pw = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _email.dispose();
    _pw.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _email.text.trim();
    final password = _pw.text.trim();
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.errEmptyLogin)),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await context.read<AuthProvider>().login(email, password);
      if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.main);
    } catch (e) {
      if (mounted) {
        final errStr = e.toString().replaceAll('Exception: ', '');
        if (errStr.toLowerCase().contains('verify') || errStr.toLowerCase().contains('xác minh') || errStr.toLowerCase().contains('pending')) {
          // Account unverified, trigger OTP send and route to verify screen
          try {
            await context.read<AuthProvider>().sendOtp(email);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text(AppStrings.errUnverifiedAccount)),
              );
              Navigator.pushNamed(context, AppRoutes.verifyOtp, arguments: email);
            }
          } catch (otpErr) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${AppStrings.errCannotSendOtp}$otpErr')),
              );
            }
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errStr)),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    try {
      await context.read<AuthProvider>().loginWithGoogle();
      if (mounted && context.read<AuthProvider>().isAuthenticated) {
        Navigator.pushReplacementNamed(context, AppRoutes.main);
      }
    } catch (e) {
      if (mounted) {
        final errStr = e.toString().replaceAll('Exception: ', '');
        debugPrint('==================================================');
        debugPrint('Google Sign-In Error: $e');
        debugPrint('==================================================');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppStrings.errGoogleLoginFailed}$errStr')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ElectroAppBar(showBack: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text(AppStrings.loginTitle, style: AppTextStyles.h1),
            const SizedBox(height: 4),
            const Text(AppStrings.loginSubtitle, style: TextStyle(fontSize: 14, color: AppColors.mutedForeground)),
            const SizedBox(height: 32),
            FloatingInput(label: AppStrings.emailLabel, controller: _email, keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 16),
            FloatingInput(label: AppStrings.passwordLabel, controller: _pw, obscureText: true),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, AppRoutes.forgotPassword),
                child: const Text(AppStrings.forgotPassword, style: TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w500)),
              ),
            ),
            const SizedBox(height: 24),
            AppButton(
              label: _isLoading ? null : AppStrings.loginButton,
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
              variant: AppButtonVariant.gradient,
              size: AppButtonSize.lg,
              fullWidth: true,
              disabled: _isLoading,
              onPressed: _isLoading ? null : _handleLogin,
            ),
            const SizedBox(height: 24),
            Row(
              children: const [
                Expanded(child: Divider(color: AppColors.border)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text(AppStrings.orText, style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                ),
                Expanded(child: Divider(color: AppColors.border)),
              ],
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _isLoading ? null : _handleGoogleLogin,
              child: Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(width: 8),
                    _GoogleIcon(),
                    const SizedBox(width: 12),
                    const Text(AppStrings.googleLogin, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.secondary)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(AppStrings.dontHaveAccount, style: TextStyle(fontSize: 13, color: AppColors.mutedForeground)),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, AppRoutes.register),
                  child: const Text(AppStrings.registerButton, style: TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 20,
      height: 20,
      child: Icon(Icons.g_mobiledata, size: 24, color: Color(0xFF4285F4)),
    );
  }
}
