import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../models/api_models.dart';

class OrderTimeline extends StatelessWidget {
  final OrderResponse order;

  const OrderTimeline({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    final status = order.orderStatus.toUpperCase();
    final isCancelled = status == 'CANCELLED';
    final isRefunded = status == 'REFUNDED';
    final steps = isCancelled || isRefunded
        ? _cancelledSteps(isRefunded)
        : _normalSteps(status);
    final icons = isCancelled || isRefunded
        ? [Icons.shopping_bag_outlined, Icons.cancel_outlined]
        : [
            Icons.shopping_bag_outlined,
            Icons.check_circle_outline,
            Icons.inventory_2_outlined,
            Icons.local_shipping_outlined,
            Icons.home_outlined,
          ];

    return Column(
      children: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        final isLast = index == steps.length - 1;
        final alertStep = (isCancelled || isRefunded) && index == 1;
        final color = alertStep ? AppColors.destructive : AppColors.success;
        final gradient = alertStep
            ? const LinearGradient(
                colors: [AppColors.destructive, AppColors.destructive],
              )
            : AppColors.successGradient;

        return _TimelineStepRow(
          step: step,
          icon: icons[index],
          isLast: isLast,
          color: color,
          gradient: gradient,
          nextDone: !isLast && steps[index + 1].done,
        );
      }).toList(),
    );
  }

  List<_TimelineStep> _cancelledSteps(bool isRefunded) {
    return [
      _TimelineStep(
        label: 'Đặt hàng thành công',
        time: _formatDate(order.orderDate),
        done: true,
        active: false,
      ),
      _TimelineStep(
        label: isRefunded ? 'Đã hoàn tiền' : 'Đã hủy đơn hàng',
        time: _formatDate(order.updatedAt),
        done: true,
        active: true,
      ),
    ];
  }

  List<_TimelineStep> _normalSteps(String status) {
    final isPending = status == 'PENDING';
    final isConfirmed = status == 'CONFIRMED';
    final isProcessing = status == 'PROCESSING';
    final isShipped = status == 'SHIPPED';
    final isDelivered = status == 'DELIVERED';

    return [
      _TimelineStep(
        label: AppStrings.placeOrder,
        time: _formatDate(order.orderDate),
        done: true,
        active: isPending,
      ),
      _TimelineStep(
        label: AppStrings.orderConfirmed,
        time: (isConfirmed || isProcessing || isShipped || isDelivered)
            ? 'Đã xác nhận'
            : '',
        done: isConfirmed || isProcessing || isShipped || isDelivered,
        active: isConfirmed,
      ),
      _TimelineStep(
        label: 'Đang chuẩn bị hàng',
        time: (isProcessing || isShipped || isDelivered) ? 'Đang đóng gói' : '',
        done: isProcessing || isShipped || isDelivered,
        active: isProcessing,
      ),
      _TimelineStep(
        label: AppStrings.orderShipping,
        time: (isShipped || isDelivered) ? 'Đang vận chuyển' : '',
        done: isShipped || isDelivered,
        active: isShipped,
      ),
      _TimelineStep(
        label: AppStrings.orderDelivered,
        time: isDelivered ? 'Đã giao hàng thành công' : AppStrings.estDelivery,
        done: isDelivered,
        active: isDelivered,
      ),
    ];
  }

  String _formatDate(String? value) {
    if (value == null || value.isEmpty) return '';
    final normalized = value.replaceAll('T', ' ');
    if (normalized.length <= 16) return normalized;
    return normalized.substring(0, 16);
  }
}

class _TimelineStepRow extends StatelessWidget {
  final _TimelineStep step;
  final IconData icon;
  final bool isLast;
  final bool nextDone;
  final Color color;
  final Gradient gradient;

  const _TimelineStepRow({
    required this.step,
    required this.icon,
    required this.isLast,
    required this.nextDone,
    required this.color,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
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
                gradient: step.done ? gradient : null,
                color: step.done ? null : AppColors.muted,
                border: step.active
                    ? Border.all(
                        color: color.withValues(alpha: 0.3),
                        width: 4,
                      )
                    : null,
                boxShadow: step.done
                    ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                icon,
                size: 14,
                color: step.done ? Colors.white : AppColors.mutedForeground,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: step.done && nextDone ? color : AppColors.border,
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
                  step.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: step.done
                        ? AppColors.secondary
                        : AppColors.mutedForeground,
                  ),
                ),
                if (step.time.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    step.time,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.mutedForeground,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TimelineStep {
  final String label;
  final String time;
  final bool done;
  final bool active;

  const _TimelineStep({
    required this.label,
    required this.time,
    required this.done,
    required this.active,
  });
}
