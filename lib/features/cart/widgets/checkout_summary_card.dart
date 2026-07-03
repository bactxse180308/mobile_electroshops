import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/format_utils.dart';
import 'checkout_section.dart';

class CheckoutSummaryCard extends StatelessWidget {
  final double subtotal;
  final double shipping;
  final double total;

  const CheckoutSummaryCard({
    super.key,
    required this.subtotal,
    required this.shipping,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return CheckoutSection(
      child: Column(
        children: [
          _SummaryLine(AppStrings.subtotal, formatVND(subtotal.round())),
          const SizedBox(height: AppSizes.p8),
          _SummaryLine(
            AppStrings.shipping,
            shipping == 0 ? AppStrings.free : formatVND(shipping.round()),
            valueColor: shipping == 0 ? AppColors.success : null,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSizes.p10),
            child: Divider(color: AppColors.border),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(AppStrings.totalPayable, style: AppTextStyles.h3),
              ShaderMask(
                shaderCallback: (bounds) =>
                    AppColors.primaryGradient.createShader(bounds),
                child: Text(
                  formatVND(total.round()),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _SummaryLine(this.label, this.value, {this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.mutedForeground,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: valueColor ?? AppColors.secondary,
          ),
        ),
      ],
    );
  }
}
