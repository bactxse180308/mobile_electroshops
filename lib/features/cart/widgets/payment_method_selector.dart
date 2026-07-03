import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import 'checkout_section.dart';

class PaymentMethodOption {
  final String id;
  final String label;
  final String subtitle;
  final IconData icon;

  const PaymentMethodOption({
    required this.id,
    required this.label,
    required this.subtitle,
    required this.icon,
  });
}

class PaymentMethodSelector extends StatelessWidget {
  final List<PaymentMethodOption> methods;
  final String selectedMethod;
  final ValueChanged<String> onChanged;

  const PaymentMethodSelector({
    super.key,
    required this.methods,
    required this.selectedMethod,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CheckoutSection(
      title: AppStrings.paymentMethod,
      child: Column(
        children: methods
            .map(
              (method) => _PaymentMethodTile(
                method: method,
                selected: selectedMethod == method.id,
                onTap: () => onChanged(method.id),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  final PaymentMethodOption method;
  final bool selected;
  final VoidCallback onTap;

  const _PaymentMethodTile({
    required this.method,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSizes.p8),
        padding: const EdgeInsets.all(AppSizes.p12),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
          color: selected
              ? AppColors.primary.withValues(alpha: 0.05)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.r12),
        ),
        child: Row(
          children: [
            Icon(method.icon, size: 24, color: AppColors.primary),
            const SizedBox(width: AppSizes.p12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method.label,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondary,
                    ),
                  ),
                  Text(
                    method.subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
            _RadioDot(selected: selected),
          ],
        ),
      ),
    );
  }
}

class _RadioDot extends StatelessWidget {
  final bool selected;

  const _RadioDot({required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.border,
          width: 2,
        ),
      ),
      child: selected
          ? Center(
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
              ),
            )
          : null,
    );
  }
}
