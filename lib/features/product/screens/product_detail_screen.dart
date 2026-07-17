import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/widgets/error_retry_view.dart';
import '../../../models/models.dart';
import '../widgets/product_detail_shimmer.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/product_detail_provider.dart';
import '../widgets/product_images.dart';
import '../widgets/product_price_card.dart';
import '../widgets/product_shipping_card.dart';
import '../widgets/product_quantity_selector.dart';
import '../widgets/product_tab_container.dart';
import '../widgets/related_products_section.dart';
import '../widgets/product_detail_bottom_bar.dart';

class ProductDetailScreen extends StatelessWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProductDetailProvider()..loadProduct(productId),
      child: const _ProductDetailView(),
    );
  }
}

class _ProductDetailView extends StatefulWidget {
  const _ProductDetailView();

  @override
  State<_ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<_ProductDetailView> {
  int _qty = 1;

  Future<void> _addToCart(BuildContext context, Product p, {required bool goToCart}) async {
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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductDetailProvider>();

    if (provider.isLoading) return const ProductDetailShimmer();
    if (provider.errorMessage != null) {
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
          errorMessage: provider.errorMessage,
          title: AppStrings.errLoadProduct,
          onRetry: () => provider.loadProduct(provider.product?.id ?? ""),
        ),
      );
    }

    final p = provider.product;
    if (p == null) return _buildNotFound();

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            ProductImages(productId: int.parse(p.id), images: p.images),
            ProductPriceCard(product: p),
            const ProductShippingCard(),
            ProductQuantitySelector(
              quantity: _qty,
              stock: p.stock,
              onChanged: (val) => setState(() => _qty = val),
            ),
            ProductTabContainer(
              product: p,
              attributes: provider.attributes,
              ratingStats: provider.ratingStats,
              reviews: provider.reviews,
            ),
            RelatedProductsSection(
              related: provider.related,
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
        onAddToCart: () => _addToCart(context, p, goToCart: false),
        onBuyNow: () => _addToCart(context, p, goToCart: true),
      ),
    );
  }

  Widget _buildNotFound() {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.productsTitle)),
      body: const Center(child: Text(AppStrings.errProductNotFound, style: TextStyle(color: AppColors.mutedForeground))),
    );
  }
}
