import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/top_app_bar.dart';
import '../../../models/api_models.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/order_provider.dart';
import '../../chat/screens/chat_screen.dart';
import '../widgets/order_action_buttons.dart';
import '../widgets/order_detail_card.dart';
import '../widgets/order_product_list.dart';
import '../widgets/order_status_card.dart';
import '../widgets/order_timeline.dart';
import '../../payment/widgets/payment_summary_card.dart';
import '../widgets/shipping_address_card.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  String? _localError;

  int? get _parsedOrderId => int.tryParse(widget.orderId);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchOrder());
  }

  Future<void> _fetchOrder() async {
    final orderId = _parsedOrderId;
    if (orderId == null) {
      setState(() => _localError = 'Mã đơn hàng không hợp lệ.');
      return;
    }

    final token = context.read<AuthProvider>().accessToken;
    if (token == null || token.isEmpty) {
      setState(() => _localError = 'Vui lòng đăng nhập để xem đơn hàng.');
      return;
    }

    setState(() => _localError = null);
    await context.read<OrderProvider>().fetchOrderById(orderId, token);
  }

  Future<void> _cancelOrder(OrderResponse order) async {
    final token = context.read<AuthProvider>().accessToken;
    if (token == null || token.isEmpty) {
      _showMessage('Vui lòng đăng nhập để hủy đơn hàng.', isError: true);
      return;
    }

    final orderProvider = context.read<OrderProvider>();
    final success = await orderProvider.cancelOrder(order.orderId, token);
    if (!mounted) return;

    if (success) {
      _showMessage('Hủy đơn hàng thành công');
      await _fetchOrder();
      return;
    }

    _showMessage(
      orderProvider.error ?? 'Hủy đơn hàng thất bại',
      isError: true,
    );
  }

  void _showCancelDialog(OrderResponse order) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xác nhận hủy đơn'),
        content: const Text('Bạn có chắc chắn muốn hủy đơn hàng này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Đóng'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _cancelOrder(order);
            },
            child: const Text(
              'Hủy đơn',
              style: TextStyle(color: AppColors.destructive),
            ),
          ),
        ],
      ),
    );
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.destructive : null,
      ),
    );
  }

  void _openSupportChat(OrderResponse order) {
    final isShipped = order.orderStatus.toUpperCase() == 'SHIPPED';
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          attachOrderId: isShipped ? order.orderId : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();
    final parsedOrderId = _parsedOrderId;
    final currentOrder = orderProvider.currentOrder;
    final order =
        parsedOrderId != null && currentOrder?.orderId == parsedOrderId
            ? currentOrder
            : null;

    return Scaffold(
      appBar:
          ElectroAppBar(title: '${AppStrings.orderPrefix}${widget.orderId}'),
      body: _buildBody(orderProvider, order),
    );
  }

  Widget _buildBody(OrderProvider orderProvider, OrderResponse? order) {
    if (orderProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (order == null) {
      return _OrderDetailErrorView(
        message: _localError ??
            orderProvider.error ??
            'Không thể tải chi tiết đơn hàng',
        onRetry: _fetchOrder,
      );
    }

    final shippingInfo = _ShippingInfo.fromOrder(order);
    final shippingFee =
        order.finalAmount - order.totalAmount + order.discountAmount;
    final userRole = context.watch<AuthProvider>().role;
    final isShipped = order.orderStatus.toUpperCase() == 'SHIPPED';

    return SingleChildScrollView(
      child: Column(
        children: [
          OrderStatusCard(status: order.orderStatus),
          OrderDetailCard(
            title: AppStrings.orderTracking,
            child: OrderTimeline(order: order),
          ),
          OrderDetailCard(
            title: AppStrings.productsTitle,
            child: OrderProductList(items: order.orderItems),
          ),
          OrderDetailCard(
            child: ShippingAddressCard(
              recipientName: shippingInfo.name,
              recipientPhone: shippingInfo.phone,
              address: shippingInfo.address,
            ),
          ),
          OrderDetailCard(
            title: AppStrings.stepPayment,
            child: PaymentSummaryCard(
              order: order,
              shippingFee: shippingFee,
            ),
          ),
          OrderActionButtons(
            showContact: userRole != 'ADMIN',
            canCancel: order.orderStatus.toUpperCase() == 'PENDING',
            isCancelling: orderProvider.isCancelling,
            contactLabel:
                isShipped ? AppStrings.askAboutThisOrder : AppStrings.contact,
            onContact: () => _openSupportChat(order),
            onCancel: () => _showCancelDialog(order),
          ),
        ],
      ),
    );
  }
}

class _ShippingInfo {
  final String name;
  final String phone;
  final String address;

  const _ShippingInfo({
    required this.name,
    required this.phone,
    required this.address,
  });

  factory _ShippingInfo.fromOrder(OrderResponse order) {
    final shippingAddress = order.shippingAddress ?? '';
    final parts = shippingAddress.split(' | ');
    if (parts.length == 3) {
      return _ShippingInfo(
        name: parts[0],
        phone: parts[1],
        address: parts[2],
      );
    }

    return _ShippingInfo(
      name: '',
      phone: '',
      address: shippingAddress,
    );
  }
}

class _OrderDetailErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _OrderDetailErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.p24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.destructive,
            ),
            const SizedBox(height: AppSizes.p16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.secondary),
            ),
            const SizedBox(height: AppSizes.p12),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}
