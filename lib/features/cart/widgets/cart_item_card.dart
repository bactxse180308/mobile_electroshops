import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/format_utils.dart';
import '../../../core/widgets/custom_checkbox.dart';
import '../../../models/api_models.dart';

class CartItemCard extends StatelessWidget {
  final ApiCartItemResponse item;
  final bool selected;
  final VoidCallback onToggle;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;

  const CartItemCard({
    super.key,
    required this.item,
    required this.selected,
    required this.onToggle,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = item.mainImage != null && item.mainImage!.isNotEmpty
        ? item.mainImage!
        : 'https://picsum.photos/seed/${item.productId}/200/200';

    return Container(
      margin: const EdgeInsets.fromLTRB(AppSizes.p12, 0, AppSizes.p12, AppSizes.p12),
      padding: const EdgeInsets.all(AppSizes.p12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.r16),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: AppSizes.p4),
            child: CustomCheckbox(checked: selected, onTap: onToggle),
          ),
          const SizedBox(width: AppSizes.p10),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.r8),
            child: Image.network(
              imageUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 80,
                height: 80,
                color: AppColors.muted,
                child: const Icon(Icons.image_not_supported, color: AppColors.mutedForeground),
              ),
            ),
          ),
          const SizedBox(width: AppSizes.p10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: const TextStyle(fontSize: 13, color: AppColors.secondary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSizes.p8),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(formatVND(item.price.round()), style: AppTextStyles.price),
                          if (item.quantity > 1)
                            Text(
                              '= ${formatVND(item.subtotal.round())}',
                              style: const TextStyle(fontSize: 11, color: AppColors.mutedForeground),
                            ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        // Xoá
                        GestureDetector(
                          onTap: onRemove,
                          child: Container(
                            width: 32,
                            height: 32,
                            alignment: Alignment.center,
                            child: const Icon(Icons.delete_outline, size: 18, color: AppColors.mutedForeground),
                          ),
                        ),
                        // Số lượng
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.border),
                            borderRadius: BorderRadius.circular(AppSizes.r8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _QtyButton(icon: Icons.remove, onTap: item.quantity > 1 ? onDecrease : null),
                              SizedBox(
                                width: 32,
                                child: Text(
                                  '${item.quantity}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                ),
                              ),
                              _QtyButton(icon: Icons.add, onTap: onIncrease),
                            ],
                          ),
                        ),
                      ],
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

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _QtyButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 30,
        height: 30,
        child: Icon(
          icon,
          size: 14,
          color: onTap == null ? AppColors.mutedForeground : AppColors.secondary,
        ),
      ),
    );
  }
}
