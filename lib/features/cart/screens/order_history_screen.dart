import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/format_utils.dart';
import '../../../core/widgets/top_app_bar.dart';
import '../../../models/api_models.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/order_provider.dart';
import 'order_detail_screen.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final ScrollController _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _loadOrders(refresh: true));
  }

  @override
  void dispose() {
    _scrollCtrl.removeListener(_onScroll);
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      final op = context.read<OrderProvider>();
      final auth = context.read<AuthProvider>();
      if (op.hasMore &&
          !op.isLoadingMore &&
          !op.isLoading &&
          auth.accessToken != null &&
          auth.userId != null) {
        op.fetchMyOrders(auth.accessToken!, auth.userId!);
      }
    }
  }

  Future<void> _loadOrders({bool refresh = false}) async {
    final auth = context.read<AuthProvider>();
    if (auth.accessToken != null && auth.userId != null) {
      await context
          .read<OrderProvider>()
          .fetchMyOrders(auth.accessToken!, auth.userId!, refresh: refresh);
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return 'Chờ xử lý';
      case 'CONFIRMED':
        return 'Đã xác nhận';
      case 'PROCESSING':
        return 'Đang chuẩn bị';
      case 'SHIPPED':
        return 'Đang giao';
      case 'DELIVERED':
        return 'Đã giao';
      case 'CANCELLED':
        return 'Đã hủy';
      case 'REFUNDED':
        return 'Đã hoàn tiền';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Colors.orange;
      case 'CONFIRMED':
        return Colors.indigo;
      case 'PROCESSING':
        return Colors.purple;
      case 'SHIPPED':
        return Colors.blue;
      case 'DELIVERED':
        return AppColors.success;
      case 'CANCELLED':
      case 'REFUNDED':
        return AppColors.destructive;
      default:
        return AppColors.mutedForeground;
    }
  }

  @override
  Widget build(BuildContext context) {
    final op = context.watch<OrderProvider>();
    final orders = op.orders;

    return Scaffold(
      appBar: const ElectroAppBar(title: AppStrings.myOrders),
      body: RefreshIndicator(
        onRefresh: () => _loadOrders(refresh: true),
        child: _buildBody(op, orders),
      ),
    );
  }

  Widget _buildBody(OrderProvider op, List<OrderResponse> orders) {
    if (op.isLoading && orders.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (orders.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.25),
          const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_2_outlined,
                    size: 72, color: AppColors.muted),
                SizedBox(height: AppSizes.p16),
                Text(
                  'Không có đơn hàng nào',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondary),
                ),
                SizedBox(height: AppSizes.p8),
                Text(
                  'Hãy mua sắm sản phẩm công nghệ ngay!',
                  style:
                      TextStyle(fontSize: 13, color: AppColors.mutedForeground),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      controller: _scrollCtrl,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSizes.p12),
      itemCount: orders.length + (op.hasMore ? 1 : 0),
      itemBuilder: (context, idx) {
        if (idx == orders.length) {
          return const Padding(
            padding: EdgeInsets.all(AppSizes.p12),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final order = orders[idx];
        return _OrderCard(
          order: order,
          statusLabel: _getStatusLabel(order.orderStatus),
          statusColor: _getStatusColor(order.orderStatus),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  OrderDetailScreen(orderId: order.orderId.toString()),
            ),
          ),
        );
      },
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderResponse order;
  final String statusLabel;
  final Color statusColor;
  final VoidCallback onTap;

  const _OrderCard({
    required this.order,
    required this.statusLabel,
    required this.statusColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final totalQty =
        order.orderItems.fold(0, (sum, item) => sum + item.quantity);
    final firstItem =
        order.orderItems.isNotEmpty ? order.orderItems.first : null;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.p12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.r16),
        boxShadow: AppShadows.card,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSizes.r16),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.p16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${AppStrings.orderPrefix}${order.orderId}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.secondary,
                          fontSize: 14),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.p10, vertical: AppSizes.p4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppSizes.r20),
                        border: Border.all(
                            color: statusColor.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        statusLabel,
                        style: TextStyle(
                            color: statusColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSizes.p10),
                  child: Divider(color: AppColors.border, height: 1),
                ),
                if (firstItem != null) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppSizes.r8),
                        child: firstItem.productImage != null &&
                                firstItem.productImage!.isNotEmpty
                            ? Image.network(
                                firstItem.productImage!,
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                    width: 56,
                                    height: 56,
                                    color: AppColors.muted),
                              )
                            : Container(
                                width: 56, height: 56, color: AppColors.muted),
                      ),
                      const SizedBox(width: AppSizes.p12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              firstItem.productName,
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.secondary,
                                  fontWeight: FontWeight.w500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: AppSizes.p4),
                            Text(
                              'Số lượng: ${firstItem.quantity}',
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.mutedForeground),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        formatVND(firstItem.subtotal.round()),
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.secondary),
                      ),
                    ],
                  ),
                  if (order.orderItems.length > 1) ...[
                    const SizedBox(height: AppSizes.p8),
                    Center(
                      child: Text(
                        'Xem thêm ${order.orderItems.length - 1} sản phẩm',
                        style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.mutedForeground,
                            fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSizes.p10),
                    child: Divider(color: AppColors.border, height: 1),
                  ),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$totalQty sản phẩm',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.mutedForeground),
                    ),
                    Row(
                      children: [
                        const Text(
                          'Tổng tiền: ',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.secondary),
                        ),
                        Text(
                          formatVND(order.finalAmount.round()),
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
