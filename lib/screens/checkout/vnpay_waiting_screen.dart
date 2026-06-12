import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/api_models.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_button.dart';
import '../../widgets/top_app_bar.dart';
import 'order_failed_screen.dart';
import 'order_success_screen.dart';

class VnpayWaitingScreen extends StatefulWidget {
  final int orderId;

  const VnpayWaitingScreen({super.key, required this.orderId});

  @override
  State<VnpayWaitingScreen> createState() => _VnpayWaitingScreenState();
}

class _VnpayWaitingScreenState extends State<VnpayWaitingScreen> {
  static const _pollInterval = Duration(seconds: 3);
  static const _timeout = Duration(minutes: 2);

  final _api = ApiService();
  Timer? _timer;
  DateTime? _startedAt;
  bool _isChecking = false;
  bool _isPolling = true;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _startedAt = DateTime.now();
    _checkPaymentStatus(showPendingMessage: false);
    _timer = Timer.periodic(_pollInterval, (_) {
      _checkPaymentStatus(showPendingMessage: false);
    });
  }

  void _stopPolling() {
    _timer?.cancel();
    _timer = null;
    _isPolling = false;
  }

  Future<void> _checkPaymentStatus({required bool showPendingMessage}) async {
    if (_isChecking || !_isPolling) return;

    final startedAt = _startedAt;
    if (startedAt != null && DateTime.now().difference(startedAt) >= _timeout) {
      _stopPolling();
      if (!mounted) return;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hết thời gian chờ xác nhận thanh toán'),
          backgroundColor: AppColors.destructive,
        ),
      );
      return;
    }

    final token = context.read<AuthProvider>().accessToken;
    if (token == null) {
      _stopPolling();
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    setState(() => _isChecking = true);
    try {
      final order = await _api.getOrderById(widget.orderId, token);
      if (!mounted) return;

      final paymentStatus = order.paymentStatus.toUpperCase();
      if (paymentStatus == 'SUCCESS') {
        _stopPolling();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => OrderSuccessScreen(order: order)),
        );
        return;
      }

      if (paymentStatus == 'FAILED' || paymentStatus == 'CANCELLED') {
        _stopPolling();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => OrderFailedScreen(
              orderId: order.orderId,
              paymentStatus: paymentStatus,
            ),
          ),
        );
        return;
      }

      if (showPendingMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chưa nhận được thanh toán, vui lòng thử lại'),
            backgroundColor: AppColors.destructive,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e is ApiException ? e.message : e.toString()),
          backgroundColor: AppColors.destructive,
        ),
      );
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  void _cancel() {
    _stopPolling();
    Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final title = _isPolling
        ? 'Đang chờ xác nhận thanh toán...'
        : 'Chưa nhận được xác nhận thanh toán';

    return Scaffold(
      appBar: const ElectroAppBar(title: 'Thanh toán VNPay'),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isPolling)
              const CircularProgressIndicator(color: AppColors.primary)
            else
              const Icon(Icons.schedule, size: 48, color: AppColors.mutedForeground),
            const SizedBox(height: 24),
            Text(
              title,
              style: AppTextStyles.h2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Mã đơn hàng #${widget.orderId}',
              style: const TextStyle(fontSize: 13, color: AppColors.mutedForeground),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            AppButton(
              label: _isChecking ? 'Đang kiểm tra...' : 'Tôi đã thanh toán xong',
              variant: AppButtonVariant.gradient,
              size: AppButtonSize.lg,
              fullWidth: true,
              disabled: _isChecking || !_isPolling,
              onPressed: () => _checkPaymentStatus(showPendingMessage: true),
            ),
            const SizedBox(height: 12),
            AppButton(
              label: 'Hủy',
              variant: AppButtonVariant.secondary,
              size: AppButtonSize.lg,
              fullWidth: true,
              disabled: _isChecking,
              onPressed: _cancel,
            ),
          ],
        ),
      ),
    );
  }
}
