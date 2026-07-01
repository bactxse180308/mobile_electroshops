import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/widgets/shimmer_box.dart';
import '../../../models/models.dart';
import '../../../services/api_service.dart';
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
      final api = ApiService();

      // Load categories và brands trước
      final cats  = await api.getCategories();
      final brnds = await api.getBrands();

      if (!mounted) return;
      setState(() {
        _categories = cats.map((e) => Category.fromApi(e)).toList();
        _brands     = brnds.map((e) => Brand.fromApi(e)).toList();
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
              ? _buildShimmer()
              : _errorMessage != null
                  ? _buildError()
                  : _buildContent(),
        ),
      ],
    );
  }

  // ── Loading Shimmer ───────────────────────────────────────────────────────
  Widget _buildShimmer() {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner shimmer
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSizes.p16, AppSizes.p16, AppSizes.p16, 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.r16),
              child: const ShimmerBox(height: 160, width: double.infinity),
            ),
          ),
          const SizedBox(height: AppSizes.p20),
          // Category shimmer
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSizes.p16),
            child: ShimmerBox(height: 14, width: 80),
          ),
          const SizedBox(height: AppSizes.p12),
          SizedBox(
            height: 90,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
              itemCount: 6,
              separatorBuilder: (_, __) => const SizedBox(width: AppSizes.p12),
              itemBuilder: (_, __) => Column(
                children: const [
                  ShimmerBox(height: 56, width: 56, radius: AppSizes.r16),
                  SizedBox(height: AppSizes.p6),
                  ShimmerBox(height: 10, width: 48),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSizes.p20),
          // Product grid shimmer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: AppSizes.p12,
              mainAxisSpacing: AppSizes.p12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 0.52,
              children: List.generate(4, (_) => const ShimmerBox(height: double.infinity, width: double.infinity, radius: AppSizes.r12)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Error State ───────────────────────────────────────────────────────────
  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.p32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72, height: 72,
              decoration: const BoxDecoration(
                color: AppColors.wifiErrBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.wifi_off_rounded, size: 36, color: AppColors.destructive),
            ),
            const SizedBox(height: AppSizes.p16),
            const Text(AppStrings.errCannotLoadData, style: AppTextStyles.h3),
            const SizedBox(height: AppSizes.p8),
            Text(
              _errorMessage ?? AppStrings.error,
              style: const TextStyle(fontSize: 13, color: AppColors.mutedForeground),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.p24),
            GestureDetector(
              onTap: _loadHomeData,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.p24, vertical: AppSizes.p12),
                decoration: BoxDecoration(
                  gradient: AppColors.heroGradient,
                  borderRadius: BorderRadius.circular(AppSizes.r12),
                ),
                child: const Text(AppStrings.retry, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
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
            const HomeBannerCarousel(bannerImages: AppAssets.homeBanners),

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
