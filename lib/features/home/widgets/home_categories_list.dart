import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/models.dart';
import 'home_section_header.dart';

class HomeCategoriesList extends StatelessWidget {
  final List<Category> categories;
  final void Function(int? categoryId, String? categoryName)? onCategoryTap;

  const HomeCategoriesList({
    super.key,
    required this.categories,
    this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const HomeSectionHeader(title: AppStrings.filterCategories),
        SizedBox(
          height: 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSizes.p12),
            itemBuilder: (context, i) {
              final cat = categories[i];
              final isEven = i % 2 == 0;
              return GestureDetector(
                onTap: () => onCategoryTap?.call(
                  int.tryParse(cat.id),
                  cat.name,
                ),
                child: SizedBox(
                  width: 64,
                  child: Column(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: isEven
                                ? [const Color(0xFFFEF3C7), Colors.white]
                                : [const Color(0xFFEFF6FF), Colors.white],
                          ),
                          borderRadius: BorderRadius.circular(AppSizes.r16),
                          boxShadow: AppShadows.card,
                        ),
                        child: Icon(cat.icon, size: 24, color: AppColors.primary),
                      ),
                      const SizedBox(height: AppSizes.p6),
                      Text(
                        cat.name,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
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
