import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/api_models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/format_utils.dart';
import '../../widgets/app_button.dart';
import '../../widgets/top_app_bar.dart';
import '../chat_screen.dart';

class OrderDetailScreen extends StatefulWidget {
  final dynamic orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadOrder());
  }

  int get _parsedId {
    if (widget.orderId is int) return widget.orderId as int;
    return int.tryParse(widget.orderId.toString()) ?? 0;
  }

  Future<void> _loadOrder() async {
    final auth = context.read<AuthProvider>();
    if (!auth.isAuthenticated || auth.accessToken == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }
    if (_parsedId == 0) return;
    await context.read<OrderProvider>().fetchOrderById(_parsedId, auth.accessToken!);
  }

  Future<void> _cancelOrder() async {
    final auth = context.read<AuthProvider>();
    final token = auth.accessToken;
    if (!auth.isAuthenticated || token == null || _parsedId == 0) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    final success = await context.read<OrderProvider>().cancelOrder(_parsedId, token);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Đã hủy đơn hàng' : (context.read<OrderProvider>().error ?? 'Không thể hủy đơn hàng')),
        backgroundColor: success ? AppColors.success : AppColors.destructive,
      ),
    );

    if (success) {
      await _loadOrder();
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();
    final currentOrder = orderProvider.currentOrder;
    final order = currentOrder?.orderId == _parsedId ? currentOrder : null;
    final isLoading = orderProvider.isLoading && order == null;

    if (isLoading) {
      return Scaffold(
        appBar: ElectroAppBar(title: 'Đơn #${widget.orderId}'),
        body: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    if (order == null) {
      return Scaffold(
        appBar: ElectroAppBar(title: 'Đơn #${widget.orderId}'),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(orderProvider.error ?? 'Không tìm thấy đơn hàng', textAlign: TextAlign.center),
                const SizedBox(height: 12),
                AppButton(label: 'Thử lại', onPressed: _loadOrder),
              ],
            ),
          ),
        ),
      );
    }

    final statusColor = orderStatusColor(order.orderStatus);
    final canCancel = order.orderStatus.toUpperCase() == 'PENDING';

    return Scaffold(
      appBar: ElectroAppBar(title: 'Đơn #${order.orderId}'),
      body: SingleChildScrollView(
        child: Column(
          children: [
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
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: const Icon(Icons.local_shipping_outlined, size: 24, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Trạng thái', style: TextStyle(fontSize: 11, color: Colors.white70)),
                        Text(order.statusLabel, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Text(
                      order.statusLabel,
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            _Card(
              title: 'Theo dõi đơn hàng',
              child: _Timeline(status: order.orderStatus, createdDate: order.orderDate),
            ),
            _Card(
              title: 'Thông tin đơn hàng',
              child: Column(
                children: [
                  _Row('Mã đơn hàng', '#${order.orderId}'),
                  const SizedBox(height: 6),
                  _Row('Ngày đặt', _formatDate(order.orderDate)),
                ],
              ),
            ),
            _Card(
              title: 'Sản phẩm',
              child: Column(
                children: order.orderItems.map((item) {
                  final image = item.productImage ??
                      'https://picsum.photos/seed/${item.productId}_cover/600/600';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            image,
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(width: 64, height: 64, color: AppColors.muted),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.productName,
                                style: const TextStyle(fontSize: 13, color: AppColors.secondary),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('x${item.quantity}', style: const TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                                  Text(
                                    formatVND(item.subtotal.round()),
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 16, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text('Địa chỉ giao hàng', style: AppTextStyles.h3),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${order.recipientName} · ${order.recipientPhone}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.secondary),
                  ),
                  const SizedBox(height: 4),
                  Text(order.shippingAddress, style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                  if (order.note != null && order.note!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text('Ghi chú: ${order.note}', style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                  ],
                ],
              ),
            ),
            _Card(
              title: 'Thanh toán',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(order.paymentMethodLabel, style: const TextStyle(fontSize: 13, color: AppColors.secondary)),
                  const SizedBox(height: 6),
                  Text(
                    order.paymentStatus.isNotEmpty ? order.paymentStatus : 'Chưa thanh toán',
                    style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground),
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: AppColors.border),
                  const SizedBox(height: 8),
                  _Row('Tạm tính', formatVND(order.totalAmount.round())),
                  const SizedBox(height: 6),
                  _Row('Vận chuyển', formatVND(order.shippingFee.round())),
                  if (order.discountAmount > 0) ...[
                    const SizedBox(height: 6),
                    _Row('Giảm giá', '-${formatVND(order.discountAmount.round())}', AppColors.success),
                  ],
                  const Divider(color: AppColors.border, height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tổng', style: AppTextStyles.h3),
                      Text(
                        formatVND(order.finalAmount.round()),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
              child: Column(
                children: [
                  if (canCancel) ...[
                    AppButton(
                      label: orderProvider.isCancelling ? 'Đang hủy...' : 'Hủy đơn hàng',
                      variant: AppButtonVariant.danger,
                      size: AppButtonSize.lg,
                      fullWidth: true,
                      disabled: orderProvider.isCancelling,
                      onPressed: _cancelOrder,
                    ),
                    const SizedBox(height: 10),
                  ],
                  AppButton(
                    label: 'Liên hệ',
                    variant: AppButtonVariant.secondary,
                    fullWidth: true,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Icon(Icons.phone_outlined, size: 16), SizedBox(width: 6), Text('Liên hệ')],
                    ),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen())),
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

String _formatDate(String? date) {
  if (date == null || date.isEmpty) return '—';
  if (date.length >= 10) return date.substring(0, 10);
  return date;
}

class _Timeline extends StatelessWidget {
  final String status;
  final String? createdDate;

  const _Timeline({required this.status, this.createdDate});

  int _stepIndex(String s) {
    switch (s.toUpperCase()) {
      case 'PENDING':
      case 'WAITING_CONFIRM':
      case 'WAITING_CONFIRMATION':
        return 0;
      case 'CONFIRMED':
        return 1;
      case 'SHIPPING':
      case 'DELIVERING':
        return 2;
      case 'COMPLETED':
      case 'DELIVERED':
        return 3;
      case 'CANCELLED':
      case 'CANCELED':
        return -1;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = _stepIndex(status);
    final isCancelled = current == -1;
    final date = createdDate != null && createdDate!.length >= 10 ? createdDate!.substring(0, 10) : '—';

    final steps = [
      (label: 'Đặt hàng', time: date),
      (label: 'Đã xác nhận', time: current >= 1 ? date : 'Chờ xác nhận'),
      (label: 'Đang giao', time: current >= 2 ? 'Đang vận chuyển' : 'Chờ giao'),
      (label: 'Hoàn tất', time: current >= 3 ? 'Đã giao' : 'Dự kiến'),
    ];

    if (isCancelled) {
      return const Text('Đơn hàng đã bị hủy', style: TextStyle(fontSize: 13, color: AppColors.destructive));
    }

    return Column(
      children: steps.asMap().entries.map((e) {
        final i = e.key;
        final s = e.value;
        final isLast = i == steps.length - 1;
        final done = i <= current;
        final active = i == current;
        final icons = [Icons.shopping_bag_outlined, Icons.check_circle_outline, Icons.local_shipping_outlined, Icons.home_outlined];
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: done ? AppColors.successGradient : null,
                    color: done ? null : AppColors.muted,
                    border: active ? Border.all(color: AppColors.success.withOpacity(0.3), width: 4) : null,
                  ),
                  child: Icon(icons[i], size: 14, color: done ? Colors.white : AppColors.mutedForeground),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 40,
                    color: done && i < current ? AppColors.success : AppColors.border,
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
                    Text(
                      s.label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: done ? AppColors.secondary : AppColors.mutedForeground,
                      ),
                    ),
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
