import 'package:flutter/material.dart';
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
  bool _agree = true;

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
            const FloatingInput(label: 'Họ và tên'),
            const SizedBox(height: 16),
            const FloatingInput(label: 'Email', keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 16),
            const FloatingInput(label: 'Số điện thoại', keyboardType: TextInputType.phone),
            const SizedBox(height: 16),
            const FloatingInput(label: 'Mật khẩu', obscureText: true),
            const SizedBox(height: 16),
            const FloatingInput(label: 'Xác nhận mật khẩu', obscureText: true),
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
              label: 'Đăng ký',
              variant: AppButtonVariant.gradient,
              size: AppButtonSize.lg,
              fullWidth: true,
              disabled: !_agree,
              onPressed: () => Navigator.pushReplacementNamed(context, '/main'),
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
