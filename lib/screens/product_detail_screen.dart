import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_html/flutter_html.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../models/api_models.dart';
import '../services/api_service.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/format_utils.dart';
import '../widgets/product_card.dart';
import '../widgets/app_button.dart';
import 'chat_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  // ── UI state ───────────────────────────────────────────────────────────────
  int _imgIndex = 0;
  int _qty = 1;
  String _tab = 'specs';

  // ── Data state ─────────────────────────────────────────────────────────────
  Product? _product;
  List<Product> _related = [];
  List<ApiProductAttributeResponse> _attributes = [];
  ApiPage<ApiReviewResponse>? _reviewsPage;
  ApiRatingStatsResponse? _ratingStats;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  // ── Load product from API ──────────────────────────────────────────────────
  Future<void> _loadProduct() async {
    if (!mounted) return;
    setState(() { _isLoading = true; _errorMessage = null; });

    try {
      final id = int.tryParse(widget.productId);
      if (id == null) throw const ApiException(statusCode: 0, message: 'ID sản phẩm không hợp lệ');

      final api = ApiService();
      final apiProduct = await api.getProductById(id);
      final product = Product.fromApi(apiProduct);

      // Lấy sản phẩm liên quan theo cùng danh mục
      List<Product> related = [];
      if (apiProduct.categoryId != null) {
        final relatedPage = await api.getProducts(
          categoryId: apiProduct.categoryId,
          size: 8,
        );
        related = relatedPage.content
            .where((p) => p.productId != id)
            .take(6)
            .map((p) => Product.fromApi(p))
            .toList();
      }

      // Lấy attributes, reviews
      final attrs = await api.getProductAttributes(id);
      final stats = await api.getProductRatingStats(id);
      final revs = await api.getProductReviews(id, size: 10);

      if (!mounted) return;
      setState(() {
        _product = product;
        _related = related;
        _attributes = attrs;
        _ratingStats = stats;
        _reviewsPage = revs;
        _isLoading = false;
        _imgIndex = 0;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e is ApiException ? e.message : e.toString();
        _isLoading = false;
      });
    }
  }

  // ── Add to cart qua API ────────────────────────────────────────────────────
  Future<void> _addToCart(Product p, {required bool goToCart}) async {
    final auth = context.read<AuthProvider>();
    if (!auth.isAuthenticated || auth.userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Vui lòng đăng nhập để thêm vào giỏ hàng'),
          action: SnackBarAction(
            label: 'Đăng nhập',
            onPressed: () => Navigator.pushNamed(context, '/login'),
          ),
        ),
      );
      return;
    }

    try {
      await context.read<CartProvider>().addItem(
        auth.userId!,
        int.parse(p.id),
        _qty,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã thêm vào giỏ hàng ✓'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 2),
        ),
      );
      if (goToCart) {
        Navigator.pushNamedAndRemoveUntil(context, '/main-cart', (r) => r.isFirst);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể thêm vào giỏ: ${e.toString().replaceAll("ApiException(", "").replaceAll(")", "")}'),
          backgroundColor: AppColors.destructive,
        ),
      );
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_isLoading) return _buildLoading();
    if (_errorMessage != null) return _buildError();
    if (_product == null) return _buildNotFound();
    return _buildContent(_product!);
  }

  // ── Loading skeleton ───────────────────────────────────────────────────────
  Widget _buildLoading() {
    return Scaffold(
      body: Column(
        children: [
          // Image area shimmer
          _AnimatedShimmer(
            child: Container(
              color: Colors.grey[300],
              height: MediaQuery.of(context).size.width,
              width: double.infinity,
            ),
          ),
          const SizedBox(height: 12),
          // Text shimmer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _AnimatedShimmer(child: Container(height: 28, width: 160, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(6)))),
                const SizedBox(height: 10),
                _AnimatedShimmer(child: Container(height: 16, width: double.infinity, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(6)))),
                const SizedBox(height: 6),
                _AnimatedShimmer(child: Container(height: 16, width: 200, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(6)))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: AppColors.secondary, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(color: AppColors.destructive.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.error_outline, size: 36, color: AppColors.destructive),
              ),
              const SizedBox(height: 16),
              const Text('Không thể tải sản phẩm', style: AppTextStyles.h3),
              const SizedBox(height: 8),
              Text(_errorMessage ?? '', style: const TextStyle(fontSize: 13, color: AppColors.mutedForeground), textAlign: TextAlign.center),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: _loadProduct,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(gradient: AppColors.heroGradient, borderRadius: BorderRadius.circular(12)),
                  child: const Text('Thử lại', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotFound() {
    return Scaffold(
      appBar: AppBar(title: const Text('Sản phẩm')),
      body: const Center(child: Text('Không tìm thấy sản phẩm', style: TextStyle(color: AppColors.mutedForeground))),
    );
  }

  // ── Main product content ───────────────────────────────────────────────────
  Widget _buildContent(Product p) {
    final discount = p.oldPrice > p.price
        ? ((p.oldPrice - p.price) / p.oldPrice * 100).round()
        : 0;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Image gallery
                  Stack(
                    children: [
                      AspectRatio(
                        aspectRatio: 1,
                        child: GestureDetector(
                          onHorizontalDragEnd: (d) {
                            if (d.primaryVelocity == null) return;
                            if (d.primaryVelocity! < -200 && _imgIndex < p.images.length - 1) {
                              setState(() => _imgIndex++);
                            } else if (d.primaryVelocity! > 200 && _imgIndex > 0) {
                              setState(() => _imgIndex--);
                            }
                          },
                          child: Image.network(
                            p.images[_imgIndex],
                            fit: BoxFit.cover,
                            loadingBuilder: (_, child, progress) {
                              if (progress == null) return child;
                              return Container(color: AppColors.muted, child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)));
                            },
                            errorBuilder: (_, __, ___) => Container(color: AppColors.muted, child: const Icon(Icons.image_not_supported, size: 64, color: AppColors.mutedForeground)),
                          ),
                        ),
                      ),
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 8,
                        left: 12,
                        child: _CircleBtn(icon: Icons.chevron_left, onTap: () => Navigator.pop(context)),
                      ),
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 8,
                        right: 12,
                        child: Row(
                          children: [
                            _CircleBtn(icon: Icons.favorite_border, onTap: () {}),
                            const SizedBox(width: 8),
                            _CircleBtn(icon: Icons.share_outlined, onTap: () {}),
                          ],
                        ),
                      ),
                      if (p.images.length > 1)
                        Positioned(
                          bottom: 12,
                          left: 0, right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(p.images.length, (i) => AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              width: i == _imgIndex ? 20 : 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: i == _imgIndex ? AppColors.primary : Colors.white70,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            )),
                          ),
                        ),
                    ],
                  ),

                  // Thumbnail strip
                  if (p.images.length > 1)
                    SizedBox(
                      height: 72,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: p.images.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, i) => GestureDetector(
                          onTap: () => setState(() => _imgIndex = i),
                          child: Container(
                            width: 56, height: 56,
                            decoration: BoxDecoration(
                              border: Border.all(color: i == _imgIndex ? AppColors.primary : Colors.transparent, width: 2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(p.images[i], fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(color: AppColors.muted)),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Price + name card
                  _Card(
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(formatVND(p.price), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.primary)),
                            if (discount > 0) ...[
                              const SizedBox(width: 8),
                              Text(formatVND(p.oldPrice), style: AppTextStyles.priceOld.copyWith(fontSize: 13)),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(4)),
                                child: Text('-$discount%', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(p.name, style: AppTextStyles.h2),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.star, size: 14, color: AppColors.accent),
                            const SizedBox(width: 4),
                            Text(p.rating.toStringAsFixed(1), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.secondary)),
                            Text(' (${p.reviews})', style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                            const Text(' · ', style: TextStyle(color: AppColors.mutedForeground)),
                            Text('Đã bán ${formatSold(p.sold)}', style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                            const Text(' · ', style: TextStyle(color: AppColors.mutedForeground)),
                            Text(p.stock > 0 ? 'Còn hàng' : 'Hết hàng',
                                style: TextStyle(fontSize: 12, color: p.stock > 0 ? AppColors.success : AppColors.destructive, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Shipping info
                  _Card(
                    margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Column(
                      children: [
                        const _InfoRow(icon: Icons.local_shipping_outlined, text: 'Giao 2h tại nội thành · Miễn phí từ 500.000 ₫'),
                        const Divider(height: 12, color: AppColors.border),
                        const _InfoRow(icon: Icons.verified_user_outlined, text: 'Bảo hành chính hãng 12 tháng'),
                        const Divider(height: 12, color: AppColors.border),
                        const _InfoRow(icon: Icons.replay_outlined, text: 'Đổi trả trong 7 ngày'),
                      ],
                    ),
                  ),

                  // Quantity
                  _Card(
                    margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Row(
                      children: [
                        const Text('Số lượng', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.secondary)),
                        const Spacer(),
                        _QtyBtn(icon: Icons.remove, onTap: _qty > 1 ? () => setState(() => _qty--) : null),
                        const SizedBox(width: 12),
                        SizedBox(width: 32, child: Text('$_qty', textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.secondary))),
                        const SizedBox(width: 12),
                        _QtyBtn(icon: Icons.add, onTap: _qty < p.stock ? () => setState(() => _qty++) : null),
                      ],
                    ),
                  ),

                  // Tabs
                  _Card(
                    margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            _TabBtn(label: 'Mô tả', active: _tab == 'desc', onTap: () => setState(() => _tab = 'desc')),
                            _TabBtn(label: 'Thông số', active: _tab == 'specs', onTap: () => setState(() => _tab = 'specs')),
                            _TabBtn(label: 'Đánh giá (${p.reviews})', active: _tab == 'rev', onTap: () => setState(() => _tab = 'rev')),
                          ],
                        ),
                        const Divider(height: 1, color: AppColors.border),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: _TabContent(
                            tab: _tab,
                            product: p,
                            attributes: _attributes,
                            ratingStats: _ratingStats,
                            reviews: _reviewsPage?.content ?? [],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Related products
                  if (_related.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Align(alignment: Alignment.centerLeft, child: Text('Sản phẩm liên quan', style: AppTextStyles.h3)),
                    ),
                    SizedBox(
                      height: 230,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _related.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (context, i) => ProductCard(
                          product: _related[i],
                          variant: ProductCardVariant.horizontal,
                          onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(
                            builder: (_) => ProductDetailScreen(productId: _related[i].id),
                          )),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Bottom action bar
          Container(
            padding: EdgeInsets.fromLTRB(12, 10, 12, 10 + MediaQuery.of(context).padding.bottom),
            decoration: const BoxDecoration(
              color: AppColors.background,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen())),
                  child: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(12)),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 18, color: AppColors.primary),
                        Text('Chat', style: TextStyle(fontSize: 9, color: AppColors.secondary)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AppButton(
                    label: 'Vào giỏ',
                    variant: AppButtonVariant.secondary,
                    disabled: p.stock == 0,
                    onPressed: () => _addToCart(p, goToCart: false),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AppButton(
                    label: 'Mua ngay',
                    variant: AppButtonVariant.gradient,
                    disabled: p.stock == 0,
                    onPressed: () => _addToCart(p, goToCart: true),
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

// ── Helper Widgets ────────────────────────────────────────────────────────────

class _AnimatedShimmer extends StatelessWidget {
  final Widget child;
  const _AnimatedShimmer({required this.child});

  @override
  Widget build(BuildContext context) => child; // Simple placeholder
}

class _Card extends StatelessWidget {
  final Widget child;
  final EdgeInsets margin;
  const _Card({required this.child, required this.margin});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.card,
      ),
      child: child,
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: AppShadows.card,
        ),
        child: Icon(icon, size: 20, color: AppColors.secondary),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 12, color: AppColors.secondary))),
      ],
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _QtyBtn({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8),
          color: onTap == null ? AppColors.muted : Colors.transparent,
        ),
        child: Icon(icon, size: 16, color: onTap == null ? AppColors.mutedForeground : AppColors.secondary),
      ),
    );
  }
}

