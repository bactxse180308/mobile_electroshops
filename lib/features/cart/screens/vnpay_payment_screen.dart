import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/top_app_bar.dart';
import '../../../models/api_models.dart';
import '../../../providers/order_provider.dart';
import '../../../services/vnpay_service.dart';
import 'vnpay_result_screen.dart';

class VNPayPaymentScreenArgs {
  final OrderResponse order;
  final String paymentUrl;
  final String token;

  const VNPayPaymentScreenArgs({
    required this.order,
    required this.paymentUrl,
    required this.token,
  });
}

class VNPayPaymentScreen extends StatefulWidget {
  final OrderResponse order;
  final String paymentUrl;
  final String token;

  const VNPayPaymentScreen({
    super.key,
    required this.order,
    required this.paymentUrl,
    required this.token,
  });

  @override
  State<VNPayPaymentScreen> createState() => _VNPayPaymentScreenState();
}

class _VNPayPaymentScreenState extends State<VNPayPaymentScreen> {
  final VNPayService _vnPayService = VNPayService();
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _handledReturn = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            if (mounted) setState(() => _isLoading = true);
            _handleNavigation(url);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
          onNavigationRequest: (request) {
            final handled = _handleNavigation(request.url);
            return handled ? NavigationDecision.prevent : NavigationDecision.navigate;
          },
          onWebResourceError: (error) {
            debugPrint('[VNPAY] WebView error: ${error.errorCode} ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  bool _handleNavigation(String url) {
    if (_handledReturn) return true;

    final result = _vnPayService.parseReturnUrl(url);
    if (result == null) return false;

    _handledReturn = true;
    _finishPayment(result);
    return true;
  }

  Future<void> _finishPayment(VNPayReturnParams result) async {
    OrderResponse? refreshedOrder;
    String? syncWarning;

    try {
      await _vnPayService.confirmReturn(
        result.fullUrl,
        widget.token,
      );
    } catch (e) {
      syncWarning = 'Thanh toan da hoan tat nhung dong bo trang thai don hang that bai. Vui long tai lai don hang.';
      debugPrint('[VNPAY] Backend return synchronization failed: $e');
    }

    try {
      refreshedOrder = await context.read<OrderProvider>().fetchOrderById(
            widget.order.orderId,
            widget.token,
          );
    } catch (e) {
      debugPrint('[VNPAY] Failed to refresh order after return: $e');
    }

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => VNPayResultScreen(
          isSuccess: result.isSuccess,
          order: refreshedOrder ?? widget.order,
          result: result,
          syncWarning: syncWarning,
        ),
      ),
    );
  }

  Future<bool> _confirmExit() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Huy thanh toan VNPay?'),
        content: const Text('Giao dich chua hoan tat. Ban co muon thoat man hinh thanh toan?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Tiep tuc'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Thoat'),
          ),
        ],
      ),
    );
    return shouldExit ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _confirmExit,
      child: Scaffold(
        appBar: const ElectroAppBar(title: 'Thanh toan VNPay'),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading)
              const LinearProgressIndicator(
                minHeight: 3,
                color: AppColors.primary,
                backgroundColor: AppColors.border,
              ),
          ],
        ),
      ),
    );
  }
}
