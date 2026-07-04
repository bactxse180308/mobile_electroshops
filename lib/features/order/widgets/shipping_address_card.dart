import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';

class ShippingAddressCard extends StatelessWidget {
  final String recipientName;
  final String recipientPhone;
  final String address;

  const ShippingAddressCard({
    super.key,
    required this.recipientName,
    required this.recipientPhone,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    final hasRecipientInfo =
        recipientName.trim().isNotEmpty || recipientPhone.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 16,
              color: AppColors.primary,
            ),
            SizedBox(width: AppSizes.p8),
            Text(AppStrings.shippingAddress, style: AppTextStyles.h3),
          ],
        ),
        const SizedBox(height: AppSizes.p8),
        if (hasRecipientInfo) ...[
          Text(
            '$recipientName · $recipientPhone',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: AppSizes.p4),
        ],
        Text(
          address.isEmpty ? 'Chưa có địa chỉ giao hàng' : address,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.mutedForeground,
          ),
        ),
      ],
    );
  }
}
