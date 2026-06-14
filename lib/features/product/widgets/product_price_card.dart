import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../models/models.dart';

class ProductPriceCard extends StatelessWidget {
  final Product product;
  const ProductPriceCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final discount = product.oldPrice > product.price
        ? ((product.oldPrice - product.price) / product.oldPrice * 100).round()
        : 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
      padding: const EdgeInsets.all(AppSizes.p16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.r12),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatVND(product.price),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.primary),
              ),
              if (discount > 0) ...[
                const SizedBox(width: AppSizes.p8),
                Text(formatVND(product.oldPrice), style: AppTextStyles.priceOld.copyWith(fontSize: 13)),
                const SizedBox(width: AppSizes.p8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.p6, vertical: 2),
                  decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(AppSizes.r4)),
                  child: Text(
                    '-$discount%',
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSizes.p8),
          Text(product.name, style: AppTextStyles.h2),
          const SizedBox(height: AppSizes.p8),
          Row(
            children: [
              const Icon(Icons.star, size: 14, color: AppColors.accent),
              const SizedBox(width: AppSizes.p4),
              Text(
                product.rating.toStringAsFixed(1),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.secondary),
              ),
              Text(' (${product.reviews})', style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
              const Text(' · ', style: TextStyle(color: AppColors.mutedForeground)),
              Text('${AppStrings.soldCount} ${formatSold(product.sold)}', style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
              const Text(' · ', style: TextStyle(color: AppColors.mutedForeground)),
              Text(
                product.stock > 0 ? AppStrings.stockIn : AppStrings.stockOut,
                style: TextStyle(
                  fontSize: 12,
                  color: product.stock > 0 ? AppColors.success : AppColors.destructive,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
