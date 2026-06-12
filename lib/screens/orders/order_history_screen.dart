import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/api_models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/format_utils.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/app_button.dart';
import '../../widgets/top_app_bar.dart';
import 'order_detail_screen.dart';

const _filters = [
  (label: 'Tất cả', status: null),
  (label: 'Chờ xác nhận', status: 'PENDING'),
  (label: 'Đã xác nhận', status: 'CONFIRMED'),
  (label: 'Đang giao', status: 'SHIPPING'),
  (label: 'Hoàn tất', status: 'COMPLETED'),
  (label: 'Đã hủy', status: 'CANCELLED'),
];

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final _scrollCtrl = ScrollController();
  String? _statusFilter;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadOrders(refresh: true));
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 200) {
      _loadOrders();
    }
  }

  Future<void> _loadOrders({bool refresh = false}) async {
    final auth = context.read<AuthProvider>();
    final token = auth.accessToken;
    final userId = auth.userId;
    if (!auth.isAuthenticated || token == null || userId == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }
    await context.read<OrderProvider>().fetchMyOrders(token, userId, refresh: refresh);
  }

  List<OrderResponse> _filteredOrders(List<OrderResponse> orders) {
    if (_statusFilter == null) return orders;
    return orders.where((o) {
      final s = o.status.toUpperCase();
      final f = _statusFilter!.toUpperCase();
      if (f == 'PENDING') {
        return s == 'PENDING' || s == 'WAITING_CONFIRM' || s == 'WAITING_CONFIRMATION';
      }
      if (f == 'SHIPPING') return s == 'SHIPPING' || s == 'DELIVERING';
      if (f == 'COMPLETED') return s == 'COMPLETED' || s == 'DELIVERED';
      if (f == 'CANCELLED') return s == 'CANCELLED' || s == 'CANCELED';
      return s == f;
    }).toList();
  }

  String _formatDate(String? date) {
    if (date == null || date.isEmpty) return '—';
    if (date.length >= 10) return date.substring(0, 10);
    return date;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final orderProvider = context.watch<OrderProvider>();
    final orders = _filteredOrders(orderProvider.orders);

    if (!auth.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
      return Scaffold(
        appBar: const ElectroAppBar(title: 'Đơn hàng của tôi'),
        body: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    return Scaffold(
      appBar: const ElectroAppBar(title: 'Đơn hàng của tôi'),
      body: Column(
        children: [
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final f = _filters[i];
                final active = _statusFilter == f.status;
                return GestureDetector(
                  onTap: () => setState(() => _statusFilter = f.status),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: active ? AppColors.primary : AppColors.muted,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: active ? AppColors.primary : AppColors.border),
                    ),
                    child: Text(
                      f.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: active ? Colors.white : AppColors.secondary,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          Expanded(
            child: orderProvider.isLoading && orders.isEmpty
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : orderProvider.error != null && orders.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(orderProvider.error!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.destructive)),
                              const SizedBox(height: 12),
                              AppButton(label: 'Thử lại', onPressed: () => _loadOrders(refresh: true)),
                            ],
                          ),
                        ),
                      )
                    : orders.isEmpty
                        ? const EmptyState(
                            icon: Icons.inventory_2_outlined,
                            title: 'Chưa có đơn hàng nào',
                            body: 'Bạn chưa có đơn hàng nào trong mục này.',
                          )
                        : RefreshIndicator(
                            color: AppColors.primary,
                            onRefresh: () => _loadOrders(refresh: true),
                            child: ListView.separated(
                              controller: _scrollCtrl,
                              padding: const EdgeInsets.all(12),
                              itemCount: orders.length + (orderProvider.isLoadingMore ? 1 : 0),
                              separatorBuilder: (_, __) => const SizedBox(height: 10),
                              itemBuilder: (context, i) {
                                if (i >= orders.length) {
                                  return const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                                  );
                                }
                                final order = orders[i];
                                final statusColor = orderStatusColor(order.orderStatus);
                                return GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => OrderDetailScreen(orderId: order.orderId)),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: AppColors.card,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: AppShadows.card,
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                '#${order.orderId}',
                                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.secondary),
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: statusColor.withOpacity(0.12),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                order.statusLabel,
                                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          _formatDate(order.orderDate),
                                          style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '${order.orderItems.length} sản phẩm',
                                              style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground),
                                            ),
                                            Text(
                                              formatVND(order.finalAmount.round()),
                                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
