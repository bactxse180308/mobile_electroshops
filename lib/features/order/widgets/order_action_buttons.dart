import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_button.dart';

class OrderActionButtons extends StatelessWidget {
  final bool showContact;
  final bool canCancel;
  final bool isCancelling;
  final String contactLabel;
  final VoidCallback onContact;
  final VoidCallback onCancel;

  const OrderActionButtons({
    super.key,
    required this.showContact,
    required this.canCancel,
    required this.isCancelling,
    required this.contactLabel,
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
                label: contactLabel,
                variant: AppButtonVariant.secondary,
                onPressed: onContact,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.chat_bubble_outline, size: 16),
                    const SizedBox(width: AppSizes.p6),
                    Flexible(
                      child: Text(
                        contactLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
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
