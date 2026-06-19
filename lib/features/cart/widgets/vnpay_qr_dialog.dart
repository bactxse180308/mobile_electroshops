import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../screens/order_success_screen.dart';
import '../../../models/api_models.dart';

class VNPayQRDialog extends StatelessWidget {
  final String paymentUrl;
  final OrderResponse order;

  const VNPayQRDialog({
    super.key,
    required this.paymentUrl,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Thanh toán VNPay'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 240,
            height: 240,
            child: QrImageView(
              data: paymentUrl,
              size: 240,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Quét mã QR bằng app ngân hàng hoặc VNPay để thanh toán',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.mutedForeground),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => OrderSuccessScreen(order: order),
              ),
            );
          },
          child: const Text('Đã thanh toán'),
        ),
      ],
    );
  }
}
