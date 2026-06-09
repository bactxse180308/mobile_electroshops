import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../models/api_models.dart';
import '../services/api_service.dart';
import '../widgets/product_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/app_button.dart';
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

class _CategoriesScreenState extends State<CategoriesScreen> {
  // ── Search & Filter state ─────────────────────────────────────────────────
  late final TextEditingController _search;
  Timer? _debounce;

  String _sort = 'Phổ biến';
  bool _showSort = false;
  bool _showFilter = false;

  // Filter state — dùng ID từ API
  int? _selectedCategoryId;
  int? _selectedBrandId;
  String? _pickedPrice;
  double _minRating = 0;

  // ── Data state ────────────────────────────────────────────────────────────
  List<Brand> _brands = [];            // dùng để hiển thị filter brands
  List<ApiBrandResponse> _apiBrands = []; // giữ nguyên để map id
  List<ApiCategoryResponse> _apiCategories = []; // Thêm để map category
  List<Product> _products = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentPage = 0;
  int _totalCount = 0;
  String? _errorMessage;

  // ── Scroll controller cho infinite scroll ─────────────────────────────────
  final ScrollController _scrollCtrl = ScrollController();

  // ── Constant ──────────────────────────────────────────────────────────────
  static const _sorts = ['Phổ biến', 'Giá tăng dần', 'Giá giảm dần', 'Mới nhất', 'Đánh giá cao'];
  static final _priceBands = [
    {'id': 'u1m', 'label': 'Dưới 1tr', 'min': 0, 'max': 999999},
    {'id': '1-3', 'label': '1tr - 3tr', 'min': 1000000, 'max': 3000000},
    {'id': '3-5', 'label': '3tr - 5tr', 'min': 3000000, 'max': 5000000},
    {'id': '5p', 'label': 'Trên 5tr', 'min': 5000000, 'max': 999999999},
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
    _debounce?.cancel();
    _scrollCtrl.dispose();
    super.dispose();
  }

