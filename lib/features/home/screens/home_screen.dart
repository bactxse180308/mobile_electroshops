import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/widgets/shimmer_box.dart';
import '../../../providers/product_provider.dart';
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ProductProvider>();
      if (provider.homeCategories.isEmpty) {
        provider.loadHomeData();
      }
    });
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
    final productProvider = context.watch<ProductProvider>();

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
          child: productProvider.isLoadingHome
              ? _buildShimmer()
              : productProvider.homeError != null
                  ? _buildError(productProvider)
                  : _buildContent(productProvider),
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
  Widget _buildError(ProductProvider provider) {
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
              provider.homeError ?? AppStrings.error,
              style: const TextStyle(fontSize: 13, color: AppColors.mutedForeground),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.p24),
            GestureDetector(
              onTap: provider.loadHomeData,
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
  Widget _buildContent(ProductProvider provider) {
    return RefreshIndicator(
      onRefresh: provider.loadHomeData,
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
              categories: provider.homeCategories,
              onCategoryTap: (id, name) {
                widget.onNavigateToCategories?.call(
                  categoryId: id,
                  categoryName: name,
                );
              },
            ),

            // Flash Sale
            HomeFlashSale(
              products: provider.flashSale,
              onProductTap: (id) => _goToProduct(context, id),
              onViewAllTap: () => widget.onNavigate?.call(1),
            ),

            // Brands
            HomeBrandsList(
              brands: provider.homeBrands,
              onBrandTap: (id, name) {
                widget.onNavigateToCategories?.call(
                  brandId: id,
                  brandQuery: name,
                );
              },
            ),

            // Best Sellers
            if (provider.bestSellers.isNotEmpty) ...[
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
                  children: provider.bestSellers.map((p) => ProductCard(
                    product: p,
                    onTap: () => _goToProduct(context, p.id),
                  )).toList(),
                ),
              ),
            ],

            // Recently Viewed
            if (provider.recentlyViewed.isNotEmpty) ...[
              const HomeSectionHeader(title: AppStrings.sectionRecentlyViewed),
              SizedBox(
                height: 230,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
                  itemCount: provider.recentlyViewed.length,
                  separatorBuilder: (_, __) => const SizedBox(width: AppSizes.p10),
                  itemBuilder: (context, i) => ProductCard(
                    product: provider.recentlyViewed[i],
                    variant: ProductCardVariant.horizontal,
                    onTap: () => _goToProduct(context, provider.recentlyViewed[i].id),
                  ),
                ),
              ),
            ],

            // New Arrivals
            if (provider.newArrivals.isNotEmpty) ...[
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
                  children: provider.newArrivals.map((p) => ProductCard(
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
