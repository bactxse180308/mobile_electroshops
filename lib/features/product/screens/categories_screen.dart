import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/categories_provider.dart';
import '../widgets/product_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_retry_view.dart';
import '../widgets/filter_sheet.dart';
import '../widgets/product_grid_shimmer.dart';
import '../widgets/category_header.dart';
import 'product_detail_screen.dart';

class CategoriesScreen extends StatelessWidget {
  final int? initialCategoryId;
  final String? initialCategoryName;
  final int? initialBrandId;
  final String? initialQuery;

  const CategoriesScreen({
    super.key,
    this.initialCategoryId,
    this.initialCategoryName,
    this.initialBrandId,
    this.initialQuery,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CategoriesProvider()..init(
        categoryId: initialCategoryId,
        brandId: initialBrandId,
        query: initialQuery,
      ),
      child: _CategoriesView(initialCategoryName: initialCategoryName),
    );
  }
}

class _CategoriesView extends StatefulWidget {
  final String? initialCategoryName;
  const _CategoriesView({this.initialCategoryName});

  @override
  State<_CategoriesView> createState() => _CategoriesViewState();
}

class _CategoriesViewState extends State<_CategoriesView> {
  late final TextEditingController _search;
  Timer? _debounce;
  bool _showSort = false;
  bool _showFilter = false;

  final ScrollController _scrollCtrl = ScrollController();

  static const _sorts = [
    AppStrings.sortPopular,
    AppStrings.sortPriceAsc,
    AppStrings.sortPriceDesc,
    AppStrings.sortNewest,
    AppStrings.sortRatingDesc,
  ];

  @override
  void initState() {
    super.initState();
    final initialQuery = context.read<CategoriesProvider>().searchQuery;
    _search = TextEditingController(text: initialQuery);
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _search.dispose();
    _debounce?.cancel();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 200) {
      final provider = context.read<CategoriesProvider>();
      if (!provider.isLoadingMore && !provider.isLastPage) {
        provider.loadProducts();
      }
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<CategoriesProvider>().setSearchQuery(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CategoriesProvider>();
    final catName = widget.initialCategoryName;

    return Material(
      color: AppColors.background,
      child: Column(
        children: [
          CategoryHeader(
            searchController: _search,
            onSearchChanged: _onSearchChanged,
            onClearSearch: () {
              _search.clear();
              provider.setSearchQuery('');
            },
            onFilterTap: () => setState(() => _showFilter = true),
            activeFilters: provider.activeFilters,
            isLoading: provider.isLoading,
            currentSort: provider.sort,
            onSortTap: () => setState(() => _showSort = !_showSort),
            catName: catName,
          ),

          // Product grid
          Expanded(
            child: Stack(
              children: [
                provider.isLoading
                    ? const ProductGridShimmer()
                    : provider.errorMessage != null
                        ? ErrorRetryView(
                            errorMessage: provider.errorMessage,
                            onRetry: () => provider.loadProducts(reset: true),
                          )
                        : provider.products.isEmpty
                            ? const EmptyState(
                                icon: Icons.search_off,
                                title: AppStrings.errProductNotFound,
                                body: AppStrings.filterEmptyMsg,
                              )
                            : _buildProductGrid(provider),

                // Sort dropdown overlay
                if (_showSort) ...[
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () => setState(() => _showSort = false),
                      child: Container(color: Colors.transparent),
                    ),
                  ),
                  Positioned(
                    top: 0, right: 12,
                    child: Container(
                      width: 176,
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(AppSizes.r12),
                        boxShadow: AppShadows.lift,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: _sorts.map((s) => GestureDetector(
                          onTap: () {
                            setState(() => _showSort = false);
                            provider.setSort(s);
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: AppSizes.p12, vertical: AppSizes.p10),
                            decoration: BoxDecoration(
                              color: provider.sort == s ? AppColors.primary.withValues(alpha: 0.05) : Colors.transparent,
                              borderRadius: BorderRadius.circular(AppSizes.r4),
                            ),
                            child: Text(s, style: TextStyle(fontSize: 13, color: provider.sort == s ? AppColors.primary : AppColors.secondary, fontWeight: provider.sort == s ? FontWeight.w600 : FontWeight.normal)),
                          ),
                        )).toList(),
                      ),
                    ),
                  ),
                ],

                // Filter bottom sheet
                if (_showFilter)
                  Positioned.fill(
                    child: FilterSheet(
                      apiBrands: provider.apiBrands,
                      apiCategories: provider.apiCategories,
                      selectedCategoryId: provider.selectedCategoryId,
                      selectedBrandId: provider.selectedBrandId,
                      pickedPrice: provider.pickedPrice,
                      minRating: provider.minRating,
                      resultCount: provider.totalElements,
                      onApply: (catId, brandId, price, rating) {
                        setState(() => _showFilter = false);
                        provider.applyFilter(catId, brandId, price, rating);
                      },
                      onClose: () => setState(() => _showFilter = false),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid(CategoriesProvider provider) {
    return GridView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.all(AppSizes.p12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: AppSizes.p12, mainAxisSpacing: AppSizes.p12, childAspectRatio: 0.52,
      ),
      itemCount: provider.products.length + (provider.isLoadingMore ? 1 : 0),
      itemBuilder: (context, i) {
        if (i >= provider.products.length) {
          return const Center(child: Padding(
            padding: EdgeInsets.all(AppSizes.p16),
            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
          ));
        }
        return ProductCard(
          product: provider.products[i],
          onTap: () => Navigator.push(context, MaterialPageRoute(
            builder: (_) => ProductDetailScreen(productId: provider.products[i].id),
          )),
        );
      },
    );
  }
}
