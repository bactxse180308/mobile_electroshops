import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/format_utils.dart';
import '../../../models/api_models.dart';
import 'order_status_utils.dart';

class OrderHistoryCard extends StatelessWidget {
  final OrderResponse order;
  final VoidCallback onTap;

  const OrderHistoryCard({
    super.key,
    required this.order,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final totalQuantity =
        order.orderItems.fold(0, (sum, item) => sum + item.quantity);
    final firstItem =
        order.orderItems.isNotEmpty ? order.orderItems.first : null;
    final statusColor = orderStatusColor(order.orderStatus);

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
                _OrderHeader(order: order, statusColor: statusColor),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSizes.p10),
                  child: Divider(color: AppColors.border, height: 1),
                ),
                if (firstItem != null) ...[
                  _FirstOrderItem(item: firstItem),
                  if (order.orderItems.length > 1) ...[
                    const SizedBox(height: AppSizes.p8),
                    Center(
                      child: Text(
                        'Xem thêm ${order.orderItems.length - 1} sản phẩm',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.mutedForeground,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSizes.p10),
                    child: Divider(color: AppColors.border, height: 1),
                  ),
                ],
                _OrderTotalRow(order: order, totalQuantity: totalQuantity),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OrderHeader extends StatelessWidget {
  final OrderResponse order;
  final Color statusColor;

  const _OrderHeader({
    required this.order,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${AppStrings.orderPrefix}${order.orderId}',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.secondary,
            fontSize: 14,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.p10,
            vertical: AppSizes.p4,
          ),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSizes.r20),
            border: Border.all(color: statusColor.withValues(alpha: 0.3)),
          ),
          child: Text(
            orderStatusLabel(order.orderStatus),
            style: TextStyle(
              color: statusColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _FirstOrderItem extends StatelessWidget {
  final ApiOrderItemResponse item;

  const _FirstOrderItem({required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ItemImage(imageUrl: item.productImage),
        const SizedBox(width: AppSizes.p12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.productName,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSizes.p4),
              Text(
                'Số lượng: ${item.quantity}',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.mutedForeground,
                ),
              ),
            ],
          ),
        ),
        Text(
          formatVND(item.subtotal.round()),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.secondary,
          ),
        ),
      ],
    );
  }
}

class _ItemImage extends StatelessWidget {
  final String? imageUrl;

  const _ItemImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.r8),
      child: url != null && url.isNotEmpty
          ? Image.network(
              url,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const _ImageFallback(),
            )
          : const _ImageFallback(),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(width: 56, height: 56, color: AppColors.muted);
  }
}

class _OrderTotalRow extends StatelessWidget {
  final OrderResponse order;
  final int totalQuantity;

  const _OrderTotalRow({
    required this.order,
    required this.totalQuantity,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$totalQuantity sản phẩm',
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.mutedForeground,
          ),
        ),
        Row(
          children: [
            const Text(
              'Tổng tiền: ',
              style: TextStyle(fontSize: 12, color: AppColors.secondary),
            ),
            Text(
              formatVND(order.finalAmount.round()),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
