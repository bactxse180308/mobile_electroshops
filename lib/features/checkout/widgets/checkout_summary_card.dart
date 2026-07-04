import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/format_utils.dart';
import 'checkout_section.dart';
import '../../../widgets/common/summary_info_row.dart';

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
          SummaryInfoRow(
            label: AppStrings.subtotal,
            value: formatVND(subtotal.round()),
            labelStyle: const TextStyle(
              fontSize: 13,
              color: AppColors.mutedForeground,
            ),
            valueStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: AppSizes.p8),
          SummaryInfoRow(
            label: AppStrings.shipping,
            value:
                shipping == 0 ? AppStrings.free : formatVND(shipping.round()),
            labelStyle: const TextStyle(
              fontSize: 13,
              color: AppColors.mutedForeground,
            ),
            valueStyle: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: shipping == 0 ? AppColors.success : AppColors.secondary,
            ),
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