class _TabBtn extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _TabBtn({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: active ? AppColors.primary : Colors.transparent, width: 2)),
          ),
          child: Center(child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: active ? AppColors.primary : AppColors.mutedForeground))),
        ),
      ),
    );
  }
}

class _TabContent extends StatelessWidget {
  final String tab;
  final Product product;
  final List<ApiProductAttributeResponse> attributes;
  final ApiRatingStatsResponse? ratingStats;
  final List<ApiReviewResponse> reviews;

  const _TabContent({
    required this.tab,
    required this.product,
    required this.attributes,
    required this.ratingStats,
    required this.reviews,
  });

  @override
  Widget build(BuildContext context) {
    if (tab == 'desc') {
      final desc = product.description;
      return Html(
        data: desc,
        style: {
          "body": Style(
            fontSize: FontSize(14.0),
            color: AppColors.secondary,
            lineHeight: LineHeight(1.6),
            padding: HtmlPaddings.zero,
            margin: Margins.zero,
          ),
        },
      );
    }
    if (tab == 'specs') {
      if (attributes.isEmpty) {
        return const Text(
          'Thông số kỹ thuật chi tiết sẽ được cập nhật sớm.',
          style: TextStyle(fontSize: 13, color: AppColors.mutedForeground),
        );
      }
      return Column(
        children: attributes.map((e) => Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
          child: Row(
            children: [
              SizedBox(width: 110, child: Text(e.attributeName, style: const TextStyle(fontSize: 13, color: AppColors.mutedForeground))),
              const SizedBox(width: 12),
              Expanded(child: Text(e.attributeValue, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.secondary))),
            ],
          ),
        )).toList(),
      );
    }
    // Reviews tab
    final avgRating = ratingStats?.averageRating ?? product.rating;
    final totalRevs = ratingStats?.totalReviews ?? product.reviews;
    final rc = ratingStats?.ratingCount ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Column(
              children: [
                Text(avgRating.toStringAsFixed(1), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.secondary)),
                Row(children: List.generate(5, (i) => Icon(Icons.star, size: 12, color: i < avgRating.round() ? AppColors.accent : AppColors.border))),
                const SizedBox(height: 4),
                Text('$totalRevs đánh giá', style: const TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                children: [5, 4, 3, 2, 1].map((s) {
                  final count = rc[s.toString()] ?? 0;
                  final pct = totalRevs > 0 ? count / totalRevs : 0.0;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Text('$s', style: const TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: pct,
                              backgroundColor: AppColors.muted,
                              valueColor: const AlwaysStoppedAnimation(AppColors.accent),
                              minHeight: 6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (reviews.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 16),
            child: Text('Chưa có đánh giá nào cho sản phẩm này.', style: TextStyle(fontSize: 13, color: AppColors.mutedForeground)),
          )
        else
          ...reviews.map((r) => Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(color: AppColors.border),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Text(r.userName.isNotEmpty ? r.userName[0].toUpperCase() : 'U', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 12)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(child: Text(r.userName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.secondary), maxLines: 1, overflow: TextOverflow.ellipsis)),
                              if (r.reviewDate != null)
                                Text(r.reviewDate!.split('T')[0], style: const TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                            ],
                          ),
                          Row(children: List.generate(5, (i) => Icon(Icons.star, size: 11, color: i < r.rating ? AppColors.accent : AppColors.border))),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(r.comment, style: const TextStyle(fontSize: 12, color: AppColors.secondary)),
                if (r.reply != null && r.reply!.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AppColors.muted, borderRadius: BorderRadius.circular(6)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.support_agent, size: 14, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Expanded(child: Text(r.reply!, style: const TextStyle(fontSize: 12, color: AppColors.secondary))),
                      ],
                    ),
                  ),
              ],
            ),
          )),
      ],
    );
  }
}
