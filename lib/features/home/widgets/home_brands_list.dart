import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/models.dart';
import 'home_section_header.dart';

class HomeBrandsList extends StatelessWidget {
  final List<Brand> brands;
  final void Function(int? brandId, String? brandName)? onBrandTap;

  const HomeBrandsList({
    super.key,
    required this.brands,
    this.onBrandTap,
  });

  @override
  Widget build(BuildContext context) {
    if (brands.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const HomeSectionHeader(title: AppStrings.featuredBrands),
        SizedBox(
          height: 56,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
            itemCount: brands.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSizes.p10),
            itemBuilder: (context, i) {
              final b = brands[i];
              return GestureDetector(
                onTap: () => onBrandTap?.call(
                  int.tryParse(b.id),
                  b.name,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(AppSizes.r12),
                    boxShadow: AppShadows.card,
                  ),
                  child: Center(
                    child: Text(
                      b.name,
                      style: TextStyle(color: b.color, fontSize: 13, fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
