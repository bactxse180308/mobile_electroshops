import 'package:flutter/foundation.dart';

import '../models/api_models.dart';
import '../providers/order_provider.dart';
import '../services/vnpay_service.dart';

class PaymentResolutionResult {
  final OrderResponse order;
  final bool isSuccess;
  final VNPayReturnParams result;
  final String? syncWarning;

  PaymentResolutionResult({
    required this.order,
    required this.isSuccess,
    required this.result,
    this.syncWarning,
  });
}

class PaymentResultResolver {
  static Future<PaymentResolutionResult?> resolve({
    required int orderId,
    required String token,
    required String? statusStr,
    required String? txnRefStr,
    required OrderProvider orderProvider,
    required OrderResponse? fallbackOrder,
    String paymentUrl = 'electroshop://payment-result',
  }) async {
    OrderResponse? refreshedOrder;
    String? syncWarning;

    try {
      refreshedOrder = await orderProvider.fetchOrderById(orderId, token);
    } catch (e) {
      debugPrint('[PaymentResultResolver] Fetch order failed: $e');
      syncWarning = 'Không thể đồng bộ trạng thái đơn hàng tự động.';
    }

    final order = refreshedOrder ?? fallbackOrder;
    if (order == null) {
      return null;
    }

    final isSuccess = statusStr == 'SUCCESS' ||
        order.paymentStatus.toUpperCase() == 'PAID' ||
        order.paymentStatus.toUpperCase() == 'COMPLETED';

    final syntheticResult = VNPayReturnParams(
      uri: Uri.parse(paymentUrl),
      fullUrl: paymentUrl,
      responseCode: isSuccess ? '00' : '99',
      transactionStatus: isSuccess ? '00' : '99',
      txnRef: txnRefStr ?? orderId.toString(),
    );

    return PaymentResolutionResult(
      order: order,
      isSuccess: isSuccess,
      result: syntheticResult,
      syncWarning: syncWarning,
    );
  }
}
