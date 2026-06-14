import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';

class CouponInput extends StatelessWidget {
  const CouponInput({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.p12),
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.p12, vertical: AppSizes.p8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.r12),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: [
          const Icon(Icons.local_offer_outlined, size: 20, color: AppColors.accent),
          const SizedBox(width: AppSizes.p8),
          const Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: AppStrings.enterCoupon,
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: TextStyle(fontSize: 13),
            ),
          ),
          AppButton(
            label: AppStrings.apply,
            size: AppButtonSize.sm,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
