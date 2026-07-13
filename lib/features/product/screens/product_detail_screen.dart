import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../../../models/models.dart';
import '../../../providers/product_provider.dart';
import '../../../core/widgets/shimmer_box.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final id = int.tryParse(widget.productId);
      if (id != null) {
        context.read<ProductProvider>().loadProductDetail(id);
      }
    });
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
    final provider = context.watch<ProductProvider>();
    
    if (provider.isLoadingDetail) return _buildLoading();
    if (provider.detailError != null) return _buildError(provider);
    if (provider.currentProduct == null) return _buildNotFound();
    return _buildContent(provider);
  }

  // ── Loading skeleton ───────────────────────────────────────────────────────
  Widget _buildLoading() {
    return Scaffold(
      body: Column(
        children: [
          // Image area shimmer
          ShimmerBox(
            height: MediaQuery.of(context).size.width,
            width: double.infinity,
            radius: 0,
          ),
          const SizedBox(height: AppSizes.p12),
          // Text shimmer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerBox(height: 28, width: 160, radius: AppSizes.r6),
                const SizedBox(height: AppSizes.p10),
                const ShimmerBox(height: 16, width: double.infinity, radius: AppSizes.r6),
                const SizedBox(height: AppSizes.p6),
                const ShimmerBox(height: 16, width: 200, radius: AppSizes.r6),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(ProductProvider provider) {
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
              Text(provider.detailError ?? '', style: const TextStyle(fontSize: 13, color: AppColors.mutedForeground), textAlign: TextAlign.center),
              const SizedBox(height: AppSizes.p24),
              GestureDetector(
                onTap: () {
                  final id = int.tryParse(widget.productId);
                  if (id != null) provider.loadProductDetail(id);
                },
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
  Widget _buildContent(ProductProvider provider) {
    final p = provider.currentProduct!;
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
                    attributes: provider.currentAttributes,
                    ratingStats: provider.currentRatingStats,
                    reviews: provider.currentReviewsPage?.content ?? [],
                  ),

                  // Related products
                  if (provider.relatedProducts.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.fromLTRB(AppSizes.p16, AppSizes.p16, AppSizes.p16, AppSizes.p8),
                      child: Align(alignment: Alignment.centerLeft, child: Text(AppStrings.relatedProducts, style: AppTextStyles.h3)),
                    ),
                    SizedBox(
                      height: 230,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
                        itemCount: provider.relatedProducts.length,
                        separatorBuilder: (_, __) => const SizedBox(width: AppSizes.p10),
                        itemBuilder: (context, i) => ProductCard(
                          product: provider.relatedProducts[i],
                          variant: ProductCardVariant.horizontal,
                          onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(
                            builder: (_) => ProductDetailScreen(productId: provider.relatedProducts[i].id),
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
                // Admin không chat với vai trò khách → ẩn nút chat cho ADMIN.
                if (context.watch<AuthProvider>().role != 'ADMIN') ...[
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(attachProduct: p))),
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
                ],
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
