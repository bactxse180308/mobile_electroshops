import 'package:flutter/foundation.dart';
import '../services/vnpay_service.dart';

class PaymentProvider extends ChangeNotifier {
  final VNPayService _vnPayService = VNPayService();

  bool isLoading = false;
  String? error;
  String? paymentUrl;

  Future<String?> createVNPayUrl(int orderId) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      paymentUrl = await _vnPayService.createPaymentUrl(orderId);
      return paymentUrl;
    } catch (e) {
      error = e.toString();
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    paymentUrl = null;
    error = null;
    isLoading = false;
    notifyListeners();
  }
}
