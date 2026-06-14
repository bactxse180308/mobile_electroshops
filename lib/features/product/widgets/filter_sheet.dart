import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../../../models/api_models.dart';

class FilterSheet extends StatefulWidget {
  final List<ApiBrandResponse> apiBrands;
  final List<ApiCategoryResponse> apiCategories;
  final int? selectedCategoryId;
  final int? selectedBrandId;
  final String? pickedPrice;
  final double minRating;
  final int resultCount;
  final Function(int? catId, int? brandId, String? price, double rating) onApply;
  final VoidCallback onClose;

  static final priceBands = [
    {'id': 'u1m', 'label': AppStrings.priceUnder1m, 'min': 0, 'max': 999999},
    {'id': '1-3', 'label': AppStrings.price1to3m, 'min': 1000000, 'max': 3000000},
    {'id': '3-5', 'label': AppStrings.price3to5m, 'min': 3000000, 'max': 5000000},
    {'id': '5p', 'label': AppStrings.priceOver5m, 'min': 5000000, 'max': 999999999},
  ];

  const FilterSheet({
    super.key,
    required this.apiBrands,
    required this.apiCategories,
    required this.selectedCategoryId,
    required this.selectedBrandId,
    required this.pickedPrice,
    required this.minRating,
    required this.resultCount,
    required this.onApply,
    required this.onClose,
  });

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  int? _catId;
  int? _brandId;
  String? _price;
  double _rating = 0;

  @override
  void initState() {
    super.initState();
    _catId = widget.selectedCategoryId;
    _brandId = widget.selectedBrandId;
    _price = widget.pickedPrice;
    _rating = widget.minRating;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onClose,
      child: Container(
        color: Colors.black54,
        child: Column(
          children: [
            const Spacer(),
            GestureDetector(
              onTap: () {},
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: AppSizes.p10),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSizes.p20, vertical: AppSizes.p12),
                      child: Row(
                        children: [
                          const Text(AppStrings.filterTitle, style: AppTextStyles.h3),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            onPressed: widget.onClose,
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 400),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(AppSizes.p20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Price range
                            const Text(
                              AppStrings.priceRange,
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.secondary),
                            ),
                            const SizedBox(height: AppSizes.p8),
                            GridView.count(
                              crossAxisCount: 2,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisSpacing: AppSizes.p8,
                              mainAxisSpacing: AppSizes.p8,
                              childAspectRatio: 3,
                              children: FilterSheet.priceBands.map((b) {
                                final active = _price == b['id'];
                                return GestureDetector(
                                  onTap: () => setState(() => _price = active ? null : b['id'] as String),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: active ? AppColors.primary : AppColors.border),
                                      color: active ? AppColors.primary.withValues(alpha: 0.05) : Colors.transparent,
                                      borderRadius: BorderRadius.circular(AppSizes.r8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        b['label'] as String,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: active ? AppColors.primary : AppColors.secondary,
                                          fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            // Categories
                            if (widget.apiCategories.isNotEmpty) ...[
                              const SizedBox(height: AppSizes.p16),
                              const Text(
                                AppStrings.filterCategories,
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.secondary),
                              ),
                              const SizedBox(height: AppSizes.p8),
                              Wrap(
                                spacing: AppSizes.p8,
                                runSpacing: AppSizes.p8,
                                children: widget.apiCategories.map((c) {
                                  final active = _catId == c.categoryId;
                                  return GestureDetector(
                                    onTap: () => setState(() => _catId = active ? null : c.categoryId),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: AppSizes.p12, vertical: AppSizes.p6),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: active ? AppColors.primary : AppColors.border),
                                        color: active ? AppColors.primary.withValues(alpha: 0.05) : Colors.transparent,
                                        borderRadius: BorderRadius.circular(AppSizes.r20),
                                      ),
                                      child: Text(
                                        c.categoryName,
                                        style: TextStyle(fontSize: 12, color: active ? AppColors.primary : AppColors.secondary),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                            // Brands
                            if (widget.apiBrands.isNotEmpty) ...[
                              const SizedBox(height: AppSizes.p16),
                              const Text(
                                AppStrings.filterBrands,
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.secondary),
                              ),
                              const SizedBox(height: AppSizes.p8),
                              Wrap(
                                spacing: AppSizes.p8,
                                runSpacing: AppSizes.p8,
                                children: widget.apiBrands.map((b) {
                                  final active = _brandId == b.brandId;
                                  return GestureDetector(
                                    onTap: () => setState(() => _brandId = active ? null : b.brandId),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: AppSizes.p12, vertical: AppSizes.p6),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: active ? AppColors.primary : AppColors.border),
                                        color: active ? AppColors.primary.withValues(alpha: 0.05) : Colors.transparent,
                                        borderRadius: BorderRadius.circular(AppSizes.r20),
                                      ),
                                      child: Text(
                                        b.brandName,
                                        style: TextStyle(fontSize: 12, color: active ? AppColors.primary : AppColors.secondary),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                            // Rating
                            const SizedBox(height: AppSizes.p16),
                            const Text(
                              AppStrings.minRating,
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.secondary),
                            ),
                            const SizedBox(height: AppSizes.p8),
                            Row(
                              children: [0.0, 3.0, 4.0, 4.5].map((r) {
                                final active = _rating == r;
                                return Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(() => _rating = r),
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 3),
                                      height: 40,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: active ? AppColors.accent : AppColors.border),
                                        color: active ? AppColors.accent.withValues(alpha: 0.1) : Colors.transparent,
                                        borderRadius: BorderRadius.circular(AppSizes.r8),
                                      ),
                                      child: Center(
                                        child: Text(
                                          r == 0 ? AppStrings.all : '${r.toStringAsFixed(r == 4.5 ? 1 : 0)}★',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                                            color: active ? AppColors.accent : AppColors.secondary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(AppSizes.p16),
                      child: Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              label: AppStrings.clearFilter,
                              variant: AppButtonVariant.secondary,
                              onPressed: () => setState(() {
                                _catId = null;
                                _brandId = null;
                                _price = null;
                                _rating = 0;
                              }),
                            ),
                          ),
                          const SizedBox(width: AppSizes.p8),
                          Expanded(
                            child: AppButton(
                              label: AppStrings.applyFilter,
                              variant: AppButtonVariant.gradient,
                              onPressed: () => widget.onApply(_catId, _brandId, _price, _rating),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).padding.bottom),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
