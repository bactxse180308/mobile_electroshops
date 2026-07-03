import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/format_utils.dart';
import '../../../providers/cart_provider.dart';

class OrderSummary extends StatelessWidget {
  final CartProvider cart;

  const OrderSummary({
    super.key,
    required this.cart,
  });

  @override
  Widget build(BuildContext context) {
    final subtotal = cart.selectedSubtotal;
    final shipping = cart.shippingFee;
    final total = cart.totalPayable;
    final count = cart.selectedItems.length;

    return Container(
      margin: const EdgeInsets.all(AppSizes.p12),
      padding: const EdgeInsets.all(AppSizes.p16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.r12),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          _SummaryRow(
            label: '${AppStrings.subtotal} ($count ${AppStrings.productUnit})',
            value: formatVND(subtotal.round()),
          ),
          const SizedBox(height: AppSizes.p8),
          _SummaryRow(
            label: AppStrings.shipping,
            value:
                shipping == 0 ? AppStrings.free : formatVND(shipping.round()),
          ),
          if (shipping == 0) ...[
            const SizedBox(height: AppSizes.p4),
            const Row(
              children: [
                Spacer(),
                Icon(Icons.local_shipping_outlined,
                    size: 12, color: AppColors.success),
                SizedBox(width: AppSizes.p4),
                Text(
                  AppStrings.freeShipNote,
                  style: TextStyle(fontSize: 11, color: AppColors.success),
                ),
              ],
            ),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSizes.p10),
            child: Divider(color: AppColors.border),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(AppStrings.payableTotal, style: AppTextStyles.h3),
              Text(
                formatVND(total.round()),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13, color: AppColors.mutedForeground)),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.secondary,
          ),
        ),
      ],
    );
  }
}
