import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/error_retry_view.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/chat_provider.dart';
import '../../../providers/admin_chat_provider.dart';
import '../../../providers/home_provider.dart';
import '../../product/widgets/product_card.dart';
import '../../product/screens/product_detail_screen.dart';
import '../../chat/screens/chat_screen.dart';
import '../../chat/screens/admin_conversations_screen.dart';
import '../widgets/home_shimmer.dart';
import '../widgets/home_header.dart';
import '../widgets/home_banner_carousel.dart';
import '../widgets/home_section_header.dart';
import '../widgets/home_categories_list.dart';
import '../widgets/home_flash_sale.dart';
import '../widgets/home_brands_list.dart';
import '../widgets/home_product_grid.dart';

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
      context.read<HomeProvider>().loadHomeData();
    });
  }

  void _goToProduct(BuildContext context, String id) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(productId: id)));
  }

  @override
  Widget build(BuildContext context) {
    final cartCount = context.watch<CartProvider>().totalCount;
    final isAdmin = context.watch<AuthProvider>().role == 'ADMIN';
    final chatCount = isAdmin
        ? context.watch<AdminChatProvider>().totalUnread
        : context.watch<ChatProvider>().unreadCount;
        
    final home = context.watch<HomeProvider>();

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
          child: home.isLoading
              ? const HomeShimmer()
              : home.errorMessage != null
                  ? ErrorRetryView(
                      errorMessage: home.errorMessage,
                      onRetry: () => home.loadHomeData(),
                    )
                  : _buildContent(home),
        ),
      ],
    );
  }

  Widget _buildContent(HomeProvider home) {
    return RefreshIndicator(
      onRefresh: home.loadHomeData,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Carousel
            HomeBannerCarousel(bannerImages: home.bannerImages),

            // Categories
            HomeCategoriesList(
              categories: home.categories,
              onCategoryTap: (id, name) {
                widget.onNavigateToCategories?.call(
                  categoryId: id,
                  categoryName: name,
                );
              },
            ),

            // Flash Sale
            HomeFlashSale(
              products: home.flashSale,
              onProductTap: (id) => _goToProduct(context, id),
              onViewAllTap: () => widget.onNavigate?.call(1),
            ),

            // Brands
            HomeBrandsList(
              brands: home.brands,
              onBrandTap: (id, name) {
                widget.onNavigateToCategories?.call(
                  brandId: id,
                  brandQuery: name,
                );
              },
            ),

            // Best Sellers
            if (home.bestSellers.isNotEmpty) ...[
              HomeSectionHeader(
                title: AppStrings.sectionBestSellers,
                onViewAllTap: () => widget.onNavigate?.call(1),
              ),
              HomeProductGrid(
                products: home.bestSellers,
                onProductTap: (id) => _goToProduct(context, id),
              ),
            ],

            // Recently Viewed
            if (home.recentlyViewed.isNotEmpty) ...[
              const HomeSectionHeader(title: AppStrings.sectionRecentlyViewed),
              SizedBox(
                height: 230,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
                  itemCount: home.recentlyViewed.length,
                  separatorBuilder: (_, __) => const SizedBox(width: AppSizes.p10),
                  itemBuilder: (context, i) => ProductCard(
                    product: home.recentlyViewed[i],
                    variant: ProductCardVariant.horizontal,
                    onTap: () => _goToProduct(context, home.recentlyViewed[i].id),
                  ),
                ),
              ),
            ],

            // New Arrivals
            if (home.newArrivals.isNotEmpty) ...[
              HomeSectionHeader(
                title: AppStrings.sectionNewArrivals,
                onViewAllTap: () => widget.onNavigate?.call(1),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.p20),
                child: HomeProductGrid(
                  products: home.newArrivals,
                  onProductTap: (id) => _goToProduct(context, id),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
