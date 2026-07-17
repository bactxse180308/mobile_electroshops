import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_button.dart';
import '../../../models/api_models.dart';
import '../../../services/vnpay_service.dart';
import '../../order/screens/order_detail_screen.dart';
import '../widgets/vnpay_result_header.dart';
import '../widgets/vnpay_result_row.dart';

class VNPayResultScreenArgs {
  final bool isSuccess;
  final OrderResponse order;
  final VNPayReturnParams result;
  final String? syncWarning;

  const VNPayResultScreenArgs({
    required this.isSuccess,
    required this.order,
    required this.result,
    this.syncWarning,
  });
}

class VNPayResultScreen extends StatelessWidget {
  final bool isSuccess;
  final OrderResponse order;
  final VNPayReturnParams result;
  final String? syncWarning;

  const VNPayResultScreen({
    super.key,
    required this.isSuccess,
    required this.order,
    required this.result,
    this.syncWarning,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.p24),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    VNPayResultHeader(
                      isSuccess: isSuccess,
                      order: order,
                      result: result,
                    ),
                    const SizedBox(height: AppSizes.p20),
                    if (syncWarning != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSizes.p12),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.12),
                          border: Border.all(color: AppColors.accent.withValues(alpha: 0.35)),
                          borderRadius: BorderRadius.circular(AppSizes.r12),
                        ),
                        child: Text(
                          syncWarning!,
                          style: const TextStyle(
                            color: AppColors.secondary,
                            fontSize: 13,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: AppSizes.p12),
                    ],
                    VNPayResultRow(label: 'Mã giao dịch', value: result.txnRef ?? '-'),
                    VNPayResultRow(label: 'Trạng thái đơn hàng', value: order.orderStatus),
                    VNPayResultRow(label: 'Trạng thái thanh toán', value: order.paymentStatus),
                  ],
                ),
              ),
              AppButton(
                label: 'Xem đơn hàng',
                variant: AppButtonVariant.gradient,
                size: AppButtonSize.lg,
                fullWidth: true,
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OrderDetailScreen(orderId: order.orderId.toString()),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.p12),
              AppButton(
                label: isSuccess ? 'Tiếp tục mua sắm' : 'Quay về giỏ hàng',
                variant: AppButtonVariant.secondary,
                size: AppButtonSize.lg,
                fullWidth: true,
                onPressed: () => Navigator.pushReplacementNamed(
                  context,
                  isSuccess ? AppRoutes.main : AppRoutes.mainCart,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
