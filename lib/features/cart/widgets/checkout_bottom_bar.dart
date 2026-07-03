import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/format_utils.dart';
import '../../../core/widgets/app_button.dart';

class CheckoutBottomBar extends StatelessWidget {
  final double total;
  final bool loading;
  final bool disabled;
  final VoidCallback? onPlaceOrder;

  const CheckoutBottomBar({
    super.key,
    required this.total,
    required this.loading,
    required this.disabled,
    required this.onPlaceOrder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSizes.p12,
        AppSizes.p10,
        AppSizes.p12,
        AppSizes.p10 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                AppStrings.total,
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.mutedForeground,
                ),
              ),
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
          const SizedBox(width: AppSizes.p12),
          Expanded(
            child: AppButton(
              label: loading ? null : AppStrings.placeOrder,
              variant: AppButtonVariant.gradient,
              size: AppButtonSize.lg,
              disabled: disabled || loading,
              onPressed: disabled || loading ? null : onPlaceOrder,
              child: loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
