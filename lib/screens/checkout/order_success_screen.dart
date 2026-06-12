import 'package:flutter/material.dart';
import '../../models/api_models.dart';
import '../../theme/app_theme.dart';
import '../../utils/format_utils.dart';
import '../../widgets/app_button.dart';
import '../orders/order_detail_screen.dart';

class OrderSuccessScreen extends StatefulWidget {
  final OrderResponse? order;

  const OrderSuccessScreen({super.key, this.order});

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _scale = Tween<double>(begin: 0.5, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _fade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  OrderResponse? get _order {
    if (widget.order != null) return widget.order;
    final args = ModalRoute.of(context)?.settings.arguments;
    return args is OrderResponse ? args : null;
  }

  int? get _orderId {
    final order = _order;
    if (order != null) return order.orderId;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is int) return args;
    return int.tryParse(args.toString());
  }

  @override
  Widget build(BuildContext context) {
    final order = _order;
    final orderId = _orderId;
    final total = order != null ? formatVND(order.finalAmount.round()) : '—';

    return Scaffold(
      body: Stack(
        children: [
          ...List.generate(12, (i) {
            final colors = [AppColors.primary, AppColors.accent, AppColors.success, AppColors.destructive, const Color(0xFFA78BFA)];
            return Positioned(
              top: 60.0 + (i * 40) % 300,
              left: (i * 73) % MediaQuery.of(context).size.width,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: colors[i % colors.length].withOpacity(0.6),
                  shape: i % 2 == 0 ? BoxShape.circle : BoxShape.rectangle,
                  borderRadius: i % 2 != 0 ? BorderRadius.circular(2) : null,
                ),
              ),
            );
          }),
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 80),
                      ScaleTransition(
                        scale: _scale,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 112,
                              height: 112,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.success.withOpacity(0.15),
                              ),
                            ),
                            Container(
                              width: 80,
                              height: 80,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: AppColors.successGradient,
                                boxShadow: [BoxShadow(color: Color(0x4010B981), blurRadius: 20, offset: Offset(0, 8))],
                              ),
                              child: const Icon(Icons.check, size: 40, color: Colors.white),
                            ),
                            const Positioned(
                              top: 0,
                              right: 0,
                              child: Icon(Icons.auto_awesome, size: 20, color: AppColors.accent),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      FadeTransition(
                        opacity: _fade,
                        child: const Text('Đặt hàng thành công!', style: AppTextStyles.h1),
                      ),
                      const SizedBox(height: 8),
                      FadeTransition(
                        opacity: _fade,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            'Cảm ơn bạn đã mua sắm tại ElectroShop. Chúng tôi sẽ xử lý đơn hàng trong thời gian sớm nhất.',
                            style: TextStyle(fontSize: 14, color: AppColors.mutedForeground, height: 1.5),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      FadeTransition(
                        opacity: _fade,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.primary.withOpacity(0.4)),
                            color: AppColors.primary.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              const Text('Mã đơn hàng', style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                              const SizedBox(height: 4),
                              Text(
                                orderId != null ? '#$orderId' : '—',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary, letterSpacing: 2, fontFamily: 'monospace'),
                              ),
                              if (order != null) ...[
                                const SizedBox(height: 8),
                                Text('Tổng: $total', style: const TextStyle(fontSize: 13, color: AppColors.secondary)),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (order?.paymentMethod == 'BANK_TRANSFER')
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            border: Border.all(color: AppColors.border),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Thông tin chuyển khoản', style: AppTextStyles.h3),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Ngân hàng', style: TextStyle(color: AppColors.mutedForeground, fontSize: 13)),
                                  const Text('Vietcombank', style: TextStyle(color: AppColors.secondary, fontSize: 13, fontWeight: FontWeight.w600)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Số tài khoản', style: TextStyle(color: AppColors.mutedForeground, fontSize: 13)),
                                  const Text('1234567890', style: TextStyle(color: AppColors.secondary, fontSize: 13, fontWeight: FontWeight.w600)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Chủ tài khoản', style: TextStyle(color: AppColors.mutedForeground, fontSize: 13)),
                                  const Text('CONG TY ELECTROSHOP', style: TextStyle(color: AppColors.secondary, fontSize: 13, fontWeight: FontWeight.w600)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Nội dung CK', style: TextStyle(color: AppColors.mutedForeground, fontSize: 13)),
                                  Text('ELECTROSHOP #$orderId', style: const TextStyle(color: AppColors.secondary, fontSize: 13, fontWeight: FontWeight.w600)),
                                ],
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Đơn hàng sẽ được xác nhận sau khi nhận được thanh toán',
                                style: TextStyle(color: AppColors.mutedForeground, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(24, 0, 24, 32 + MediaQuery.of(context).padding.bottom),
                child: Column(
                  children: [
                    AppButton(
                      label: 'Xem đơn hàng',
                      variant: AppButtonVariant.gradient,
                      size: AppButtonSize.lg,
                      fullWidth: true,
                      onPressed: orderId != null
                          ? () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => OrderDetailScreen(orderId: orderId)),
                              )
                          : null,
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      label: 'Tiếp tục mua sắm',
                      variant: AppButtonVariant.secondary,
                      size: AppButtonSize.lg,
                      fullWidth: true,
                      onPressed: () => Navigator.pushReplacementNamed(context, '/main'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
