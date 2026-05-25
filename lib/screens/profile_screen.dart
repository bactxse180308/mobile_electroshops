import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'order_detail_screen.dart';
import 'stores_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 16, 16, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
              ),
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
                            color: Colors.white.withOpacity(0.2),
                            border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
                          ),
                          child: const Center(child: Text('MT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 22))),
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
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Minh Tuấn', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                          const Text('minh.tuan@email.com', style: TextStyle(color: Colors.white70, fontSize: 13)),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(20)),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star, size: 12, color: Colors.white),
                                SizedBox(width: 4),
                                Text('Thành viên Vàng', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: const [
                      Expanded(child: _StatItem(label: 'Đơn hàng', value: '24')),
                      _Divider(),
                      Expanded(child: _StatItem(label: 'Voucher', value: '5')),
                      _Divider(),
                      Expanded(child: _StatItem(label: 'Yêu thích', value: '12')),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Menu items
          Container(
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppShadows.card,
            ),
            child: Column(
              children: [
                _MenuItem(
                  icon: Icons.inventory_2_outlined,
                  label: 'Đơn hàng của tôi',
                  badge: '3 đang xử lý',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderDetailScreen(orderId: 'ES2025002847'))),
                ),
                const _Divider2(),
                const _MenuItem(icon: Icons.location_on_outlined, label: 'Địa chỉ giao hàng'),
                const _Divider2(),
                const _MenuItem(icon: Icons.local_offer_outlined, label: 'Mã giảm giá', badge: '5'),
                const _Divider2(),
                const _MenuItem(icon: Icons.favorite_border, label: 'Sản phẩm yêu thích'),
                const _Divider2(),
                const _MenuItem(icon: Icons.star_border, label: 'Đánh giá của tôi'),
                const _Divider2(),
                _MenuItem(
                  icon: Icons.store_outlined,
                  label: 'Cửa hàng gần bạn',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StoresScreen())),
                ),
                const _Divider2(),
                const _MenuItem(icon: Icons.settings_outlined, label: 'Cài đặt'),
                const _Divider2(),
                const _MenuItem(icon: Icons.help_outline, label: 'Trung tâm trợ giúp'),
                const _Divider2(),
                _MenuItem(
                  icon: Icons.logout,
                  label: 'Đăng xuất',
                  iconColor: AppColors.destructive,
                  labelColor: AppColors.destructive,
                  onTap: () => Navigator.pushReplacementNamed(context, '/login'),
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
    return Container(width: 1, height: 32, color: Colors.white.withOpacity(0.2));
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.primary).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: iconColor ?? AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: TextStyle(fontSize: 14, color: labelColor ?? AppColors.secondary))),
            if (badge != null)
              Text(badge!, style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, size: 16, color: labelColor ?? AppColors.mutedForeground),
          ],
        ),
      ),
    );
  }
}
