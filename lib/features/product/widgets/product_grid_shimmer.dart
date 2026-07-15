import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/shimmer_box.dart';

class ProductGridShimmer extends StatelessWidget {
  final int itemCount;
  final EdgeInsetsGeometry padding;

  const ProductGridShimmer({
    super.key,
    this.itemCount = 6,
    this.padding = const EdgeInsets.all(AppSizes.p12),
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: padding,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSizes.p12,
        mainAxisSpacing: AppSizes.p12,
        childAspectRatio: 0.52,
      ),
      itemCount: itemCount,
      itemBuilder: (_, __) => const ShimmerBox(
        height: double.infinity,
        width: double.infinity,
        radius: AppSizes.r12,
      ),
    );
  }
}
