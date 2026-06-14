import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_strings.dart';

class ProductQuantitySelector extends StatelessWidget {
  final int quantity;
  final int stock;
  final ValueChanged<int> onChanged;

  const ProductQuantitySelector({
    super.key,
    required this.quantity,
    required this.stock,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(AppSizes.p16, AppSizes.p12, AppSizes.p16, 0),
      padding: const EdgeInsets.all(AppSizes.p16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.r12),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: [
          const Text(
            AppStrings.quantity,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.secondary),
          ),
          const Spacer(),
          _QtyBtn(
            icon: Icons.remove,
            onTap: quantity > 1 ? () => onChanged(quantity - 1) : null,
          ),
          const SizedBox(width: AppSizes.p12),
          SizedBox(
            width: AppSizes.p32,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.secondary),
            ),
          ),
          const SizedBox(width: AppSizes.p12),
          _QtyBtn(
            icon: Icons.add,
            onTap: quantity < stock ? () => onChanged(quantity + 1) : null,
          ),
        ],
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _QtyBtn({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: AppSizes.btnHeightSm,
        height: AppSizes.btnHeightSm,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppSizes.r8),
          color: onTap == null ? AppColors.muted : Colors.transparent,
        ),
        child: Icon(icon, size: AppSizes.iconSm, color: onTap == null ? AppColors.mutedForeground : AppColors.secondary),
      ),
    );
  }
}
