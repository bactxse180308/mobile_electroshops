import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_sizes.dart';

class CategoryHeader extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final VoidCallback onFilterTap;
  final int activeFilters;
  final bool isLoading;
  final String currentSort;
  final VoidCallback onSortTap;
  final String? catName;

  const CategoryHeader({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onFilterTap,
    required this.activeFilters,
    required this.isLoading,
    required this.currentSort,
    required this.onSortTap,
    this.catName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + AppSizes.p4, bottom: 0),
      color: AppColors.background,
      child: Column(
        children: [
          // Search bar
          Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.p4),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
            child: Row(
              children: [
                const SizedBox(width: AppSizes.p12),
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(color: AppColors.muted, borderRadius: BorderRadius.circular(AppSizes.r12)),
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.p12),
                    child: Row(
                      children: [
                        const Icon(Icons.search, size: 16, color: AppColors.mutedForeground),
                        const SizedBox(width: AppSizes.p8),
                        Expanded(
                          child: TextField(
                            controller: searchController,
                            onChanged: onSearchChanged,
                            decoration: InputDecoration(
                              hintText: catName != null ? '${AppStrings.searchInPrefix}$catName' : AppStrings.searchProductHint,
                              hintStyle: const TextStyle(fontSize: 13, color: AppColors.mutedForeground),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        if (searchController.text.isNotEmpty)
                          GestureDetector(
                            onTap: onClearSearch,
                            child: const Icon(Icons.close, size: 16, color: AppColors.mutedForeground),
                          ),
                      ],
                    ),
                  ),
                ),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.tune, size: 22, color: AppColors.secondary),
                      onPressed: onFilterTap,
                    ),
                    if (activeFilters > 0)
                      Positioned(
                        top: 8,
                        right: 6,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                          child: Center(
                            child: Text(
                              '$activeFilters',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Count + sort row
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSizes.p12, AppSizes.p8, AppSizes.p12, AppSizes.p8),
            child: Row(
              children: [
                Text(
                  isLoading ? AppStrings.loading : '',
                  style: const TextStyle(fontSize: 11, color: AppColors.mutedForeground),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onSortTap,
                  child: Row(
                    children: [
                      const Icon(Icons.swap_vert, size: 14, color: AppColors.secondary),
                      const SizedBox(width: AppSizes.p4),
                      Text(
                        currentSort,
                        style: const TextStyle(fontSize: 12, color: AppColors.secondary, fontWeight: FontWeight.w500),
                      ),
                      const Icon(Icons.expand_more, size: 12, color: AppColors.secondary),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
