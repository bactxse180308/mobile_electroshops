import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/api_models.dart';
import '../../../services/vnpay_service.dart';

class VNPayResultHeader extends StatelessWidget {
  final bool isSuccess;
  final OrderResponse order;
  final VNPayReturnParams result;

  const VNPayResultHeader({
    super.key,
    required this.isSuccess,
    required this.order,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSuccess ? AppColors.success : AppColors.destructive;
    final icon = isSuccess ? Icons.check_circle : Icons.cancel;
    final title = isSuccess ? 'Thanh toán thành công' : 'Thanh toán thất bại';
    final message = isSuccess
        ? 'Đơn hàng #${order.orderId} đã được ghi nhận thanh toán thành công.'
        : (order.paymentStatus.toUpperCase() == 'PENDING' ||
                order.paymentStatus.toUpperCase() == 'PROCESSING')
            ? 'Giao dịch chưa hoàn tất. Vui lòng kiểm tra lại hoặc thử thanh toán lần nữa.'
            : 'Thanh toán không thành công (mã: ${result.responseCode ?? "không xác định"}). Vui lòng thử lại.';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 92),
        const SizedBox(height: AppSizes.p24),
        Text(title, style: AppTextStyles.h1, textAlign: TextAlign.center),
        const SizedBox(height: AppSizes.p12),
        Text(
          message,
          style: const TextStyle(
            color: AppColors.mutedForeground,
            fontSize: 14,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