  // ── Infinite Scroll ───────────────────────────────────────────────────────
  void _onScroll() {
    if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _hasMore) _loadMore();
    }
  }

  // ── Sort mapping ──────────────────────────────────────────────────────────
  String? _sortParam(String sort) {
    switch (sort) {
      case 'Giá tăng dần': return 'price,asc';
      case 'Giá giảm dần': return 'price,desc';
      case 'Mới nhất': return 'createdDate,desc';
      case 'Đánh giá cao': return 'rating,desc';
      default: return 'soldCount,desc'; // Phổ biến
    }
  }

  // ── Load brands and categories for filter ─────────────────────────────────
  Future<void> _loadBrandsAndCategories() async {
    try {
      final api = ApiService();
      final apiBrands = await api.getBrands();
      final apiCats = await api.getCategories();
      if (!mounted) return;
      setState(() {
        _apiBrands = apiBrands;
        _brands = apiBrands.map((b) => Brand.fromApi(b)).toList();
        _apiCategories = apiCats;
      });
    } catch (_) {
      // Load fail không critical, bỏ qua
    }
  }

  // ── Load products (fresh) ─────────────────────────────────────────────────
  Future<void> _loadProducts({bool reset = false}) async {
    if (_isLoading) return;
    if (reset) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _currentPage = 0;
        _products = [];
        _hasMore = true;
      });
    }

    try {
      final page = await ApiService().getProducts(
        keyword: _search.text.trim().isEmpty ? null : _search.text.trim(),
        categoryId: _selectedCategoryId,
        brandId: _selectedBrandId,
        page: _currentPage,
        size: 20,
        sort: _sortParam(_sort),
      );

      if (!mounted) return;

      final newProducts = page.content.map((e) => Product.fromApi(e)).toList();

      // Client-side: filter rating and price (BE không có param này)
      final filtered = newProducts.where((p) {
        if (_minRating > 0 && p.rating < _minRating) return false;
        if (_pickedPrice != null) {
          final band = _priceBands.firstWhere((b) => b['id'] == _pickedPrice);
          if (p.price < (band['min'] as int) || p.price > (band['max'] as int)) return false;
        }
        return true;
      }).toList();

      setState(() {
        _products = filtered;
        _totalCount = page.totalElements;
        _hasMore = !page.last;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e is ApiException ? e.message : e.toString();
        _isLoading = false;
      });
    }
  }

  // ── Load more (next page) ─────────────────────────────────────────────────
  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() { _isLoadingMore = true; });

    try {
      final page = await ApiService().getProducts(
        keyword: _search.text.trim().isEmpty ? null : _search.text.trim(),
        categoryId: _selectedCategoryId,
        brandId: _selectedBrandId,
        page: _currentPage + 1,
        size: 20,
        sort: _sortParam(_sort),
      );

      if (!mounted) return;

      final newProducts = page.content.map((e) => Product.fromApi(e)).toList();
      final filtered = newProducts.where((p) {
        if (_minRating > 0 && p.rating < _minRating) return false;
        if (_pickedPrice != null) {
          final band = _priceBands.firstWhere((b) => b['id'] == _pickedPrice);
          if (p.price < (band['min'] as int) || p.price > (band['max'] as int)) return false;
        }
        return true;
      }).toList();

      setState(() {
        _currentPage++;
        _products.addAll(filtered);
        _hasMore = !page.last;
        _isLoadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() { _isLoadingMore = false; });
    }
  }

  // ── Search debounce ───────────────────────────────────────────────────────
  void _onSearchChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
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
          Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 4, bottom: 0),
            color: AppColors.background,
            child: Column(
              children: [
                // Search bar
                Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left, size: 28, color: AppColors.secondary),
                        onPressed: () => Navigator.maybePop(context),
                      ),
                      Expanded(
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(color: AppColors.muted, borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            children: [
                              const Icon(Icons.search, size: 16, color: AppColors.mutedForeground),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _search,
                                  onChanged: _onSearchChanged,
                                  decoration: InputDecoration(
                                    hintText: catName != null ? 'Tìm trong $catName' : 'Tìm sản phẩm…',
                                    hintStyle: const TextStyle(fontSize: 13, color: AppColors.mutedForeground),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                              if (_search.text.isNotEmpty)
                                GestureDetector(
                                  onTap: () {
                                    _search.clear();
                                    _loadProducts(reset: true);
                                  },
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
                            onPressed: () => setState(() => _showFilter = true),
                          ),
                          if (_activeFilters > 0)
                            Positioned(
                              top: 8, right: 6,
                              child: Container(
                                width: 16, height: 16,
                                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                                child: Center(child: Text('$_activeFilters', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700))),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Count + sort row
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                  child: Row(
                    children: [
                      Text(
                        _isLoading ? 'Đang tải…' : '$_totalCount sản phẩm',
                        style: const TextStyle(fontSize: 11, color: AppColors.mutedForeground),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => setState(() => _showSort = !_showSort),
                        child: Row(
                          children: [
                            const Icon(Icons.swap_vert, size: 14, color: AppColors.secondary),
                            const SizedBox(width: 4),
                            Text(_sort, style: const TextStyle(fontSize: 12, color: AppColors.secondary, fontWeight: FontWeight.w500)),
                            const Icon(Icons.expand_more, size: 12, color: AppColors.secondary),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Product grid
          Expanded(
            child: Stack(
              children: [
                _isLoading
                    ? _buildLoadingGrid()
                    : _errorMessage != null
                        ? _buildErrorState()
                        : _products.isEmpty
                            ? const EmptyState(
                                icon: Icons.search_off,
                                title: 'Không tìm thấy sản phẩm',
                                body: 'Thử tìm với từ khoá khác hoặc bỏ bớt bộ lọc.',
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
                        borderRadius: BorderRadius.circular(12),
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
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: _sort == s ? AppColors.primary.withOpacity(0.05) : Colors.transparent,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(s, style: TextStyle(fontSize: 13, color: _sort == s ? AppColors.primary : AppColors.secondary, fontWeight: _sort == s ? FontWeight.w600 : FontWeight.normal)),
                          ),
                        )).toList(),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Filter bottom sheet
          if (_showFilter)
            _FilterSheet(
              apiBrands: _apiBrands,
              apiCategories: _apiCategories,
              selectedCategoryId: _selectedCategoryId,
              selectedBrandId: _selectedBrandId,
              pickedPrice: _pickedPrice,
              minRating: _minRating,
              priceBands: _priceBands,
              resultCount: _totalCount,
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
        ],
      ),
    );
  }

  Widget _buildLoadingGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.52,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => _GridShimmer(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off_rounded, size: 48, color: AppColors.mutedForeground),
          const SizedBox(height: 12),
          Text(_errorMessage ?? 'Lỗi không xác định',
              style: const TextStyle(color: AppColors.mutedForeground, fontSize: 13),
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => _loadProducts(reset: true),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(gradient: AppColors.heroGradient, borderRadius: BorderRadius.circular(10)),
              child: const Text('Thử lại', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid() {
    return GridView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.52,
      ),
      itemCount: _products.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, i) {
        if (i >= _products.length) {
          return const Center(child: Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
          ));
        }
        return ProductCard(
          product: _products[i],
          onTap: () => Navigator.push(context, MaterialPageRoute(
            builder: (_) => ProductDetailScreen(productId: _products[i].id),
          )),
        );
      },
    );
  }
}

// ── Shimmer card for grid ─────────────────────────────────────────────────────
class _GridShimmer extends StatefulWidget {
  @override
  State<_GridShimmer> createState() => _GridShimmerState();
}

class _GridShimmerState extends State<_GridShimmer> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 0.7).animate(_ctrl);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(_anim.value),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

// ── Filter bottom sheet ───────────────────────────────────────────────────────
class _FilterSheet extends StatefulWidget {
  final List<ApiBrandResponse> apiBrands;
  final List<ApiCategoryResponse> apiCategories;
  final int? selectedCategoryId;
  final int? selectedBrandId;
  final String? pickedPrice;
  final double minRating;
  final List<Map<String, dynamic>> priceBands;
  final int resultCount;
  final Function(int? catId, int? brandId, String? price, double rating) onApply;
  final VoidCallback onClose;

  const _FilterSheet({
    required this.apiBrands,
    required this.apiCategories,
    required this.selectedCategoryId,
    required this.selectedBrandId,
    required this.pickedPrice,
    required this.minRating,
    required this.priceBands,
    required this.resultCount,
    required this.onApply,
    required this.onClose,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
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
                    Container(margin: const EdgeInsets.only(top: 10), width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      child: Row(
                        children: [
                          const Text('Bộ lọc', style: AppTextStyles.h3),
                          const Spacer(),
                          IconButton(icon: const Icon(Icons.close, size: 20), onPressed: widget.onClose),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 400),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Price range
                            const Text('Khoảng giá', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.secondary)),
                            const SizedBox(height: 8),
                            GridView.count(
                              crossAxisCount: 2,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 3,
                              children: widget.priceBands.map((b) {
                                final active = _price == b['id'];
                                return GestureDetector(
                                  onTap: () => setState(() => _price = active ? null : b['id'] as String),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: active ? AppColors.primary : AppColors.border),
                                      color: active ? AppColors.primary.withOpacity(0.05) : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(child: Text(b['label'] as String, style: TextStyle(fontSize: 13, color: active ? AppColors.primary : AppColors.secondary, fontWeight: active ? FontWeight.w600 : FontWeight.normal))),
                                  ),
                                );
                              }).toList(),
                            ),
                            // Categories
                            if (widget.apiCategories.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              const Text('Danh mục', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.secondary)),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: widget.apiCategories.map((c) {
                                  final active = _catId == c.categoryId;
                                  return GestureDetector(
                                    onTap: () => setState(() => _catId = active ? null : c.categoryId),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: active ? AppColors.primary : AppColors.border),
                                        color: active ? AppColors.primary.withOpacity(0.05) : Colors.transparent,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(c.categoryName, style: TextStyle(fontSize: 12, color: active ? AppColors.primary : AppColors.secondary)),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                            // Brands
                            if (widget.apiBrands.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              const Text('Thương hiệu', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.secondary)),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: widget.apiBrands.map((b) {
                                  final active = _brandId == b.brandId;
                                  return GestureDetector(
                                    onTap: () => setState(() => _brandId = active ? null : b.brandId),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: active ? AppColors.primary : AppColors.border),
                                        color: active ? AppColors.primary.withOpacity(0.05) : Colors.transparent,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(b.brandName, style: TextStyle(fontSize: 12, color: active ? AppColors.primary : AppColors.secondary)),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                            // Rating
                            const SizedBox(height: 16),
                            const Text('Đánh giá tối thiểu', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.secondary)),
                            const SizedBox(height: 8),
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
                                        color: active ? AppColors.accent.withOpacity(0.1) : Colors.transparent,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(child: Text(r == 0 ? 'Tất cả' : '${r.toStringAsFixed(r == 4.5 ? 1 : 0)}★+', style: TextStyle(fontSize: 12, color: active ? AppColors.accent : AppColors.secondary))),
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
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              label: 'Xoá bộ lọc',
                              variant: AppButtonVariant.secondary,
                              onPressed: () => setState(() { _catId = null; _brandId = null; _price = null; _rating = 0; }),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: AppButton(
                              label: 'Áp dụng',
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
