import 'package:flutter/material.dart';
import '../../../../models/models.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/format_utils.dart';

enum ProductCardVariant { grid, horizontal }

class ProductCard extends StatelessWidget {
  final Product product;
  final ProductCardVariant variant;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.product,
    this.variant = ProductCardVariant.grid,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final discount = ((product.oldPrice - product.price) / product.oldPrice * 100).round();

    if (variant == ProductCardVariant.horizontal) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: 160,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppSizes.r12),
            boxShadow: AppShadows.card,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSizes.r12)),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        product.images[0],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColors.muted,
                          child: const Icon(Icons.image_not_supported, color: AppColors.mutedForeground),
                        ),
                      ),
                      if (discount > 0)
                        Positioned(
                          top: 6,
                          left: 6,
                          child: _flashBadge('-$discount%'),
                        ),
                      if (product.freeShip)
                        Positioned(
                          bottom: 6,
                          left: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.95),
                              borderRadius: BorderRadius.circular(AppSizes.r4),
                            ),
                            child: const Text(AppStrings.freeBadge, style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSizes.p8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(fontSize: 11, color: AppColors.secondary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSizes.p4),
                    Text(formatVNDShort(product.price), style: AppTextStyles.price.copyWith(fontSize: 13)),
                    Text(formatVNDShort(product.oldPrice), style: AppTextStyles.priceOld),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppSizes.r12),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSizes.r12)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      product.images[0],
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.muted,
                        child: const Icon(Icons.image_not_supported, color: AppColors.mutedForeground, size: 36),
                      ),
                    ),
                    if (discount > 0)
                      Positioned(top: 8, left: 8, child: _flashBadge('-$discount%')),
                    if (product.stock == 0)
                      Container(
                        color: Colors.black.withValues(alpha: 0.4),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.destructive,
                              borderRadius: BorderRadius.circular(AppSizes.r6),
                            ),
                            child: const Text(AppStrings.stockOut, style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ),
                    if (product.badge == 'Mới' && product.stock > 0)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            gradient: AppColors.neonGradient,
                            borderRadius: BorderRadius.circular(AppSizes.r6),
                          ),
                          child: const Text(AppStrings.hotBadge, style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSizes.p8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 42,
                    child: Text(
                      product.name,
                      style: const TextStyle(fontSize: 13, color: AppColors.secondary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: AppSizes.p4),
                  Text(formatVND(product.price), style: AppTextStyles.price),
                  Text(formatVND(product.oldPrice), style: AppTextStyles.priceOld),
                  const SizedBox(height: AppSizes.p6),
                  Wrap(
                    spacing: AppSizes.p4,
                    children: [
                      if (product.freeShip)
                        _tagBadge(AppStrings.freeShip, AppColors.success),
                      if (product.installment)
                        _tagBadge(AppStrings.installment0, AppColors.accent),
                    ],
                  ),
                  const SizedBox(height: AppSizes.p6),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 12, color: AppColors.accent),
                      const SizedBox(width: 2),
                      Text(product.rating.toStringAsFixed(1), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.secondary)),
                      const Text(' · ', style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                      Text('${AppStrings.soldCount} ${formatSold(product.sold)}', style: const TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _flashBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        gradient: AppColors.flashGradient,
        borderRadius: BorderRadius.circular(AppSizes.r4),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
    );
  }

  Widget _tagBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSizes.r4),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w800)),
    );
  }
}
