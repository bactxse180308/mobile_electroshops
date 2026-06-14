import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/format_utils.dart';
import '../../../models/api_models.dart';

class CheckoutItemRow extends StatelessWidget {
  final ApiCartItemResponse item;

  const CheckoutItemRow({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = item.mainImage != null && item.mainImage!.isNotEmpty
        ? item.mainImage!
        : 'https://picsum.photos/seed/${item.productId}/200/200';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.p12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.r8),
            child: Image.network(
              imageUrl,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 56,
                height: 56,
                color: AppColors.muted,
                child: const Icon(Icons.image_not_supported, size: 24, color: AppColors.mutedForeground),
              ),
            ),
          ),
          const SizedBox(width: AppSizes.p12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: const TextStyle(fontSize: 12, color: AppColors.secondary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSizes.p4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'x${item.quantity}',
                      style: const TextStyle(fontSize: 11, color: AppColors.mutedForeground),
                    ),
                    Text(
                      formatVND(item.subtotal.round()),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
