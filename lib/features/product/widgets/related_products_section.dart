import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../models/models.dart';
import 'product_card.dart';

class RelatedProductsSection extends StatelessWidget {
  final List<Product> related;
  final ValueChanged<Product> onProductTap;

  const RelatedProductsSection({
    super.key,
    required this.related,
    required this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    if (related.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(AppSizes.p16, AppSizes.p16, AppSizes.p16, AppSizes.p8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(AppStrings.relatedProducts, style: AppTextStyles.h3),
          ),
        ),
        SizedBox(
          height: 230,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
            itemCount: related.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSizes.p10),
            itemBuilder: (context, i) => ProductCard(
              product: related[i],
              variant: ProductCardVariant.horizontal,
              onTap: () => onProductTap(related[i]),
            ),
          ),
        ),
      ],
    );
  }
}
