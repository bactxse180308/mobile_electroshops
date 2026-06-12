import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';
import '../../models/api_models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../services/api_service.dart';
import '../../utils/format_utils.dart';
import '../../widgets/app_button.dart';
import '../../widgets/top_app_bar.dart';
import 'vnpay_waiting_screen.dart';

const _shippingFee = 30000;

const _methods = [
  (id: 'COD', label: 'Thanh toán khi nhận hàng', sub: 'Kiểm tra hàng trước khi thanh toán', emoji: '💵'),
  (id: 'VNPAY', label: 'Thanh toán qua VNPay', sub: 'Quét QR thanh toán nhanh', emoji: '🟦'),
];

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _api = ApiService();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  final _voucherCtrl = TextEditingController();

  String _paymentMethod = 'COD';
  bool _isSubmitting = false;
  bool _isValidatingVoucher = false;
  Map<String, dynamic>? _voucher;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _nameCtrl.text = context.read<AuthProvider>().fullName ?? '';
    });
  }

  int _subtotal(CartProvider cart) {
    return cart.selectedSubtotal.round();
  }

  int _discount(int subtotal) {
    if (_voucher == null) return 0;
    final type = _voucher!['discountType'];
    final value = (_voucher!['discountValue'] as num).toDouble();
    final maxDiscount =
        (_voucher!['maxDiscount'] as num?)?.toDouble() ?? double.infinity;
    if (type == 'PERCENT') {
      final discount = (subtotal * value / 100).round();
      return maxDiscount.isFinite ? min(discount, maxDiscount.round()) : discount;
    }
    if (type == 'FIXED') return value.round();
    return 0;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _noteCtrl.dispose();
    _voucherCtrl.dispose();
    super.dispose();
  }

  Future<void> _validateVoucher() async {
    final code = _voucherCtrl.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập mã giảm giá'), backgroundColor: AppColors.destructive),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final token = auth.accessToken;
    final userId = auth.userId;
    if (!auth.isAuthenticated || token == null || userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đăng nhập để tiếp tục'),
          backgroundColor: AppColors.destructive,
        ),
      );
      return;
    }

    final subtotal = _subtotal(context.read<CartProvider>());
    setState(() => _isValidatingVoucher = true);
    try {
      final result = await _api.getVoucherDetails(
        code,
        userId,
        subtotal.toDouble(),
        token,
      );
      if (!mounted) return;
      setState(() => _voucher = result);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Áp dụng mã giảm giá thành công'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e is ApiException ? e.message : e.toString()),
          backgroundColor: AppColors.destructive,
        ),
      );
    } finally {
      if (mounted) setState(() => _isValidatingVoucher = false);
    }
  }

  String? _validateForm() {
    if (_nameCtrl.text.trim().isEmpty) return 'Vui lòng nhập họ tên người nhận';
    if (_phoneCtrl.text.trim().isEmpty) return 'Vui lòng nhập số điện thoại';
    if (_addressCtrl.text.trim().isEmpty) return 'Vui lòng nhập địa chỉ giao hàng';
    return null;
  }

  Future<void> _placeOrder() async {
    final auth = context.read<AuthProvider>();
    final token = auth.accessToken;
    final userId = auth.userId;
    if (!auth.isAuthenticated || token == null || userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đăng nhập để tiếp tục'),
          backgroundColor: AppColors.destructive,
        ),
      );
      return;
    }

    final formError = _validateForm();
    if (formError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(formError), backgroundColor: AppColors.destructive),
      );
      return;
    }

    final cart = context.read<CartProvider>();
    final selected = cart.selectedItems;
    if (selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không có sản phẩm được chọn'), backgroundColor: AppColors.destructive),
      );
      return;
    }

    final items = <OrderItemRequest>[];
    for (final item in selected) {
      if (item.productId == 0) continue;
      items.add(OrderItemRequest(productId: item.productId, quantity: item.quantity));
    }
    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể xác định sản phẩm đặt hàng'), backgroundColor: AppColors.destructive),
      );
      return;
    }

    final request = CreateOrderRequest(
      recipientName: _nameCtrl.text.trim(),
      recipientPhone: _phoneCtrl.text.trim(),
      shippingAddress: '${_nameCtrl.text.trim()} | ${_phoneCtrl.text.trim()} | ${_addressCtrl.text.trim()}',
      note: _noteCtrl.text.trim(),
      paymentMethod: _paymentMethod,
      voucherCode: _voucher != null ? _voucherCtrl.text.trim() : null,
      items: items,
    );

    setState(() => _isSubmitting = true);
    final order = await context.read<OrderProvider>().createOrder(
          request,
          token,
          userId,
        );
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (order == null) {
      final err = context.read<OrderProvider>().error ?? 'Đặt hàng thất bại';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err), backgroundColor: AppColors.destructive),
      );
      return;
    }

    cart.removeSelected();

    if (_paymentMethod == 'VNPAY') {
      try {
        final payment = await _api.createVnpayPayment(
          order.orderId,
          order.finalAmount,
          'Thanh toán đơn hàng ${order.orderCode}',
          token,
        );
        if (payment.paymentUrl.isNotEmpty) {
          final uri = Uri.parse(payment.paymentUrl);
          if (await canLaunchUrl(uri)) {
            final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
            if (launched && mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => VnpayWaitingScreen(orderId: order.orderId),
                ),
              );
            } else if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Không thể mở VNPay'),
                  backgroundColor: AppColors.destructive,
                ),
              );
            }
          } else if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Không thể mở VNPay'),
                backgroundColor: AppColors.destructive,
              ),
            );
          }
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Không thể mở VNPay'),
              backgroundColor: AppColors.destructive,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e is ApiException ? e.message : 'Không thể mở VNPay'),
              backgroundColor: AppColors.destructive,
            ),
          );
        }
      }
      return;
    }

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/order-success', arguments: order);
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final items = cart.selectedItems;
    final subtotal = _subtotal(cart);
    final discount = _discount(subtotal);
    final total = subtotal + _shippingFee - discount;

    return Scaffold(
      appBar: const ElectroAppBar(title: 'Thanh toán'),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
            decoration: const BoxDecoration(
              color: AppColors.background,
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: ['Địa chỉ', 'Thanh toán', 'Xác nhận'].asMap().entries.map((e) {
                final i = e.key;
                final label = e.value;
                final done = i < 2;
                final active = i == 2;
                return Expanded(
                  child: Row(
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: done ? AppColors.successGradient : null,
                              color: active ? AppColors.primary : (done ? null : AppColors.muted),
                            ),
                            child: Center(
                              child: done
                                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                                  : Text(
                                      '${i + 1}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: active ? Colors.white : AppColors.mutedForeground,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: done || active ? AppColors.secondary : AppColors.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                      if (i < 2)
                        Expanded(
                          child: Container(
                            height: 2,
                            margin: const EdgeInsets.only(bottom: 16),
                            color: done ? AppColors.success : AppColors.border,
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _Section(
                    title: 'Thông tin giao hàng',
                    child: Column(
                      children: [
                        _InputField(controller: _nameCtrl, hint: 'Họ tên người nhận'),
                        const SizedBox(height: 10),
                        _InputField(controller: _phoneCtrl, hint: 'Số điện thoại', keyboard: TextInputType.phone),
                        const SizedBox(height: 10),
                        _InputField(controller: _addressCtrl, hint: 'Nhập địa chỉ giao hàng'),
                      ],
                    ),
                  ),
                  _Section(
                    title: 'Sản phẩm (${items.length})',
                    child: Column(
                      children: items.map((item) {
                        final image = item.mainImage ?? 'https://picsum.photos/seed/${item.productId}_cover/600/600';
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  image,
                                  width: 56,
                                  height: 56,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(width: 56, height: 56, color: AppColors.muted),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.productName,
                                      style: const TextStyle(fontSize: 12, color: AppColors.secondary),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('x${item.quantity}', style: const TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                                        Text(formatVND(item.subtotal.round()), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  _Section(
                    title: 'Mã giảm giá',
                    child: Row(
                      children: [
                        const Icon(Icons.local_offer_outlined, size: 20, color: AppColors.accent),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _voucherCtrl,
                            decoration: const InputDecoration(
                              hintText: 'Nhập mã giảm giá',
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        AppButton(
                          label: _isValidatingVoucher ? '...' : 'Áp dụng',
                          size: AppButtonSize.sm,
                          disabled: _isValidatingVoucher,
                          onPressed: _validateVoucher,
                        ),
                      ],
                    ),
                  ),
                  _Section(
                    title: 'Phương thức thanh toán',
                    child: Column(
                      children: _methods.map((m) {
                        final selected = _paymentMethod == m.id;
                        return GestureDetector(
                          onTap: () {
                            setState(() => _paymentMethod = m.id);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: selected ? AppColors.primary : AppColors.border, width: selected ? 1.5 : 1),
                              color: selected ? AppColors.primary.withOpacity(0.05) : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Text(m.emoji, style: const TextStyle(fontSize: 24)),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(m.label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.secondary)),
                                      Text(m.sub, style: const TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: selected ? AppColors.primary : AppColors.border, width: 2),
                                  ),
                                  child: selected
                                      ? Center(
                                          child: Container(
                                            width: 10,
                                            height: 10,
                                            decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primary),
                                          ),
                                        )
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  _Section(
                    title: 'Ghi chú đơn hàng',
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(10)),
                      child: TextField(
                        controller: _noteCtrl,
                        maxLines: 3,
                        minLines: 2,
                        decoration: const InputDecoration(
                          hintText: 'Lời nhắn cho shop (tuỳ chọn)',
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                  _Section(
                    child: Column(
                      children: [
                        _Row('Tạm tính', formatVND(subtotal)),
                        const SizedBox(height: 8),
                        _Row('Vận chuyển', formatVND(_shippingFee)),
                        if (discount > 0) ...[
                          const SizedBox(height: 8),
                          _Row('Giảm giá', '-${formatVND(discount)}', valueColor: AppColors.success),
                        ],
                        const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider(color: AppColors.border)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Tổng cộng', style: AppTextStyles.h3),
                            ShaderMask(
                              shaderCallback: (b) => AppColors.primaryGradient.createShader(b),
                              child: Text(formatVND(total), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(12, 10, 12, 10 + MediaQuery.of(context).padding.bottom),
            decoration: const BoxDecoration(
              color: AppColors.background,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Tổng', style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                    ShaderMask(
                      shaderCallback: (b) => AppColors.primaryGradient.createShader(b),
                      child: Text(formatVND(total), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    label: _isSubmitting ? 'Đang xử lý...' : 'Đặt hàng',
                    variant: AppButtonVariant.gradient,
                    size: AppButtonSize.lg,
                    disabled: _isSubmitting || items.isEmpty,
                    onPressed: _placeOrder,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String? title;
  final Widget child;
  const _Section({this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(title!, style: AppTextStyles.h3),
            const SizedBox(height: 12),
          ],
          child,
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _Row(this.label, this.value, {this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.mutedForeground)),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: valueColor ?? AppColors.secondary)),
      ],
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboard;

  const _InputField({required this.controller, required this.hint, this.keyboard});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 13, color: AppColors.mutedForeground),
          border: InputBorder.none,
          isDense: true,
        ),
      ),
    );
  }
}
