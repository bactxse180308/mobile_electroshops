import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../data/seed_data.dart';
import '../models/models.dart';
import '../widgets/product_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/app_button.dart';
import 'product_detail_screen.dart';

class CategoriesScreen extends StatefulWidget {
  final String? initialCategory;
  final String? initialQuery;

  const CategoriesScreen({super.key, this.initialCategory, this.initialQuery});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  late final TextEditingController _search;
  String _chip = 'Tất cả';
  String _sort = 'Phổ biến';
  bool _showSort = false;
  bool _showFilter = false;
  List<String> _pickedBrands = [];
  String? _pickedPrice;
  double _minRating = 0;

  static const _filters = ['Tất cả', 'Kingston', 'Samsung', 'Logitech', 'Sony', 'Razer', 'Còn hàng'];
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
    if (widget.initialCategory != null) {
      // set the chip to show category name if available
    }
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<Product> get _filtered {
    var r = List<Product>.from(products);
    if (widget.initialCategory != null) r = r.where((p) => p.category == widget.initialCategory).toList();
    final q = _search.text.toLowerCase();
    if (q.isNotEmpty) r = r.where((p) => p.name.toLowerCase().contains(q) || p.brand.toLowerCase().contains(q)).toList();
    if (_chip == 'Còn hàng') r = r.where((p) => p.stock > 0).toList();
    else if (_chip != 'Tất cả') r = r.where((p) => p.brand == _chip).toList();
    if (_pickedBrands.isNotEmpty) r = r.where((p) => _pickedBrands.contains(p.brand)).toList();
    if (_pickedPrice != null) {
      final band = _priceBands.firstWhere((b) => b['id'] == _pickedPrice);
      r = r.where((p) => p.price >= (band['min'] as int) && p.price <= (band['max'] as int)).toList();
    }
    if (_minRating > 0) r = r.where((p) => p.rating >= _minRating).toList();
    if (_sort == 'Giá tăng dần') r.sort((a, b) => a.price - b.price);
    else if (_sort == 'Giá giảm dần') r.sort((a, b) => b.price - a.price);
    else if (_sort == 'Đánh giá cao') r.sort((a, b) => b.rating.compareTo(a.rating));
    else if (_sort == 'Mới nhất') r = r.reversed.toList();
    return r;
  }

  int get _activeFilters => _pickedBrands.length + (_pickedPrice != null ? 1 : 0) + (_minRating > 0 ? 1 : 0);

  @override
  Widget build(BuildContext context) {
    final list = _filtered;
    final catName = widget.initialCategory != null
        ? categories.cast<Category?>().firstWhere((c) => c!.id == widget.initialCategory, orElse: () => null)?.name
        : null;

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
                                onChanged: (_) => setState(() {}),
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
              // Chip filters
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  itemCount: _filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final f = _filters[i];
                    final active = _chip == f;
                    return GestureDetector(
                      onTap: () => setState(() => _chip = f),
                      child: Container(
                        height: 32,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: active ? AppColors.primary : AppColors.background,
                          border: Border.all(color: active ? AppColors.primary : AppColors.border),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: active ? [const BoxShadow(color: Color(0x40376FF0), blurRadius: 8, offset: Offset(0, 3))] : null,
                        ),
                        child: Center(child: Text(f, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: active ? Colors.white : AppColors.secondary))),
                      ),
                    );
                  },
                ),
              ),
              // Count + sort row
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                child: Row(
                  children: [
                    Text('${list.length} sản phẩm', style: const TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
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
              list.isEmpty
                  ? const EmptyState(
                      icon: Icons.search_off,
                      title: 'Không tìm thấy sản phẩm',
                      body: 'Thử tìm với từ khoá khác hoặc bỏ bớt bộ lọc.',
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.52,
                      ),
                      itemCount: list.length,
                      itemBuilder: (context, i) => ProductCard(
                        product: list[i],
                        onTap: () => Navigator.push(context, MaterialPageRoute(
                          builder: (_) => ProductDetailScreen(productId: list[i].id),
                        )),
                      ),
                    ),

              // Sort dropdown
              if (_showSort)
                Positioned(
                  top: 0, right: 12,
                  child: GestureDetector(
                    onTap: () => setState(() => _showSort = false),
                    child: Container(
                      color: Colors.transparent,
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                    ),
                  ),
                ),
              if (_showSort)
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
                        onTap: () => setState(() { _sort = s; _showSort = false; }),
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
          ),
        ),

        // Filter bottom sheet
        if (_showFilter)
          _FilterSheet(
            pickedBrands: _pickedBrands,
            pickedPrice: _pickedPrice,
            minRating: _minRating,
            priceBands: _priceBands,
            resultCount: list.length,
            onApply: (brands, price, rating) {
              setState(() {
                _pickedBrands = brands;
                _pickedPrice = price;
                _minRating = rating;
                _showFilter = false;
              });
            },
            onClose: () => setState(() => _showFilter = false),
          ),
      ],
      ),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  final List<String> pickedBrands;
  final String? pickedPrice;
  final double minRating;
  final List<Map<String, dynamic>> priceBands;
  final int resultCount;
  final Function(List<String>, String?, double) onApply;
  final VoidCallback onClose;

  const _FilterSheet({
    required this.pickedBrands,
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
  late List<String> _brands;
  late String? _price;
  late double _rating;

  @override
  void initState() {
    super.initState();
    _brands = List.from(widget.pickedBrands);
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
                            const SizedBox(height: 16),
                            const Text('Thương hiệu', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.secondary)),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: brands.map((b) {
                                final active = _brands.contains(b.name);
                                return GestureDetector(
                                  onTap: () => setState(() {
                                    if (active) _brands.remove(b.name);
                                    else _brands.add(b.name);
                                  }),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: active ? AppColors.primary : AppColors.border),
                                      color: active ? AppColors.primary.withOpacity(0.05) : Colors.transparent,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(b.name, style: TextStyle(fontSize: 12, color: active ? AppColors.primary : AppColors.secondary)),
                                  ),
                                );
                              }).toList(),
                            ),
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
                              onPressed: () => setState(() { _brands = []; _price = null; _rating = 0; }),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: AppButton(
                              label: 'Xem ${widget.resultCount} sản phẩm',
                              variant: AppButtonVariant.gradient,
                              onPressed: () => widget.onApply(_brands, _price, _rating),
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
