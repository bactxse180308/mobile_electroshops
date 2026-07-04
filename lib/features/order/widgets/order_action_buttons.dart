import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_button.dart';

class OrderActionButtons extends StatelessWidget {
  final bool showContact;
  final bool canCancel;
  final bool isCancelling;
  final VoidCallback onContact;
  final VoidCallback onCancel;

  const OrderActionButtons({
    super.key,
    required this.showContact,
    required this.canCancel,
    required this.isCancelling,
    required this.onContact,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    if (!showContact && !canCancel) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.p12,
        0,
        AppSizes.p12,
        AppSizes.p20,
      ),
      child: Row(
        children: [
          if (showContact)
            Expanded(
              child: AppButton(
                label: AppStrings.contact,
                variant: AppButtonVariant.secondary,
                onPressed: onContact,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.phone_outlined, size: 16),
                    SizedBox(width: AppSizes.p6),
                    Text(AppStrings.contact),
                  ],
                ),
              ),
            ),
          if (showContact && canCancel) const SizedBox(width: AppSizes.p8),
          if (canCancel)
            Expanded(
              child: AppButton(
                label: isCancelling ? null : AppStrings.cancelOrder,
                variant: AppButtonVariant.ghost,
                disabled: isCancelling,
                onPressed: onCancel,
                child: isCancelling
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
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
