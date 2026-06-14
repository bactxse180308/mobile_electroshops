import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_routes.dart';
import '../../cart/screens/order_history_screen.dart';
import '../../stores/screens/stores_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final name = authProvider.fullName ?? AppStrings.guest;
    final email = authProvider.email ?? AppStrings.notLoggedIn;
    
    // Generate initials from name
    String initials = 'K';
    if (name.trim().isNotEmpty) {
      final parts = name.trim().split(' ');
      if (parts.length >= 2) {
        initials = (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
      } else if (parts.isNotEmpty) {
        initials = parts[0][0].toUpperCase();
      }
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.fromLTRB(AppSizes.p16, MediaQuery.of(context).padding.top + AppSizes.p16, AppSizes.p16, AppSizes.p20),
            decoration: const BoxDecoration(
              gradient: AppColors.profileGradient,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 64, height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.2),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 2),
                          ),
                          child: Center(
                            child: Text(
                              initials, 
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 22),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0, right: 0,
                          child: Container(
                            width: 22, height: 22,
                            decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                            child: const Icon(Icons.edit, size: 12, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: AppSizes.p12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                          Text(email, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                          const SizedBox(height: AppSizes.p6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: AppSizes.p8, vertical: 2),
                            decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(AppSizes.r20)),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star, size: 12, color: Colors.white),
                                SizedBox(width: AppSizes.p4),
                                Text(AppStrings.goldMember, style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.p16),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: AppSizes.p12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSizes.r12),
                  ),
                  child: Row(
                    children: const [
                      Expanded(child: _StatItem(label: AppStrings.orderCount, value: '24')),
                      _Divider(),
                      Expanded(child: _StatItem(label: AppStrings.voucher, value: '5')),
                      _Divider(),
                      Expanded(child: _StatItem(label: AppStrings.favCount, value: '12')),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Menu items
          Container(
            margin: const EdgeInsets.fromLTRB(AppSizes.p12, 0, AppSizes.p12, AppSizes.p12),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppSizes.r16),
              boxShadow: AppShadows.card,
            ),
            child: Column(
              children: [
                _MenuItem(
                  icon: Icons.inventory_2_outlined,
                  label: AppStrings.myOrders,
                  badge: AppStrings.pendingOrders,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
                  ),
                ),
                const _Divider2(),
                const _MenuItem(icon: Icons.location_on_outlined, label: AppStrings.shippingAddress),
                const _Divider2(),
                const _MenuItem(icon: Icons.local_offer_outlined, label: AppStrings.coupons, badge: '5'),
                const _Divider2(),
                const _MenuItem(icon: Icons.favorite_border, label: AppStrings.favoriteProducts),
                const _Divider2(),
                const _MenuItem(icon: Icons.star_border, label: AppStrings.myReviews),
                const _Divider2(),
                _MenuItem(
                  icon: Icons.store_outlined,
                  label: AppStrings.nearbyStores,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StoresScreen())),
                ),
                const _Divider2(),
                const _MenuItem(icon: Icons.settings_outlined, label: AppStrings.settings),
                const _Divider2(),
                const _MenuItem(icon: Icons.help_outline, label: AppStrings.helpCenter),
                const _Divider2(),
                _MenuItem(
                  icon: Icons.logout,
                  label: AppStrings.logout,
                  iconColor: AppColors.destructive,
                  labelColor: AppColors.destructive,
                  onTap: () async {
                    await context.read<AuthProvider>().logout();
                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
                    }
                  },
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text('ElectroShop v2.4.0', style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 32, color: Colors.white.withValues(alpha: 0.2));
  }
}

class _Divider2 extends StatelessWidget {
  const _Divider2();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, indent: 56, color: AppColors.border);
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? badge;
  final Color? iconColor;
  final Color? labelColor;
  final VoidCallback? onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    this.badge,
    this.iconColor,
    this.labelColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: AppSizes.btnHeightSm, height: AppSizes.btnHeightSm,
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.primary).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: AppSizes.iconMd, color: iconColor ?? AppColors.primary),
            ),
            const SizedBox(width: AppSizes.p12),
            Expanded(child: Text(label, style: TextStyle(fontSize: 14, color: labelColor ?? AppColors.secondary))),
            if (badge != null)
              Text(badge!, style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
            const SizedBox(width: AppSizes.p4),
            Icon(Icons.chevron_right, size: AppSizes.iconSm, color: labelColor ?? AppColors.mutedForeground),
          ],
        ),
      ),
    );
  }
}
