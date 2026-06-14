import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/models.dart';
import '../../../providers/notification_provider.dart';
import '../../../core/widgets/empty_state.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _tab = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().fetchNotifications();
    });
  }

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
      case NotifType.promo: return AppColors.accent.withValues(alpha: 0.15);
      case NotifType.order: return AppColors.primary.withValues(alpha: 0.1);
      case NotifType.product: return AppColors.success.withValues(alpha: 0.15);
      case NotifType.system: return AppColors.muted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
    
    List<NotifModel> list;
    switch (_tab) {
      case 'unread':
        list = provider.items.where((n) => n.unread).toList();
        break;
      case 'order':
        list = provider.items.where((n) => n.type == NotifType.order).toList();
        break;
      case 'promo':
        list = provider.items.where((n) => n.type == NotifType.promo).toList();
        break;
      case 'all':
      default:
        list = provider.items;
        break;
    }

    final unreadCount = provider.items.where((n) => n.unread).length;
    final isLoading = provider.isLoading;

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
                  const SizedBox(width: AppSizes.p16),
                  const Text(AppStrings.notificationsTitle, style: AppTextStyles.h3),
                  const Spacer(),
                  TextButton(
                    onPressed: () => context.read<NotificationProvider>().markAllRead(),
                    child: const Text(AppStrings.readAll, style: TextStyle(fontSize: 12, color: AppColors.primary)),
                  ),
                ],
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(AppSizes.p12, 0, AppSizes.p12, AppSizes.p12),
                child: Row(
                  children: [
                    _FilterChip(
                      label: AppStrings.tabAll,
                      active: _tab == 'all',
                      onTap: () => setState(() => _tab = 'all'),
                    ),
                    const SizedBox(width: AppSizes.p8),
                    _FilterChip(
                      label: '${AppStrings.tabUnread} ($unreadCount)',
                      active: _tab == 'unread',
                      onTap: () => setState(() => _tab = 'unread'),
                    ),
                    const SizedBox(width: AppSizes.p8),
                    _FilterChip(
                      label: 'Đơn hàng',
                      active: _tab == 'order',
                      onTap: () => setState(() => _tab = 'order'),
                    ),
                    const SizedBox(width: AppSizes.p8),
                    _FilterChip(
                      label: 'Khuyến mãi',
                      active: _tab == 'promo',
                      onTap: () => setState(() => _tab = 'promo'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: isLoading && provider.items.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: () => provider.fetchNotifications(),
                  child: list.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            const SizedBox(height: 100),
                            EmptyState(
                              icon: Icons.notifications_off_outlined,
                              title: provider.items.isEmpty 
                                  ? AppStrings.noNotifTitle 
                                  : 'Không có thông báo',
                              body: provider.items.isEmpty 
                                  ? AppStrings.noNotifSub 
                                  : 'Không tìm thấy thông báo nào trong danh mục này.',
                            ),
                          ],
                        )
                      : ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: list.length,
                          separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.border),
                          itemBuilder: (context, i) {
                            final n = list[i];
                            return Dismissible(
                              key: Key(n.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                color: Colors.red.shade600,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.symmetric(horizontal: AppSizes.p20),
                                child: const Icon(Icons.delete_outline, color: Colors.white, size: AppSizes.iconMd),
                              ),
                              onDismissed: (direction) {
                                context.read<NotificationProvider>().deleteNotification(n.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Đã xóa thông báo'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                              child: GestureDetector(
                                onTap: () {
                                  context.read<NotificationProvider>().markRead(n.id);
                                  if (n.type == NotifType.order && n.orderId != null) {
                                    Navigator.pushNamed(context, AppRoutes.orderDetail(n.orderId!));
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16, vertical: 14),
                                  color: n.unread ? AppColors.primary.withValues(alpha: 0.05) : AppColors.background,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 40, height: 40,
                                        decoration: BoxDecoration(
                                          color: _bgOf(n.type),
                                          borderRadius: BorderRadius.circular(AppSizes.r12),
                                        ),
                                        child: Icon(_iconOf(n.type), size: AppSizes.iconMd, color: _colorOf(n.type)),
                                      ),
                                      const SizedBox(width: AppSizes.p12),
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
                                                    width: AppSizes.p8, height: AppSizes.p8,
                                                    decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(height: 2),
                                            Text(n.body, style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground), maxLines: 2, overflow: TextOverflow.ellipsis),
                                            const SizedBox(height: AppSizes.p4),
                                            Text(n.time, style: const TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.muted,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? AppColors.primary : AppColors.border,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: active ? FontWeight.bold : FontWeight.w500,
            color: active ? Colors.white : AppColors.secondary,
          ),
        ),
      ),
    );
  }
}
