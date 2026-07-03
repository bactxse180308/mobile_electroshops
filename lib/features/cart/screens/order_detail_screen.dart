import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/format_utils.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/top_app_bar.dart';
import '../../../models/api_models.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/order_provider.dart';
import '../../chat/screens/chat_screen.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.accessToken != null) {
        context
            .read<OrderProvider>()
            .fetchOrderById(int.parse(widget.orderId), auth.accessToken!);
      }
    });
  }

  void _showCancelDialog(BuildContext context, OrderResponse order) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận hủy đơn'),
        content: const Text('Bạn có chắc chắn muốn hủy đơn hàng này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đóng'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final auth = context.read<AuthProvider>();
              final op = context.read<OrderProvider>();
              final success =
                  await op.cancelOrder(order.orderId, auth.accessToken!);
              if (success) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Hủy đơn hàng thành công')),
                );
              } else {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(op.error ?? 'Hủy đơn hàng thất bại')),
                );
              }
            },
            child: const Text('Hủy đơn',
                style: TextStyle(color: AppColors.destructive)),
          ),
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return 'Chờ xử lý';
      case 'CONFIRMED':
        return 'Đã xác nhận';
      case 'PROCESSING':
        return 'Đang chuẩn bị';
      case 'SHIPPED':
        return 'Đang giao hàng';
      case 'DELIVERED':
        return 'Đã giao hàng';
      case 'CANCELLED':
        return 'Đã hủy';
      case 'REFUNDED':
        return 'Đã hoàn tiền';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final op = context.watch<OrderProvider>();
    final order = op.currentOrder;

    return Scaffold(
      appBar:
          ElectroAppBar(title: '${AppStrings.orderPrefix}${widget.orderId}'),
      body: _buildBody(op, order),
    );
  }

  Widget _buildBody(OrderProvider op, OrderResponse? order) {
    if (op.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (order == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline,
                size: 48, color: AppColors.destructive),
            const SizedBox(height: AppSizes.p16),
            Text(op.error ?? 'Không thể tải chi tiết đơn hàng'),
            const SizedBox(height: AppSizes.p12),
            ElevatedButton(
              onPressed: () {
                final auth = context.read<AuthProvider>();
                if (auth.accessToken != null) {
                  op.fetchOrderById(
                      int.parse(widget.orderId), auth.accessToken!);
                }
              },
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    // Parse combined shipping address info (Name | Phone | Address)
    String recipientName = order.userFullName ?? AppStrings.mockUserName;
    String recipientPhone = AppStrings.mockUserPhone;
    String actualAddress = order.shippingAddress ?? '';
    final addressParts = (order.shippingAddress ?? '').split(' | ');
    if (addressParts.length >= 3) {
      recipientName = addressParts[0];
      recipientPhone = addressParts[1];
      actualAddress = addressParts[2];
    }

    final shippingFee =
        order.finalAmount - order.totalAmount + order.discountAmount;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Status hero
          Container(
            margin: const EdgeInsets.all(AppSizes.p12),
            padding: const EdgeInsets.all(AppSizes.p16),
            decoration: BoxDecoration(
              gradient: AppColors.heroGradient,
              borderRadius: BorderRadius.circular(AppSizes.r16),
              boxShadow: AppShadows.lift,
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  child: const Icon(Icons.local_shipping_outlined,
                      size: 24, color: Colors.white),
                ),
                const SizedBox(width: AppSizes.p12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppStrings.orderStatusLabel.replaceAll(':', ''),
                          style: const TextStyle(
                              fontSize: 11, color: Colors.white70)),
                      Text(
                        _getStatusText(order.orderStatus),
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),
                if (order.orderStatus.toUpperCase() == 'DELIVERED')
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.p12, vertical: AppSizes.p4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppSizes.r20),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: const Text('Thành công',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  ),
              ],
            ),
          ),

          // Timeline
          _Card(
            title: AppStrings.orderTracking,
            child: _Timeline(order: order),
          ),

          // Products
          _Card(
            title: AppStrings.productsTitle,
            child: Column(
              children: order.orderItems
                  .map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSizes.p12),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(AppSizes.r8),
                              child: item.productImage != null &&
                                      item.productImage!.isNotEmpty
                                  ? Image.network(
                                      item.productImage!,
                                      width: 64,
                                      height: 64,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                          width: 64,
                                          height: 64,
                                          color: AppColors.muted),
                                    )
                                  : Container(
                                      width: 64,
                                      height: 64,
                                      color: AppColors.muted),
                            ),
                            const SizedBox(width: AppSizes.p12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.productName,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.secondary),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: AppSizes.p4),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('x${item.quantity}',
                                          style: const TextStyle(
                                              fontSize: 11,
                                              color:
                                                  AppColors.mutedForeground)),
                                      Text(formatVND(item.unitPrice.round()),
                                          style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.primary)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),

          // Address
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.location_on_outlined,
                        size: 16, color: AppColors.primary),
                    SizedBox(width: AppSizes.p8),
                    Text(AppStrings.shippingAddress, style: AppTextStyles.h3),
                  ],
                ),
                const SizedBox(height: AppSizes.p8),
                Text('$recipientName · $recipientPhone',
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondary)),
                const SizedBox(height: AppSizes.p4),
                Text(actualAddress,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.mutedForeground)),
              ],
            ),
          ),

          // Payment summary
          _Card(
            title: AppStrings.stepPayment,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${order.paymentMethod} (${order.paymentStatus})',
                  style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w600),
                ),
                if (order.voucherCode != null) ...[
                  const SizedBox(height: AppSizes.p4),
                  Text(
                    'Mã giảm giá/Ghi chú: ${order.voucherCode}',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.mutedForeground),
                  ),
                ],
                const SizedBox(height: AppSizes.p12),
                const Divider(color: AppColors.border),
                const SizedBox(height: AppSizes.p8),
                _Row(AppStrings.subtotal, formatVND(order.totalAmount.round())),
                const SizedBox(height: AppSizes.p6),
                _Row(
                    AppStrings.shipping,
                    shippingFee == 0
                        ? AppStrings.free
                        : formatVND(shippingFee.round())),
                const SizedBox(height: AppSizes.p6),
                _Row(
                    AppStrings.discount,
                    '-${formatVND(order.discountAmount.round())}',
                    AppColors.success),
                const Divider(color: AppColors.border, height: AppSizes.p16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(AppStrings.total, style: AppTextStyles.h3),
                    Text(formatVND(order.finalAmount.round()),
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary)),
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSizes.p12, 0, AppSizes.p12, AppSizes.p20),
            child: Row(
              children: [
                // Admin không chat với vai trò khách → ẩn nút liên hệ cho ADMIN.
                if (context.watch<AuthProvider>().role != 'ADMIN')
                  Expanded(
                    child: AppButton(
                      label: AppStrings.contact,
                      variant: AppButtonVariant.secondary,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.phone_outlined, size: 16),
                          SizedBox(width: AppSizes.p6),
                          Text(AppStrings.contact)
                        ],
                      ),
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ChatScreen())),
                    ),
                  ),
                if (order.orderStatus.toUpperCase() == 'PENDING') ...[
                  const SizedBox(width: AppSizes.p8),
                  Expanded(
                    child: AppButton(
                      label: op.isCancelling ? null : AppStrings.cancelOrder,
                      variant: AppButtonVariant.ghost,
                      disabled: op.isCancelling,
                      onPressed: () => _showCancelDialog(context, order),
                      child: op.isCancelling
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: AppColors.primary, strokeWidth: 2),
                            )
                          : null,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  final OrderResponse order;

  const _Timeline({required this.order});

  @override
  Widget build(BuildContext context) {
    final status = order.orderStatus.toUpperCase();
    final isCancelled = status == 'CANCELLED';
    final isRefunded = status == 'REFUNDED';

    final List<({String label, String time, bool done, bool active})> steps;

    if (isCancelled || isRefunded) {
      steps = [
        (
          label: 'Đặt hàng thành công',
          time: order.orderDate != null
              ? order.orderDate!.substring(0, 16).replaceAll('T', ' ')
              : '',
          done: true,
          active: false
        ),
        (
          label: isRefunded ? 'Đã hoàn tiền' : 'Đã hủy đơn hàng',
          time: order.updatedAt != null
              ? order.updatedAt!.substring(0, 16).replaceAll('T', ' ')
              : '',
          done: true,
          active: true
        ),
      ];
    } else {
      final isPending = status == 'PENDING';
      final isConfirmed = status == 'CONFIRMED';
      final isProcessing = status == 'PROCESSING';
      final isShipped = status == 'SHIPPED';
      final isDelivered = status == 'DELIVERED';

      steps = [
        (
          label: AppStrings.placeOrder,
          time: order.orderDate != null
              ? order.orderDate!.substring(0, 16).replaceAll('T', ' ')
              : '',
          done: true,
          active: isPending
        ),
        (
          label: AppStrings.orderConfirmed,
          time: (isConfirmed || isProcessing || isShipped || isDelivered)
              ? 'Đã xác nhận'
              : '',
          done: isConfirmed || isProcessing || isShipped || isDelivered,
          active: isConfirmed
        ),
        (
          label: 'Đang chuẩn bị hàng',
          time:
              (isProcessing || isShipped || isDelivered) ? 'Đang đóng gói' : '',
          done: isProcessing || isShipped || isDelivered,
          active: isProcessing
        ),
        (
          label: AppStrings.orderShipping,
          time: (isShipped || isDelivered) ? 'Đang vận chuyển' : '',
          done: isShipped || isDelivered,
          active: isShipped
        ),
        (
          label: AppStrings.orderDelivered,
          time:
              isDelivered ? 'Đã giao hàng thành công' : AppStrings.estDelivery,
          done: isDelivered,
          active: isDelivered
        ),
      ];
    }

    return Column(
      children: steps.asMap().entries.map((e) {
        final i = e.key;
        final s = e.value;
        final isLast = i == steps.length - 1;
        final icons = isCancelled || isRefunded
            ? [Icons.shopping_bag_outlined, Icons.cancel_outlined]
            : [
                Icons.shopping_bag_outlined,
                Icons.check_circle_outline,
                Icons.inventory_2_outlined,
                Icons.local_shipping_outlined,
                Icons.home_outlined
              ];

        final color = (isCancelled || isRefunded) && i == 1
            ? AppColors.destructive
            : AppColors.success;
        final gradient = (isCancelled || isRefunded) && i == 1
            ? const LinearGradient(
                colors: [AppColors.destructive, AppColors.destructive])
            : AppColors.successGradient;

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
                    gradient: s.done ? gradient : null,
                    color: s.done ? null : AppColors.muted,
                    border: s.active
                        ? Border.all(
                            color: color.withValues(alpha: 0.3), width: 4)
                        : null,
                    boxShadow: s.done
                        ? [
                            BoxShadow(
                                color: color.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2))
                          ]
                        : null,
                  ),
                  child: Icon(icons[i],
                      size: 14,
                      color: s.done ? Colors.white : AppColors.mutedForeground),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 40,
                    color:
                        s.done && steps[i + 1].done ? color : AppColors.border,
                  ),
              ],
            ),
            const SizedBox(width: AppSizes.p16),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : AppSizes.p12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: s.done
                            ? AppColors.secondary
                            : AppColors.mutedForeground,
                      ),
                    ),
                    if (s.time.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(s.time,
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.mutedForeground)),
                    ],
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
      margin: const EdgeInsets.fromLTRB(
          AppSizes.p12, 0, AppSizes.p12, AppSizes.p12),
      padding: const EdgeInsets.all(AppSizes.p16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.r16),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(title!, style: AppTextStyles.h3),
            const SizedBox(height: AppSizes.p12),
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
        Text(label,
            style: const TextStyle(
                fontSize: 12, color: AppColors.mutedForeground)),
        Text(value,
            style:
                TextStyle(fontSize: 12, color: color ?? AppColors.secondary)),
      ],
    );
  }
}
