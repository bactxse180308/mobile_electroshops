import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/format_utils.dart';
import '../../../models/api_models.dart';
import '../../../widgets/common/summary_info_row.dart';

class PaymentSummaryCard extends StatelessWidget {
  final OrderResponse order;
  final double shippingFee;

  const PaymentSummaryCard({
    super.key,
    required this.order,
    required this.shippingFee,
  });

  @override
  Widget build(BuildContext context) {
    final voucherCode = order.voucherCode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${order.paymentMethod} (${order.paymentStatus})',
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.secondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (voucherCode != null && voucherCode.isNotEmpty) ...[
          const SizedBox(height: AppSizes.p4),
          Text(
            'Mã giảm giá/Ghi chú: $voucherCode',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.mutedForeground,
            ),
          ),
        ],
        const SizedBox(height: AppSizes.p12),
        const Divider(color: AppColors.border),
        const SizedBox(height: AppSizes.p8),
        SummaryInfoRow(
          label: AppStrings.subtotal,
          value: formatVND(order.totalAmount.round()),
          labelStyle: const TextStyle(
            fontSize: 12,
            color: AppColors.mutedForeground,
          ),
          valueStyle: const TextStyle(
            fontSize: 12,
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(height: AppSizes.p6),
        SummaryInfoRow(
          label: AppStrings.shipping,
          value: shippingFee == 0
              ? AppStrings.free
              : formatVND(shippingFee.round()),
          labelStyle: const TextStyle(
            fontSize: 12,
            color: AppColors.mutedForeground,
          ),
          valueStyle: const TextStyle(
            fontSize: 12,
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(height: AppSizes.p6),
        SummaryInfoRow(
          label: AppStrings.discount,
          value: '-${formatVND(order.discountAmount.round())}',
          labelStyle: const TextStyle(
            fontSize: 12,
            color: AppColors.mutedForeground,
          ),
          valueStyle: const TextStyle(
            fontSize: 12,
            color: AppColors.success,
          ),
        ),
        const Divider(color: AppColors.border, height: AppSizes.p16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(AppStrings.total, style: AppTextStyles.h3),
            Text(
              formatVND(order.finalAmount.round()),
              style: const TextStyle(
                fontSize: 18,
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
