import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/format_utils.dart';
import '../../../models/api_models.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/order_provider.dart';
import '../../order/widgets/order_status_utils.dart';

Future<int?> showShippedOrderPicker(BuildContext context) {
  return showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => const ShippedOrderPickerSheet(),
  );
}

/// Bottom sheet chỉ tải đơn SHIPPED từ API, không lọc từ danh sách cũ ở UI.
class ShippedOrderPickerSheet extends StatefulWidget {
  const ShippedOrderPickerSheet({super.key});

  @override
  State<ShippedOrderPickerSheet> createState() =>
      _ShippedOrderPickerSheetState();
}

class _ShippedOrderPickerSheetState extends State<ShippedOrderPickerSheet> {
  String? _localError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadOrders());
  }

  Future<void> _loadOrders() async {
    final authProvider = context.read<AuthProvider>();
    final token = authProvider.accessToken;
    final userId = authProvider.userId;
    if (token == null || userId == null) {
      setState(() => _localError = AppStrings.orderAttachmentLoadError);
      return;
    }

    setState(() => _localError = null);
    await context.read<OrderProvider>().fetchShippedOrders(token, userId);
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();

    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.65,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(
                AppSizes.p16,
                0,
                AppSizes.p16,
                AppSizes.p12,
              ),
              child: Text(
                AppStrings.shippedOrdersTitle,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.secondary,
                ),
              ),
            ),
            const Divider(height: 1, color: AppColors.border),
            Expanded(child: _buildBody(orderProvider)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(OrderProvider orderProvider) {
    if (orderProvider.isLoadingShippedOrders) {
      return const Center(child: CircularProgressIndicator());
    }

    final error = _localError ?? orderProvider.shippedOrdersError;
    if (error != null) {
      return _OrderPickerError(onRetry: _loadOrders);
    }

    final orders = orderProvider.shippedOrders;
    if (orders.isEmpty) {
      return const _EmptyShippedOrders();
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSizes.p12),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSizes.p8),
      itemBuilder: (context, index) {
        final order = orders[index];
        return _ShippedOrderItem(
          order: order,
          onTap: () => Navigator.pop(context, order.orderId),
        );
      },
    );
  }
}

class _ShippedOrderItem extends StatelessWidget {
  final OrderResponse order;
  final VoidCallback onTap;

  const _ShippedOrderItem({
    required this.order,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = orderStatusColor(order.orderStatus);

    return Material(
      color: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.r12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.r12),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.p12),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.local_shipping_outlined,
                  color: statusColor,
                  size: AppSizes.iconMd,
                ),
              ),
              const SizedBox(width: AppSizes.p12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${AppStrings.orderPrefix}${order.orderId}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.p4),
                    Text(
                      orderStatusLabel(order.orderStatus),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                formatVND(order.finalAmount.round()),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSizes.p4),
              const Icon(
                Icons.chevron_right,
                size: AppSizes.iconMd,
                color: AppColors.mutedForeground,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyShippedOrders extends StatelessWidget {
  const _EmptyShippedOrders();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(AppSizes.p24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.local_shipping_outlined,
              size: 52,
              color: AppColors.mutedForeground,
            ),
            SizedBox(height: AppSizes.p12),
            Text(
              AppStrings.noShippedOrders,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.secondary,
              ),
            ),
            SizedBox(height: AppSizes.p6),
            Text(
              AppStrings.noShippedOrdersSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderPickerError extends StatelessWidget {
  final VoidCallback onRetry;

  const _OrderPickerError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            AppStrings.orderAttachmentLoadError,
            style: TextStyle(color: AppColors.destructive),
          ),
          const SizedBox(height: AppSizes.p8),
          TextButton(
            onPressed: onRetry,
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }
}
