import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../providers/cart_provider.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../core/widgets/app_button.dart';

class DiscountCodeInput extends StatefulWidget {
  const DiscountCodeInput({super.key});

  @override
  State<DiscountCodeInput> createState() => _DiscountCodeInputState();
}

class _DiscountCodeInputState extends State<DiscountCodeInput> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _applyCode(BuildContext context, CartProvider cart) async {
    final code = _controller.text.trim();
    if (code.isEmpty) return;

    final auth = context.read<AuthProvider>();
    if (auth.userId == null) return;

    // Ẩn bàn phím
    FocusScope.of(context).unfocus();

    await cart.applyDiscountCode(code, auth.userId!);

    if (cart.voucherError != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(cart.voucherError!),
          backgroundColor: AppColors.destructive,
        ),
      );
      cart.clearVoucherError();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Áp dụng mã giảm giá thành công!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final voucher = cart.appliedVoucher;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.p12),
      padding: const EdgeInsets.all(AppSizes.p12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.r12),
        boxShadow: AppShadows.card,
      ),
      child: voucher != null
          ? _buildAppliedState(context, cart, voucher.voucherCode)
          : _buildInputState(context, cart),
    );
  }

  Widget _buildAppliedState(BuildContext context, CartProvider cart, String code) {
    return Row(
      children: [
        const Icon(Icons.local_offer_outlined, color: AppColors.primary, size: 20),
        const SizedBox(width: AppSizes.p8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mã giảm giá đang áp dụng',
                style: TextStyle(fontSize: 11, color: AppColors.mutedForeground),
              ),
              Text(
                code.toUpperCase(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: () {
            _controller.clear();
            cart.removeDiscountCode();
          },
          child: const Text('Hủy', style: TextStyle(color: AppColors.destructive)),
        ),
      ],
    );
  }

  Widget _buildInputState(BuildContext context, CartProvider cart) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 44,
            child: TextField(
              controller: _controller,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                hintText: 'Nhập mã giảm giá',
                hintStyle: const TextStyle(fontSize: 13, color: AppColors.mutedForeground),
                prefixIcon: const Icon(Icons.local_offer_outlined, size: 18),
                contentPadding: const EdgeInsets.symmetric(horizontal: AppSizes.p12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.r8),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.r8),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.r8),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSizes.p8),
        SizedBox(
          height: 44,
          child: AppButton(
            label: cart.isLoading ? 'Đang tải...' : 'Áp dụng',
            disabled: cart.isLoading,
            onPressed: () => _applyCode(context, cart),
          ),
        ),
      ],
    );
  }
}
