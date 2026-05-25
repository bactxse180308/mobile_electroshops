import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../providers/notification_provider.dart';
import '../widgets/empty_state.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _tab = 'all';

  IconData _iconOf(NotifType type) {
    switch (type) {
      case NotifType.promo: return Icons.card_giftcard;
      case NotifType.order: return Icons.inventory_2_outlined;
      case NotifType.product: return Icons.star_border;
      case NotifType.system: return Icons.notifications_outlined;
    }
  }

  Color _colorOf(NotifType type) {
    switch (type) {
      case NotifType.promo: return AppColors.accent;
      case NotifType.order: return AppColors.primary;
      case NotifType.product: return AppColors.success;
      case NotifType.system: return AppColors.mutedForeground;
    }
  }

  Color _bgOf(NotifType type) {
    switch (type) {
      case NotifType.promo: return AppColors.accent.withOpacity(0.15);
      case NotifType.order: return AppColors.primary.withOpacity(0.1);
      case NotifType.product: return AppColors.success.withOpacity(0.15);
      case NotifType.system: return AppColors.muted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
    final list = _tab == 'all' ? provider.items : provider.unread;
    final unreadCount = provider.unread.length;

    return Column(
      children: [
        Container(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          decoration: const BoxDecoration(
            color: AppColors.background,
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const SizedBox(width: 16),
                  const Text('Thông báo', style: AppTextStyles.h3),
                  const Spacer(),
                  TextButton(
                    onPressed: () => context.read<NotificationProvider>().markAllRead(),
                    child: const Text('Đọc tất cả', style: TextStyle(fontSize: 12, color: AppColors.primary)),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Row(
                  children: [
                    Expanded(child: _Tab(label: 'Tất cả', active: _tab == 'all', onTap: () => setState(() => _tab = 'all'))),
                    const SizedBox(width: 8),
                    Expanded(child: _Tab(label: 'Chưa đọc ($unreadCount)', active: _tab == 'unread', onTap: () => setState(() => _tab = 'unread'))),
                  ],
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: list.isEmpty
              ? const EmptyState(
                  icon: Icons.notifications_off_outlined,
                  title: 'Chưa có thông báo',
                  body: 'Bạn sẽ nhận được thông báo về đơn hàng và khuyến mãi tại đây.',
                )
              : ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.border),
                  itemBuilder: (context, i) {
                    final n = list[i];
                    return GestureDetector(
                      onTap: () => context.read<NotificationProvider>().markRead(n.id),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        color: n.unread ? AppColors.primary.withOpacity(0.05) : AppColors.background,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 40, height: 40,
                              decoration: BoxDecoration(
                                color: _bgOf(n.type),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(_iconOf(n.type), size: 20, color: _colorOf(n.type)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(n.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.secondary), overflow: TextOverflow.ellipsis),
                                      ),
                                      if (n.unread)
                                        Container(
                                          width: 8, height: 8,
                                          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(n.body, style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground), maxLines: 2, overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 4),
                                  Text(n.time, style: const TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _Tab({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.muted,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: active ? Colors.white : AppColors.secondary))),
      ),
    );
  }
}
