import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/models.dart';
import '../../product/widgets/product_card.dart';
import 'countdown_timer.dart';

class HomeFlashSale extends StatelessWidget {
  final List<Product> products;
  final ValueChanged<String> onProductTap;
  final VoidCallback onViewAllTap;

  const HomeFlashSale({
    super.key,
    required this.products,
    required this.onProductTap,
    required this.onViewAllTap,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.r16),
          boxShadow: AppShadows.lift,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.r16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16, vertical: AppSizes.p12),
                decoration: const BoxDecoration(gradient: AppColors.flashGradient),
                child: Row(
                  children: const [
                    Icon(Icons.local_fire_department, color: Colors.white, size: 20),
                    SizedBox(width: AppSizes.p8),
                    Text(
                      AppStrings.sectionFlashSale,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Spacer(),
                    CountdownTimer(),
                  ],
                ),
              ),
              Container(
                color: AppColors.card,
                child: Column(
                  children: [
                    SizedBox(
                      height: 230,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.all(AppSizes.p12),
                        itemCount: products.length,
                        separatorBuilder: (_, __) => const SizedBox(width: AppSizes.p10),
                        itemBuilder: (context, i) => ProductCard(
                          product: products[i],
                          variant: ProductCardVariant.horizontal,
                          onTap: () => onProductTap(products[i].id),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: onViewAllTap,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: AppSizes.p10),
                        decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.border))),
                        child: const Text(
                          '${AppStrings.viewAll} →',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
