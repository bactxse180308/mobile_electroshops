import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_button.dart';
import '../widgets/floating_input.dart';
import '../widgets/top_app_bar.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _fullName = TextEditingController();
  final _email = TextEditingController();
  final _phoneNumber = TextEditingController();
  final _pw = TextEditingController();
  final _confirmPw = TextEditingController();
  
  bool _agree = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _fullName.dispose();
    _email.dispose();
    _phoneNumber.dispose();
    _pw.dispose();
    _confirmPw.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final fullName = _fullName.text.trim();
    final email = _email.text.trim();
    final phoneNumber = _phoneNumber.text.trim();
    final password = _pw.text.trim();
    final confirmPassword = _confirmPw.text.trim();

    if (fullName.isEmpty || email.isEmpty || phoneNumber.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin đăng ký.')),
      );
      return;
    }

    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Định dạng email không hợp lệ.')),
      );
      return;
    }

    final phoneRegExp = RegExp(r'^[0-9]{10,15}$');
    if (!phoneRegExp.hasMatch(phoneNumber)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Số điện thoại phải từ 10 đến 15 chữ số.')),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mật khẩu xác nhận không trùng khớp.')),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mật khẩu phải chứa ít nhất 6 ký tự.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Call Register API (Backend will automatically generate and send OTP email)
      await context.read<AuthProvider>().register(fullName, email, phoneNumber, password);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đăng ký thành công! Vui lòng kiểm tra hòm thư để nhận mã OTP.')),
        );
        // 2. Navigate to OTP screen and pass the email
        Navigator.pushReplacementNamed(context, '/verify-otp', arguments: email);
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
    return Scaffold(
      appBar: const ElectroAppBar(title: 'Tạo tài khoản'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text('Tham gia ElectroShop để nhận ưu đãi thành viên', style: TextStyle(fontSize: 14, color: AppColors.mutedForeground)),
            const SizedBox(height: 24),
            FloatingInput(label: 'Họ và tên', controller: _fullName),
            const SizedBox(height: 16),
            FloatingInput(label: 'Email', controller: _email, keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 16),
            FloatingInput(label: 'Số điện thoại', controller: _phoneNumber, keyboardType: TextInputType.phone),
            const SizedBox(height: 16),
            FloatingInput(label: 'Mật khẩu', controller: _pw, obscureText: true),
            const SizedBox(height: 16),
            FloatingInput(label: 'Xác nhận mật khẩu', controller: _confirmPw, obscureText: true),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => setState(() => _agree = !_agree),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: _agree ? AppColors.primary : Colors.transparent,
                      border: Border.all(color: _agree ? AppColors.primary : AppColors.border, width: 1.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: _agree ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(fontSize: 12, color: AppColors.mutedForeground),
                        children: [
                          TextSpan(text: 'Tôi đồng ý với '),
                          TextSpan(text: 'Điều khoản dịch vụ', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500)),
                          TextSpan(text: ' và '),
                          TextSpan(text: 'Chính sách bảo mật', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500)),
                          TextSpan(text: ' của ElectroShop'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            AppButton(
              label: _isLoading ? null : 'Đăng ký',
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
              disabled: !_agree || _isLoading,
              onPressed: _isLoading ? null : _handleRegister,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Đã có tài khoản? ', style: TextStyle(fontSize: 13, color: AppColors.mutedForeground)),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Text('Đăng nhập', style: TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w700)),
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
