import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../../../models/api_models.dart';
import '../../../services/vnpay_service.dart';
import '../../order/screens/order_detail_screen.dart';

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
    final color = isSuccess ? AppColors.success : AppColors.destructive;
    final icon = isSuccess ? Icons.check_circle : Icons.cancel;
    final title = isSuccess ? 'Thanh toan thanh cong' : 'Thanh toan that bai';
    final message = isSuccess
        ? 'Don hang #${order.orderId} da duoc ghi nhan thanh toan.'
        : 'VNPay tra ve ma loi ${result.responseCode ?? 'khong xac dinh'}. Vui long thu lai.';

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
                    _ResultRow(label: 'Ma giao dich', value: result.txnRef ?? '-'),
                    _ResultRow(label: 'Trang thai don', value: order.orderStatus),
                    _ResultRow(label: 'Trang thai thanh toan', value: order.paymentStatus),
                  ],
                ),
              ),
              AppButton(
                label: 'Xem don hang',
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
                label: isSuccess ? 'Tiep tuc mua sam' : 'Quay ve gio hang',
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

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;

  const _ResultRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.p8),
      padding: const EdgeInsets.all(AppSizes.p12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppSizes.r12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppColors.mutedForeground, fontSize: 13),
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w600),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
