import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../services/deep_link_service.dart';
import '../../../services/payment_result_resolver.dart';
import '../widgets/vnpay_waiting_view.dart';
import '../widgets/vnpay_checking_view.dart';
import '../widgets/vnpay_error_view.dart';

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

class _VNPayPaymentScreenState extends State<VNPayPaymentScreen>
    with WidgetsBindingObserver {

  /// Trạng thái: 'waiting' | 'checking' | 'done' | 'error'
  String _phase = 'waiting';
  bool _browserOpened = false;
  String? _errorMessage;

  StreamSubscription<Uri>? _deepLinkSubscription;
  bool _resultHandled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Listen for deep links (warm start)
    _deepLinkSubscription = DeepLinkService.instance.linkStream.listen((Uri uri) {
      if (uri.scheme == 'electroshop' && uri.host == 'payment-result') {
        final orderIdStr = uri.queryParameters['orderId'];
        final statusStr = uri.queryParameters['status'];
        final txnRefStr = uri.queryParameters['txnRef'];

        if (orderIdStr != null) {
          final orderId = int.tryParse(orderIdStr);
          if (orderId == widget.order.orderId) {
            debugPrint('[VNPAY DeepLink] Handled deep link for order $orderId');
            _handleDeepLinkResult(statusStr, txnRefStr);
          }
        }
      }
    });

    // Tự động mở trình duyệt ngay khi vào màn hình
    WidgetsBinding.instance.addPostFrameCallback((_) => _launchBrowser());
  }

  @override
  void dispose() {
    _deepLinkSubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Được gọi mỗi khi vòng đời app thay đổi.
  /// Khi user quay lại app (resumed) sau khi đã mở browser → poll kết quả.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        _browserOpened &&
        _phase == 'waiting') {
      _checkPaymentResult();
    }
  }

  /// Mở trình duyệt hệ thống với paymentUrl của VNPay.
  Future<void> _launchBrowser() async {
    final uri = Uri.tryParse(widget.paymentUrl);
    if (uri == null) {
      _setError('Link thanh toán không hợp lệ.');
      return;
    }

    final canLaunch = await canLaunchUrl(uri);
    if (!canLaunch) {
      _setError(
        'Không thể mở trình duyệt để thanh toán.\n'
        'Vui lòng kiểm tra thiết bị có trình duyệt web không.',
      );
      return;
    }

    try {
      // Lưu orderId và token đang chờ thanh toán để hỗ trợ cold start
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('pending_payment_order_id', widget.order.orderId);
      await prefs.setString('pending_payment_token', widget.token);

      await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (mounted) {
        setState(() => _browserOpened = true);
      }
    } catch (e) {
      debugPrint('[VNPAY] launchUrl error: $e');
      _setError('Không thể mở trình duyệt: $e');
    }
  }

  Future<void> _handleDeepLinkResult(String? statusStr, String? txnRefStr) async {
    if (_resultHandled) return;
    _resultHandled = true;

    if (!mounted) return;
    setState(() => _phase = 'checking');

    final orderProvider = context.read<OrderProvider>();
    final resolution = await PaymentResultResolver.resolve(
      orderId: widget.order.orderId,
      token: widget.token,
      statusStr: statusStr,
      txnRefStr: txnRefStr,
      orderProvider: orderProvider,
      fallbackOrder: widget.order,
      paymentUrl: widget.paymentUrl,
    );

    if (!mounted) return;

    if (resolution != null) {
      _navigateToResult(
        resolution.order,
        isSuccess: resolution.isSuccess,
        syncWarning: resolution.syncWarning,
        result: resolution.result,
      );
    }
  }

  /// Polling: Gọi API lấy trạng thái đơn hàng sau khi user quay lại app.
  Future<void> _checkPaymentResult() async {
    if (_resultHandled) return;
    if (!mounted) return;
    setState(() => _phase = 'checking');

    OrderResponse? refreshedOrder;
    try {
      final orderProvider = context.read<OrderProvider>();
      refreshedOrder = await orderProvider.fetchOrderById(
        widget.order.orderId,
        widget.token,
      );
    } catch (e) {
      debugPrint('[VNPAY] Polling failed: $e');
      if (_resultHandled) return;
      _resultHandled = true;
      _navigateToResult(
        widget.order,
        syncWarning:
            'Không thể kiểm tra kết quả thanh toán tự động.\n'
            'Vui lòng kiểm tra lịch sử đơn hàng.',
      );
      return;
    }

    if (!mounted) return;
    if (_resultHandled) return;

    final order = refreshedOrder ?? widget.order;
    final paymentStatus = order.paymentStatus.toUpperCase();

    // Xác định kết quả dựa trên paymentStatus từ backend
    final isPaid = paymentStatus == 'PAID' || paymentStatus == 'COMPLETED';
    final isPending =
        paymentStatus == 'PENDING' || paymentStatus == 'PROCESSING';

    if (isPending) {
      // Thanh toán có thể chưa xong, cho user chờ thêm hoặc kiểm tra lại
      setState(() => _phase = 'waiting');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Thanh toán chưa hoàn tất. Vui lòng hoàn thành trong trình duyệt rồi quay lại.'),
            duration: Duration(seconds: 4),
          ),
        );
      }
      return;
    }

    _resultHandled = true;
    _navigateToResult(order, isSuccess: isPaid);
  }

  void _navigateToResult(
    OrderResponse order, {
    bool isSuccess = false,
    String? syncWarning,
    VNPayReturnParams? result,
  }) {
    if (!mounted) return;
    setState(() => _phase = 'done');

    // Tạo VNPayReturnParams tổng hợp từ thông tin order hoặc dùng kết quả truyền vào
    final finalResult = result ?? VNPayReturnParams(
      uri: Uri.parse(widget.paymentUrl),
      fullUrl: widget.paymentUrl,
      responseCode: isSuccess ? '00' : '99',
      transactionStatus: isSuccess ? '00' : '99',
      txnRef: widget.order.orderId.toString(),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => VNPayResultScreen(
          isSuccess: isSuccess,
          order: order,
          result: finalResult,
          syncWarning: syncWarning,
        ),
      ),
    );
  }

  void _setError(String message) {
    if (!mounted) return;
    setState(() {
      _phase = 'error';
      _errorMessage = message;
    });
  }

  Future<bool> _confirmExit() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Huỷ thanh toán VNPay?'),
        content: const Text(
            'Giao dịch có thể chưa hoàn tất. Bạn có muốn thoát màn hình thanh toán?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Tiếp tục'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Thoát'),
          ),
        ],
      ),
    );
    return shouldExit ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (_phase == 'done') return; // Đã xong, cho thoát
        final shouldExit = await _confirmExit();
        if (shouldExit && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: const ElectroAppBar(title: 'Thanh toán VNPay'),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    switch (_phase) {
      case 'error':
        return VNPayErrorView(
          message: _errorMessage ?? 'Đã xảy ra lỗi không xác định.',
          onRetry: _launchBrowser,
          onBack: () => Navigator.pop(context),
        );
      case 'checking':
        return const VNPayCheckingView();
      case 'done':
        return const VNPayCheckingView(); // Transitioning…
      default:
        // 'waiting' — đang chờ user thanh toán trong browser
        return VNPayWaitingView(
          browserOpened: _browserOpened,
          onOpenBrowser: _launchBrowser,
          onCheckResult: _checkPaymentResult,
        );
    }
  }
}