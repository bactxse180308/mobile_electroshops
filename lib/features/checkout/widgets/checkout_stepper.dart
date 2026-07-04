import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';

class CheckoutStepper extends StatelessWidget {
  const CheckoutStepper({super.key});

  @override
  Widget build(BuildContext context) {
    const steps = [
      AppStrings.stepAddress,
      AppStrings.stepPayment,
      AppStrings.stepConfirm,
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.p24,
        AppSizes.p12,
        AppSizes.p24,
        AppSizes.p16,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: steps.asMap().entries.map((entry) {
          final index = entry.key;
          final label = entry.value;
          final done = index < 2;
          final active = index == 2;

          return Expanded(
            child: Row(
              children: [
                Column(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: done ? AppColors.successGradient : null,
                        color: active
                            ? AppColors.primary
                            : (done ? null : AppColors.muted),
                      ),
                      child: Center(
                        child: done
                            ? const Icon(
                                Icons.check,
                                size: 16,
                                color: Colors.white,
                              )
                            : Text(
                                '${index + 1}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: active
                                      ? Colors.white
                                      : AppColors.mutedForeground,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.p4),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: done || active
                            ? AppColors.secondary
                            : AppColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
                if (index < steps.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.only(bottom: 16),
                      color: done ? AppColors.success : AppColors.border,
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
