import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../data/seed_data.dart';
import '../utils/format_utils.dart';
import '../widgets/app_button.dart';
import '../widgets/top_app_bar.dart';
import 'chat_screen.dart';

class OrderDetailScreen extends StatelessWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final orderItems = [products[0], products[3]];
    final total = orderItems.fold(0, (s, p) => s + p.price) + 25000 - 30000;

    return Scaffold(
      appBar: ElectroAppBar(title: 'Đơn #$orderId'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Status hero
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppColors.heroGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppShadows.lift,
              ),
              child: Row(
                children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: const Icon(Icons.local_shipping_outlined, size: 24, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Trạng thái', style: TextStyle(fontSize: 11, color: Colors.white70)),
                        Text('Đang giao hàng', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: const Text('Dự kiến 15/06', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),

            // Timeline
            _Card(
              title: 'Theo dõi đơn hàng',
              child: _Timeline(),
            ),

            // Products
            _Card(
              title: 'Sản phẩm',
              child: Column(
                children: orderItems.map((p) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(p.images[0], width: 64, height: 64, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(width: 64, height: 64, color: AppColors.muted),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.name, style: const TextStyle(fontSize: 13, color: AppColors.secondary), maxLines: 2, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('x1', style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                                Text(formatVND(p.price), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ),
            ),

            // Address
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 16, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text('Địa chỉ giao hàng', style: AppTextStyles.h3),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text('Nguyễn Minh Tuấn · 0901 234 567', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.secondary)),
                  SizedBox(height: 4),
                  Text('123 Nguyễn Huệ, P. Bến Nghé, Quận 1, TP.HCM', style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                ],
              ),
            ),

            // Payment summary
            _Card(
              title: 'Thanh toán',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Thanh toán khi nhận hàng (COD)', style: TextStyle(fontSize: 13, color: AppColors.secondary)),
                  const SizedBox(height: 12),
                  const Divider(color: AppColors.border),
                  const SizedBox(height: 8),
                  _Row('Tạm tính', formatVND(total - 25000 + 30000)),
                  const SizedBox(height: 6),
                  _Row('Vận chuyển', formatVND(25000)),
                  const SizedBox(height: 6),
                  _Row('Giảm giá', '-${formatVND(30000)}', AppColors.success),
                  const Divider(color: AppColors.border, height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tổng', style: AppTextStyles.h3),
                      Text(formatVND(total), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary)),
                    ],
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
              child: Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Liên hệ',
                      variant: AppButtonVariant.secondary,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [Icon(Icons.phone_outlined, size: 16), SizedBox(width: 6), Text('Liên hệ')],
                      ),
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen())),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AppButton(
                      label: 'Huỷ đơn',
                      variant: AppButtonVariant.ghost,
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  final _steps = const [
    (label: 'Đặt hàng', time: '08:12 14/06', done: true, active: false),
    (label: 'Đã xác nhận', time: '09:30 14/06', done: true, active: false),
    (label: 'Đang giao', time: '07:00 15/06', done: true, active: true),
    (label: 'Đã giao', time: 'Dự kiến 15/06', done: false, active: false),
  ];

  const _Timeline();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _steps.asMap().entries.map((e) {
        final i = e.key;
        final s = e.value;
        final isLast = i == _steps.length - 1;
        final icons = [Icons.shopping_bag_outlined, Icons.check_circle_outline, Icons.local_shipping_outlined, Icons.home_outlined];
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 24, height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: s.done ? AppColors.successGradient : null,
                    color: s.done ? null : AppColors.muted,
                    border: s.active ? Border.all(color: AppColors.success.withOpacity(0.3), width: 4) : null,
                    boxShadow: s.done ? [const BoxShadow(color: Color(0x5010B981), blurRadius: 8, offset: Offset(0, 2))] : null,
                  ),
                  child: Icon(icons[i], size: 14, color: s.done ? Colors.white : AppColors.mutedForeground),
                ),
                if (!isLast)
                  Container(
                    width: 2, height: 40,
                    color: s.done && _steps[i + 1].done ? AppColors.success : AppColors.border,
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: s.done ? AppColors.secondary : AppColors.mutedForeground)),
                    const SizedBox(height: 2),
                    Text(s.time, style: const TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                  ],
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

class _Card extends StatelessWidget {
  final String? title;
  final Widget child;
  const _Card({this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(title!, style: AppTextStyles.h3),
            const SizedBox(height: 12),
          ],
          child,
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  const _Row(this.label, this.value, [this.color]);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
        Text(value, style: TextStyle(fontSize: 12, color: color ?? AppColors.secondary)),
      ],
    );
  }
}
