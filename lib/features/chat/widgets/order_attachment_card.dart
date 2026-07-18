import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/format_utils.dart';
import '../../../models/chat_message.dart';
import '../../order/screens/order_detail_screen.dart';
import '../../order/widgets/order_status_utils.dart';

/// Card đơn hàng đính kèm. Dữ liệu hiển thị do backend resolve live.
class OrderAttachmentCard extends StatelessWidget {
  final ChatMessage message;

  const OrderAttachmentCard({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final orderId = message.orderId;
    final status = message.orderStatus;
    final statusLabel = status == null
        ? AppStrings.orderStatusUpdating
        : orderStatusLabel(status);
    final statusColor =
        status == null ? AppColors.mutedForeground : orderStatusColor(status);

    return GestureDetector(
      onTap: orderId == null
          ? null
          : () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OrderDetailScreen(orderId: '$orderId'),
                ),
              ),
      child: Container(
        width: 230,
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.local_shipping_outlined,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${AppStrings.orderPrefix}${orderId ?? ''}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.secondary,
                    ),
                  ),
                ),
                _OrderStatusBadge(
                  label: statusLabel,
                  color: statusColor,
                ),
              ],
            ),
            if (message.orderTotal != null) ...[
              const SizedBox(height: 8),
              _OrderInfoRow(
                label: AppStrings.orderTotalLabel,
                value: formatVND(message.orderTotal!.round()),
              ),
            ],
            if (message.orderDate != null) ...[
              const SizedBox(height: 4),
              _OrderInfoRow(
                label: AppStrings.orderPlacedDateLabel,
                value: _formatDate(message.orderDate!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }
}

class _OrderStatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _OrderStatusBadge({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _OrderInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _OrderInfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$label:',
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.mutedForeground,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.secondary,
            ),
          ),
        ),
      ],
    );
  }
}
