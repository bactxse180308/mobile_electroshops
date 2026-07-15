import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/widgets/error_retry_view.dart';
import '../../../models/models.dart';
import '../widgets/product_detail_shimmer.dart';
import '../../../models/api_models.dart';
import '../../../services/api_service.dart';
import '../../../services/product_service.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/auth_provider.dart';
import '../widgets/product_images.dart';
import '../widgets/product_price_card.dart';
import '../widgets/product_shipping_card.dart';
import '../widgets/product_quantity_selector.dart';
import '../widgets/product_tab_container.dart';
import '../widgets/related_products_section.dart';
import '../widgets/product_detail_bottom_bar.dart';

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

      final api = ProductService();
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
    if (_isLoading) return const ProductDetailShimmer();
    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.chevron_left, color: AppColors.secondary, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: ErrorRetryView(
          errorMessage: _errorMessage,
          title: AppStrings.errLoadProduct,
          onRetry: _loadProduct,
        ),
      );
    }
    if (_product == null) return _buildNotFound();
    return _buildContent(_product!);
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
      body: SingleChildScrollView(
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
            RelatedProductsSection(
              related: _related,
              onProductTap: (prod) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductDetailScreen(productId: prod.id),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSizes.p16),
          ],
        ),
      ),
      bottomNavigationBar: ProductDetailBottomBar(
        product: p,
        onAddToCart: () => _addToCart(p, goToCart: false),
        onBuyNow: () => _addToCart(p, goToCart: true),
      ),
    );
  }
}
