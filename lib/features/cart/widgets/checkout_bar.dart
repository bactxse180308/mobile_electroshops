import 'package:flutter/material.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/format_utils.dart';
import '../../../core/widgets/app_button.dart';
import '../../../providers/cart_provider.dart';
import '../screens/checkout_screen.dart';

class CheckoutBar extends StatelessWidget {
  final CartProvider cart;

  const CheckoutBar({
    super.key,
    required this.cart,
  });

  @override
  Widget build(BuildContext context) {
    final selected = cart.selectedItems;
    final total = cart.totalPayable;
    final count = selected.length;

    return AppButton(
      label: count == 0
          ? AppStrings.selectItemsToCheckout
          : '${AppStrings.checkoutTitle} ($count) · ${formatVND(total.round())}',
      variant: AppButtonVariant.gradient,
      size: AppButtonSize.lg,
      fullWidth: true,
      disabled: count == 0,
      onPressed: count == 0
          ? null
          : () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CheckoutScreen()),
              ),
    );
  }
}
