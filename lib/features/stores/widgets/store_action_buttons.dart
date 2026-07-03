import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_button.dart';

class StoreActionButtons extends StatelessWidget {
  final VoidCallback onCall;
  final VoidCallback onDirections;

  const StoreActionButtons({
    super.key,
    required this.onCall,
    required this.onDirections,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AppButton(
            variant: AppButtonVariant.secondary,
            size: AppButtonSize.sm,
            fullWidth: true,
            onPressed: onCall,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.phone_outlined, size: 14),
                SizedBox(width: AppSizes.p4),
                Text(AppStrings.callButton),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSizes.p8),
        Expanded(
          child: AppButton(
            size: AppButtonSize.sm,
            variant: AppButtonVariant.gradient,
            fullWidth: true,
            onPressed: onDirections,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.near_me_outlined,
                  size: 14,
                  color: Colors.white,
                ),
                SizedBox(width: AppSizes.p4),
                Text(
                  AppStrings.directionsButton,
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
