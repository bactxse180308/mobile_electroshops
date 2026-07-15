import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/paging_controller_mixin.dart';
import '../../../models/models.dart';
import '../../../models/api_models.dart';
import '../../../services/product_service.dart';
import '../widgets/product_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_retry_view.dart';
import '../widgets/filter_sheet.dart';
import '../widgets/product_grid_shimmer.dart';
import '../widgets/category_header.dart';
import 'product_detail_screen.dart';

class CategoriesScreen extends StatefulWidget {
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
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> with PagingControllerMixin<Product> {
  // ── Search & Filter state ─────────────────────────────────────────────────
  late final TextEditingController _search;

  String _sort = AppStrings.sortPopular;
  bool _showSort = false;
  bool _showFilter = false;

  // Filter state — dùng ID từ API
  int? _selectedCategoryId;
  int? _selectedBrandId;
  String? _pickedPrice;
  double _minRating = 0;

  // ── Data state ────────────────────────────────────────────────────────────
  List<ApiBrandResponse> _apiBrands = []; // giữ nguyên để map id
  List<ApiCategoryResponse> _apiCategories = []; // Thêm để map category

  // ── Scroll controller cho infinite scroll ─────────────────────────────────
  final ScrollController _scrollCtrl = ScrollController();

  // ── Constant ──────────────────────────────────────────────────────────────
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
    _search = TextEditingController(text: widget.initialQuery ?? '');
    _selectedCategoryId = widget.initialCategoryId;
    _selectedBrandId = widget.initialBrandId;

    _scrollCtrl.addListener(_onScroll);
    _loadBrandsAndCategories();
    _loadProducts(reset: true);
  }

  @override
  void dispose() {
    _search.dispose();
    disposePaging();
    _scrollCtrl.dispose();
    super.dispose();
  }

  // ── Infinite Scroll ───────────────────────────────────────────────────────
  void _onScroll() {
    if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 200) {
      if (!isLoadingMore && hasMore) _loadProducts(reset: false);
    }
  }

  // ── Sort mapping ──────────────────────────────────────────────────────────
  String? _sortParam(String sort) {
    if (sort == AppStrings.sortPriceAsc) return 'price,asc';
    if (sort == AppStrings.sortPriceDesc) return 'price,desc';
    if (sort == AppStrings.sortNewest) return 'createdDate,desc';
    if (sort == AppStrings.sortRatingDesc) return 'rating,desc';
    return 'soldCount,desc'; // Phổ biến
  }

  // ── Load brands and categories for filter ─────────────────────────────────
  Future<void> _loadBrandsAndCategories() async {
    try {
      final api = ProductService();
      final apiBrands = await api.getBrands();
      final apiCats = await api.getCategories();
      if (!mounted) return;
      setState(() {
        _apiBrands = apiBrands;
        _apiCategories = apiCats;
      });
    } catch (_) {
      // Load fail không critical, bỏ qua
    }
  }

  // ── Load products ─────────────────────────────────────────────────────────
  Future<void> _loadProducts({bool reset = false}) async {
    await loadPage(
      reset: reset,
      onUpdate: () {
        if (mounted) setState(() {});
      },
      fetcher: (page) async {
        final apiPage = await ProductService().getProducts(
          keyword: _search.text.trim().isEmpty ? null : _search.text.trim(),
          categoryId: _selectedCategoryId,
          brandId: _selectedBrandId,
          page: page,
          size: 20,
          sort: _sortParam(_sort),
        );

        final newProducts = apiPage.content.map((e) => Product.fromApi(e)).toList();

        // Client-side: filter rating and price (BE không có param này)
        final filtered = newProducts.where((p) {
          if (_minRating > 0 && p.rating < _minRating) return false;
          if (_pickedPrice != null) {
            final band = FilterSheet.priceBands.firstWhere((b) => b['id'] == _pickedPrice);
            if (p.price < (band['min'] as int) || p.price > (band['max'] as int)) return false;
          }
          return true;
        }).toList();

        return PagingResult(
          content: filtered,
          totalElements: apiPage.totalElements,
          isLast: apiPage.last,
        );
      },
    );
  }

  // ── Search debounce ───────────────────────────────────────────────────────
  void _onSearchChanged(String _) {
    debounce(() {
      _loadProducts(reset: true);
    });
  }

  // ── Active filter count ───────────────────────────────────────────────────
  int get _activeFilters =>
      (_selectedCategoryId != null ? 1 : 0) +
      (_selectedBrandId != null ? 1 : 0) +
      (_pickedPrice != null ? 1 : 0) +
      (_minRating > 0 ? 1 : 0);

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
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
              _loadProducts(reset: true);
            },
            onFilterTap: () => setState(() => _showFilter = true),
            activeFilters: _activeFilters,
            isLoading: isLoading,
            currentSort: _sort,
            onSortTap: () => setState(() => _showSort = !_showSort),
            catName: catName,
          ),

          // Product grid
          Expanded(
            child: Stack(
              children: [
                isLoading
                    ? const ProductGridShimmer()
                    : errorMessage != null
                        ? ErrorRetryView(
                            errorMessage: errorMessage,
                            onRetry: () => _loadProducts(reset: true),
                          )
                        : items.isEmpty
                            ? const EmptyState(
                                icon: Icons.search_off,
                                title: AppStrings.errProductNotFound,
                                body: AppStrings.filterEmptyMsg,
                              )
                            : _buildProductGrid(),

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
                            setState(() { _sort = s; _showSort = false; });
                            _loadProducts(reset: true);
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: AppSizes.p12, vertical: AppSizes.p10),
                            decoration: BoxDecoration(
                              color: _sort == s ? AppColors.primary.withValues(alpha: 0.05) : Colors.transparent,
                              borderRadius: BorderRadius.circular(AppSizes.r4),
                            ),
                            child: Text(s, style: TextStyle(fontSize: 13, color: _sort == s ? AppColors.primary : AppColors.secondary, fontWeight: _sort == s ? FontWeight.w600 : FontWeight.normal)),
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
                      apiBrands: _apiBrands,
                      apiCategories: _apiCategories,
                      selectedCategoryId: _selectedCategoryId,
                      selectedBrandId: _selectedBrandId,
                      pickedPrice: _pickedPrice,
                      minRating: _minRating,
                      resultCount: totalCount,
                      onApply: (catId, brandId, price, rating) {
                        setState(() {
                          _selectedCategoryId = catId;
                          _selectedBrandId = brandId;
                          _pickedPrice = price;
                          _minRating = rating;
                          _showFilter = false;
                        });
                        _loadProducts(reset: true);
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

  Widget _buildProductGrid() {
    return GridView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.all(AppSizes.p12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: AppSizes.p12, mainAxisSpacing: AppSizes.p12, childAspectRatio: 0.52,
      ),
      itemCount: items.length + (isLoadingMore ? 1 : 0),
      itemBuilder: (context, i) {
        if (i >= items.length) {
          return const Center(child: Padding(
            padding: EdgeInsets.all(AppSizes.p16),
            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
          ));
        }
        return ProductCard(
          product: items[i],
          onTap: () => Navigator.push(context, MaterialPageRoute(
            builder: (_) => ProductDetailScreen(productId: items[i].id),
          )),
        );
      },
    );
  }
}
