import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../models/models.dart';
import '../../product/widgets/product_card.dart';

class HomeProductGrid extends StatelessWidget {
  final List<Product> products;
  final ValueChanged<String> onProductTap;

  const HomeProductGrid({
    super.key,
    required this.products,
    required this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: AppSizes.p12,
        mainAxisSpacing: AppSizes.p12,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 0.52,
        children: products.map((p) => ProductCard(
          product: p,
          onTap: () => onProductTap(p.id),
        )).toList(),
      ),
    );
  }
}
