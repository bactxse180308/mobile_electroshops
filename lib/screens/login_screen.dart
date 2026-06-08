import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_button.dart';
import '../widgets/floating_input.dart';
import '../widgets/top_app_bar.dart';

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
        const SnackBar(content: Text('Vui lòng nhập đầy đủ email và mật khẩu.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await context.read<AuthProvider>().login(email, password);
      if (mounted) Navigator.pushReplacementNamed(context, '/main');
    } catch (e) {
      if (mounted) {
        final errStr = e.toString().replaceAll('Exception: ', '');
        if (errStr.toLowerCase().contains('verify') || errStr.toLowerCase().contains('xác minh') || errStr.toLowerCase().contains('pending')) {
          // Account unverified, trigger OTP send and route to verify screen
          try {
            await context.read<AuthProvider>().sendOtp(email);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tài khoản chưa được kích hoạt. Đã gửi mã OTP xác thực tới email của bạn.')),
              );
              Navigator.pushNamed(context, '/verify-otp', arguments: email);
            }
          } catch (otpErr) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Tài khoản chưa kích hoạt. Không thể gửi mã OTP: $otpErr')),
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
        Navigator.pushReplacementNamed(context, '/main');
      }
    } catch (e) {
      if (mounted) {
        final errStr = e.toString().replaceAll('Exception: ', '');
        debugPrint('==================================================');
        debugPrint('Google Sign-In Error: $e');
        debugPrint('==================================================');
        if (errStr.toLowerCase().contains('sign_in_failed') || 
            errStr.toLowerCase().contains('network') || 
            errStr.toLowerCase().contains('developer') ||
            errStr.toLowerCase().contains('missingpluginexception') ||
            errStr.toLowerCase().contains('no implementation')) {
          _showGoogleSimulationDialog(context, errStr);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đăng nhập Google thất bại: $errStr')),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showGoogleSimulationDialog(BuildContext context, String nativeError) {
    final emailController = TextEditingController(text: 'test_google@gmail.com');
    final nameController = TextEditingController(text: 'Google User Test');

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Mô phỏng Google Login'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lỗi thực tế: $nativeError',
              style: const TextStyle(fontSize: 12, color: AppColors.destructive, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Do cấu hình Google Sign-In yêu cầu thiết lập tệp cấu hình SHA-1 & Google Services trên Firebase. Bạn có thể sử dụng chế độ giả lập này để test nhanh API Google Login của Backend.',
              style: TextStyle(fontSize: 13, color: AppColors.mutedForeground),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email Google giả lập',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Tên hiển thị Google',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogCtx);
              setState(() => _isLoading = true);
              try {
                await context.read<AuthProvider>().loginWithGoogleSimulation(
                      emailController.text.trim(),
                      nameController.text.trim(),
                    );
                if (context.read<AuthProvider>().isAuthenticated && mounted) {
                  Navigator.pushReplacementNamed(context, '/main');
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Mô phỏng Google thất bại: $e')),
                  );
                }
              } finally {
                if (mounted) setState(() => _isLoading = false);
              }
            },
            child: const Text('Tiếp tục'),
          ),
        ],
      ),
    );
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
            const Text('Chào mừng trở lại', style: AppTextStyles.h1),
            const SizedBox(height: 4),
            const Text('Đăng nhập để tiếp tục mua sắm', style: TextStyle(fontSize: 14, color: AppColors.mutedForeground)),
            const SizedBox(height: 32),
            FloatingInput(label: 'Email', controller: _email, keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 16),
            FloatingInput(label: 'Mật khẩu', controller: _pw, obscureText: true),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/forgot-password'),
                child: const Text('Quên mật khẩu?', style: TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w500)),
              ),
            ),
            const SizedBox(height: 24),
            AppButton(
              label: _isLoading ? null : 'Đăng nhập',
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
                  child: Text('hoặc', style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
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
                    const Text('Tiếp tục với Google', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.secondary)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Chưa có tài khoản? ', style: TextStyle(fontSize: 13, color: AppColors.mutedForeground)),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/register'),
                  child: const Text('Đăng ký', style: TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w700)),
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
