import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../data/seed_data.dart';
import '../providers/cart_provider.dart';
import '../widgets/product_card.dart';
import 'product_detail_screen.dart';
import 'categories_screen.dart';

const _bannerImages = [
  'https://picsum.photos/seed/electro-banner1/800/400',
  'https://picsum.photos/seed/electro-banner2/800/400',
  'https://picsum.photos/seed/electro-banner3/800/400',
];

class HomeScreen extends StatefulWidget {
  final ValueChanged<int>? onNavigate;
  const HomeScreen({super.key, this.onNavigate});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _bannerIndex = 0;
  Timer? _bannerTimer;

  @override
  void initState() {
    super.initState();
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (mounted) setState(() => _bannerIndex = (_bannerIndex + 1) % _bannerImages.length);
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    super.dispose();
  }

  void _goToProduct(BuildContext context, String id) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(productId: id)));
  }

  @override
  Widget build(BuildContext context) {
    final cartCount = context.watch<CartProvider>().totalCount;
    return Column(
      children: [
        // Gradient header
        Container(
          decoration: const BoxDecoration(gradient: AppColors.heroGradient),
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16, right: 16, bottom: 20,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 16, color: Colors.white),
                  const SizedBox(width: 4),
                  const Text('Giao đến: Q.1, TP.HCM', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                  const Icon(Icons.expand_more, size: 16, color: Colors.white),
                  const Spacer(),
                  IconButton(
                    icon: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(Icons.notifications_outlined, color: Colors.white, size: 22),
                        Positioned(
                          top: -2, right: -2,
                          child: Container(
                            width: 8, height: 8,
                            decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                          ),
                        ),
                      ],
                    ),
                    onPressed: () => widget.onNavigate?.call(3),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 22),
                        if (cartCount > 0)
                          Positioned(
                            top: -4, right: -6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(gradient: AppColors.flashGradient, borderRadius: BorderRadius.circular(8)),
                              child: Text('$cartCount', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                            ),
                          ),
                      ],
                    ),
                    onPressed: () => widget.onNavigate?.call(2),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => widget.onNavigate?.call(1),
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: AppShadows.lift,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: const Row(
                    children: [
                      Icon(Icons.search, size: 20, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text('Tìm RAM, SSD, bàn phím…', style: TextStyle(color: AppColors.mutedForeground, fontSize: 14)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // Scrollable content
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Banner
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        AspectRatio(
                          aspectRatio: 2,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 700),
                            child: Image.network(
                              _bannerImages[_bannerIndex],
                              key: ValueKey(_bannerIndex),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (_, __, ___) => Container(color: AppColors.muted, height: 160),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 10,
                          left: 0, right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(3, (i) => AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              width: i == _bannerIndex ? 24 : 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: i == _bannerIndex ? Colors.white : Colors.white60,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            )),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Categories
                _SectionHeader(title: 'Danh mục', padding: const EdgeInsets.fromLTRB(16, 20, 16, 12)),
                SizedBox(
                  height: 90,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, i) {
                      final cat = categories[i];
                      final isEven = i % 2 == 0;
                      return GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(
                          builder: (_) => CategoriesScreen(initialCategory: cat.id),
                        )),
                        child: SizedBox(
                          width: 64,
                          child: Column(
                            children: [
                              Container(
                                width: 56, height: 56,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                                    colors: isEven
                                        ? [const Color(0xFFFEF3C7), Colors.white]
                                        : [const Color(0xFFEFF6FF), Colors.white],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: AppShadows.card,
                                ),
                                child: Icon(cat.icon, size: 24, color: AppColors.primary),
                              ),
                              const SizedBox(height: 6),
                              Text(cat.name, style: const TextStyle(fontSize: 10, color: AppColors.secondary, fontWeight: FontWeight.w500), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Flash Sale
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppShadows.lift,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: const BoxDecoration(gradient: AppColors.flashGradient),
                            child: Row(
                              children: [
                                const Icon(Icons.local_fire_department, color: Colors.white, size: 20),
                                const SizedBox(width: 8),
                                const Text('FLASH SALE', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                                const Spacer(),
                                const _CountdownTimer(),
                              ],
                            ),
                          ),
                          Container(
                            color: AppColors.card,
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 230,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    padding: const EdgeInsets.all(12),
                                    itemCount: flashSale.length,
                                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                                    itemBuilder: (context, i) => ProductCard(
                                      product: flashSale[i],
                                      variant: ProductCardVariant.horizontal,
                                      onTap: () => _goToProduct(context, flashSale[i].id),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => widget.onNavigate?.call(1),
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.border))),
                                    child: const Text('Xem tất cả →', textAlign: TextAlign.center, style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Brands
                _SectionHeader(title: 'Thương hiệu nổi bật', padding: const EdgeInsets.fromLTRB(16, 20, 16, 12)),
                SizedBox(
                  height: 56,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: brands.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, i) {
                      final b = brands[i];
                      return GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(
                          builder: (_) => CategoriesScreen(initialQuery: b.name),
                        )),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: AppShadows.card,
                          ),
                          child: Center(
                            child: Text(b.name, style: TextStyle(color: b.color, fontSize: 13, fontWeight: FontWeight.w900)),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Best Sellers
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome, size: 18, color: AppColors.accent),
                      const SizedBox(width: 8),
                      const Text('Bán chạy nhất', style: AppTextStyles.h3),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => widget.onNavigate?.call(1),
                        child: const Text('Xem tất cả', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 0.52,
                    children: bestSellers.map((p) => ProductCard(
                      product: p,
                      onTap: () => _goToProduct(context, p.id),
                    )).toList(),
                  ),
                ),

                // Recently Viewed
                _SectionHeader(title: 'Đã xem gần đây', padding: const EdgeInsets.fromLTRB(16, 20, 16, 8)),
                SizedBox(
                  height: 230,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: recentlyViewed.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, i) => ProductCard(
                      product: recentlyViewed[i],
                      variant: ProductCardVariant.horizontal,
                      onTap: () => _goToProduct(context, recentlyViewed[i].id),
                    ),
                  ),
                ),

                // New Arrivals
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                  child: Row(
                    children: [
                      const Text('Mới về', style: AppTextStyles.h3),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => widget.onNavigate?.call(1),
                        child: const Text('Xem tất cả', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 0.52,
                    children: newArrivals.map((p) => ProductCard(
                      product: p,
                      onTap: () => _goToProduct(context, p.id),
                    )).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final EdgeInsets padding;
  const _SectionHeader({required this.title, required this.padding});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(title, style: AppTextStyles.h3),
    );
  }
}

class _CountdownTimer extends StatefulWidget {
  const _CountdownTimer();

  @override
  State<_CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<_CountdownTimer> {
  int _h = 5, _m = 42, _s = 18;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _s--;
        if (_s < 0) { _s = 59; _m--; }
        if (_m < 0) { _m = 59; _h--; }
        if (_h < 0) { _h = 5; _m = 42; _s = 18; }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String pad(int n) => n.toString().padLeft(2, '0');
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.access_time, color: Colors.white70, size: 12),
        const SizedBox(width: 4),
        _Chip(pad(_h)),
        const Text(':', style: TextStyle(color: Colors.white70, fontSize: 12)),
        _Chip(pad(_m)),
        const Text(':', style: TextStyle(color: Colors.white70, fontSize: 12)),
        _Chip(pad(_s)),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  const _Chip(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(4)),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700, fontFeatures: [FontFeature.tabularFigures()])),
    );
  }
}
