import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/widgets/error_retry_view.dart';
import '../../../models/models.dart';
import '../../../services/api_service.dart';
import '../widgets/home_shimmer.dart';
import '../../../services/product_service.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/chat_provider.dart';
import '../../../providers/admin_chat_provider.dart';
import '../../product/widgets/product_card.dart';
import '../../product/screens/product_detail_screen.dart';
import '../../chat/screens/chat_screen.dart';
import '../../chat/screens/admin_conversations_screen.dart';
import '../widgets/home_header.dart';
import '../widgets/home_banner_carousel.dart';
import '../widgets/home_section_header.dart';
import '../widgets/home_categories_list.dart';
import '../widgets/home_flash_sale.dart';
import '../widgets/home_brands_list.dart';

class HomeScreen extends StatefulWidget {
  final ValueChanged<int>? onNavigate;
  final void Function({int? categoryId, String? categoryName, int? brandId, String? brandQuery})? onNavigateToCategories;

  const HomeScreen({
    super.key,
    this.onNavigate,
    this.onNavigateToCategories,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ── API Data ────────────────────────────
  List<Category> _categories = [];
  List<Brand> _brands = [];
  List<Product> _flashSale = [];     // sản phẩm có discount
  List<Product> _bestSellers = [];   // sắp xếp theo soldCount
  List<Product> _newArrivals = [];   // sản phẩm mới nhất
  List<Product> _recentlyViewed = []; // giữ local (không có API)
  List<String> _bannerImages = AppAssets.homeBanners; // default value

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadHomeData();
  }

  // ── Data Loading ──────────────────────────────────────────────────────────
  Future<void> _loadHomeData() async {
    if (!mounted) return;
    setState(() { _isLoading = true; _errorMessage = null; });

    try {
      final api = ProductService();

      // Load categories, brands, và banners trước
      final cats    = await api.getCategories();
      final brnds   = await api.getBrands();
      final banners = await api.getHomeBannerUrls();

      if (!mounted) return;
      setState(() {
        _categories   = cats.map((e) => Category.fromApi(e)).toList();
        _brands       = brnds.map((e) => Brand.fromApi(e)).toList();
        _bannerImages = banners.isNotEmpty ? banners : AppAssets.homeBanners;
      });

      // Load sản phẩm — dùng sort client-side để tránh lỗi
      List<Product> flash = [];
      List<Product> best  = [];
      List<Product> newArr = [];

      try {
        final p = await api.getProducts(size: 20);
        final all = p.content.map((e) => Product.fromApi(e)).toList();
        flash  = List.from(all)..sort((a, b) => (b.oldPrice - b.price).compareTo(a.oldPrice - a.price));
        best   = List.from(all)..sort((a, b) => b.sold.compareTo(a.sold));
        newArr = List.from(all);
      } catch (e) {
        debugPrint('Load products error: $e');
      }

      if (!mounted) return;
      setState(() {
        _flashSale      = flash.take(6).toList();
        _bestSellers    = best.take(4).toList();
        _newArrivals    = newArr.take(4).toList();
        _recentlyViewed = best.skip(4).take(4).toList();
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

  void _goToProduct(BuildContext context, String id) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(productId: id)));
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final cartCount = context.watch<CartProvider>().totalCount;
    final isAdmin = context.watch<AuthProvider>().role == 'ADMIN';
    final chatCount = isAdmin
        ? context.watch<AdminChatProvider>().totalUnread
        : context.watch<ChatProvider>().unreadCount;
    return Column(
      children: [
        HomeHeader(
          cartCount: cartCount,
          chatCount: chatCount,
          onNotificationTap: () => widget.onNavigate?.call(3),
          onCartTap: () => widget.onNavigate?.call(2),
          onChatTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => isAdmin
                  ? const AdminConversationsScreen()
                  : const ChatScreen(),
            ),
          ),
          onSearchTap: () => widget.onNavigate?.call(1),
        ),
        Expanded(
          child: _isLoading
              ? const HomeShimmer()
              : _errorMessage != null
                  ? ErrorRetryView(
                      errorMessage: _errorMessage,
                      onRetry: _loadHomeData,
                    )
                  : _buildContent(),
        ),
      ],
    );
  }

  // ── Main Content ──────────────────────────────────────────────────────────
  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: _loadHomeData,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Carousel
            HomeBannerCarousel(bannerImages: _bannerImages),

            // Categories
            HomeCategoriesList(
              categories: _categories,
              onCategoryTap: (id, name) {
                widget.onNavigateToCategories?.call(
                  categoryId: id,
                  categoryName: name,
                );
              },
            ),

            // Flash Sale
            HomeFlashSale(
              products: _flashSale,
              onProductTap: (id) => _goToProduct(context, id),
              onViewAllTap: () => widget.onNavigate?.call(1),
            ),

            // Brands
            HomeBrandsList(
              brands: _brands,
              onBrandTap: (id, name) {
                widget.onNavigateToCategories?.call(
                  brandId: id,
                  brandQuery: name,
                );
              },
            ),

            // Best Sellers
            if (_bestSellers.isNotEmpty) ...[
              HomeSectionHeader(
                title: AppStrings.sectionBestSellers,
                onViewAllTap: () => widget.onNavigate?.call(1),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppSizes.p12,
                  mainAxisSpacing: AppSizes.p12,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 0.52,
                  children: _bestSellers.map((p) => ProductCard(
                    product: p,
                    onTap: () => _goToProduct(context, p.id),
                  )).toList(),
                ),
              ),
            ],

            // Recently Viewed
            if (_recentlyViewed.isNotEmpty) ...[
              const HomeSectionHeader(title: AppStrings.sectionRecentlyViewed),
              SizedBox(
                height: 230,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
                  itemCount: _recentlyViewed.length,
                  separatorBuilder: (_, __) => const SizedBox(width: AppSizes.p10),
                  itemBuilder: (context, i) => ProductCard(
                    product: _recentlyViewed[i],
                    variant: ProductCardVariant.horizontal,
                    onTap: () => _goToProduct(context, _recentlyViewed[i].id),
                  ),
                ),
              ),
            ],

            // New Arrivals
            if (_newArrivals.isNotEmpty) ...[
              HomeSectionHeader(
                title: AppStrings.sectionNewArrivals,
                onViewAllTap: () => widget.onNavigate?.call(1),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSizes.p16, 0, AppSizes.p16, AppSizes.p20),
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppSizes.p12,
                  mainAxisSpacing: AppSizes.p12,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 0.52,
                  children: _newArrivals.map((p) => ProductCard(
                    product: p,
                    onTap: () => _goToProduct(context, p.id),
                  )).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
