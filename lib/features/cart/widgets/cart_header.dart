import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_theme.dart';

class CartHeader extends StatelessWidget {
  final int itemCount;
  final VoidCallback? onClear;

  const CartHeader({
    super.key,
    required this.itemCount,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).padding.top + 56,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          const SizedBox(width: AppSizes.p16),
          Text('${AppStrings.cartTitle} ($itemCount)', style: AppTextStyles.h3),
          const Spacer(),
          if (itemCount > 0 && onClear != null)
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 22, color: AppColors.secondary),
              onPressed: onClear,
            ),
          const SizedBox(width: AppSizes.p4),
        ],
      ),
    );
  }
}
