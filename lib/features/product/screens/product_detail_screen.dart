import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../../../models/models.dart';
import '../../../models/api_models.dart';
import '../../../services/api_service.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/auth_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/product_images.dart';
import '../widgets/product_price_card.dart';
import '../widgets/product_shipping_card.dart';
import '../widgets/product_quantity_selector.dart';
import '../widgets/product_tab_container.dart';
import '../../chat/screens/chat_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  // ── UI state ───────────────────────────────────────────────────────────────
  int _qty = 1;

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
      if (id == null) throw const ApiException(statusCode: 0, message: AppStrings.errInvalidProductId);

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
          content: const Text(AppStrings.loginRequiredForCart),
          action: SnackBarAction(
            label: AppStrings.loginButton,
            onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
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
          content: Text(AppStrings.addToCartSuccess),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 2),
        ),
      );
      if (goToCart) {
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.mainCart, (r) => r.isFirst);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppStrings.addToCartFailed}${e.toString().replaceAll("ApiException(", "").replaceAll(")", "")}'),
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
          const SizedBox(height: AppSizes.p12),
          // Text shimmer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _AnimatedShimmer(child: Container(height: 28, width: 160, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(AppSizes.r6)))),
                const SizedBox(height: AppSizes.p10),
                _AnimatedShimmer(child: Container(height: 16, width: double.infinity, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(AppSizes.r6)))),
                const SizedBox(height: AppSizes.p6),
                _AnimatedShimmer(child: Container(height: 16, width: 200, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(AppSizes.r6)))),
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
          padding: const EdgeInsets.all(AppSizes.p32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72, height: 72,
                decoration: const BoxDecoration(color: AppColors.wifiErrBg, shape: BoxShape.circle),
                child: const Icon(Icons.error_outline, size: 36, color: AppColors.destructive),
              ),
              const SizedBox(height: AppSizes.p16),
              const Text(AppStrings.errLoadProduct, style: AppTextStyles.h3),
              const SizedBox(height: AppSizes.p8),
              Text(_errorMessage ?? '', style: const TextStyle(fontSize: 13, color: AppColors.mutedForeground), textAlign: TextAlign.center),
              const SizedBox(height: AppSizes.p24),
              GestureDetector(
                onTap: _loadProduct,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.p24, vertical: AppSizes.p12),
                  decoration: BoxDecoration(gradient: AppColors.heroGradient, borderRadius: BorderRadius.circular(AppSizes.r12)),
                  child: const Text(AppStrings.retry, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
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
      appBar: AppBar(title: const Text(AppStrings.productsTitle)),
      body: const Center(child: Text(AppStrings.errProductNotFound, style: TextStyle(color: AppColors.mutedForeground))),
    );
  }

  // ── Main product content ───────────────────────────────────────────────────
  Widget _buildContent(Product p) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Image gallery
                  ProductImages(images: p.images),

                  // Price + name card
                  ProductPriceCard(product: p),

                  // Shipping info
                  const ProductShippingCard(),

                  // Quantity
                  ProductQuantitySelector(
                    quantity: _qty,
                    stock: p.stock,
                    onChanged: (val) => setState(() => _qty = val),
                  ),

                  // Tabs
                  ProductTabContainer(
                    product: p,
                    attributes: _attributes,
                    ratingStats: _ratingStats,
                    reviews: _reviewsPage?.content ?? [],
                  ),

                  // Related products
                  if (_related.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.fromLTRB(AppSizes.p16, AppSizes.p16, AppSizes.p16, AppSizes.p8),
                      child: Align(alignment: Alignment.centerLeft, child: Text(AppStrings.relatedProducts, style: AppTextStyles.h3)),
                    ),
                    SizedBox(
                      height: 230,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
                        itemCount: _related.length,
                        separatorBuilder: (_, __) => const SizedBox(width: AppSizes.p10),
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
                  const SizedBox(height: AppSizes.p16),
                ],
              ),
            ),
          ),

          // Bottom action bar
          Container(
            padding: EdgeInsets.fromLTRB(AppSizes.p12, AppSizes.p10, AppSizes.p12, AppSizes.p10 + MediaQuery.of(context).padding.bottom),
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
                    decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(AppSizes.r12)),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 18, color: AppColors.primary),
                        Text(AppStrings.chat, style: TextStyle(fontSize: 9, color: AppColors.secondary)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.p8),
                Expanded(
                  child: AppButton(
                    label: AppStrings.addToCart,
                    variant: AppButtonVariant.secondary,
                    disabled: p.stock == 0,
                    onPressed: () => _addToCart(p, goToCart: false),
                  ),
                ),
                const SizedBox(width: AppSizes.p8),
                Expanded(
                  child: AppButton(
                    label: AppStrings.buyNow,
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

class _AnimatedShimmer extends StatelessWidget {
  final Widget child;
  const _AnimatedShimmer({required this.child});

  @override
  Widget build(BuildContext context) => child;
}
