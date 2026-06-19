import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/order_provider.dart';
import '../../../providers/payment_provider.dart';
import '../../../models/api_models.dart';
import '../../../core/utils/format_utils.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/top_app_bar.dart';
import '../widgets/checkout_item_row.dart';
import '../widgets/checkout_section.dart';
import 'order_success_screen.dart';
import 'vnpay_payment_screen.dart';

final _methods = [
  (id: 'cod', label: AppStrings.methodCod, sub: AppStrings.methodCodSub, emoji: '💵'),
  (id: 'bank', label: AppStrings.methodBank, sub: AppStrings.methodBankSub, emoji: '🏦'),
  (id: 'vnpay', label: AppStrings.methodVnpay, sub: AppStrings.methodVnpaySub, emoji: '🟦'),
];

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _pm = 'cod';
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _noteCtrl;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _nameCtrl = TextEditingController(text: auth.fullName ?? '');
    _phoneCtrl = TextEditingController(text: '0901234567');
    _addressCtrl = TextEditingController(text: AppStrings.mockUserAddress);
    _noteCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final cart = context.read<CartProvider>();
    final orderProvider = context.read<OrderProvider>();

    if (auth.userId == null || auth.accessToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập để đặt hàng')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final orderRequest = CreateOrderRequest(
      shippingAddress: '${_nameCtrl.text.trim()} | ${_phoneCtrl.text.trim()} | ${_addressCtrl.text.trim()}',
      paymentMethod: _pm.toUpperCase(),
      voucherCode: _noteCtrl.text.trim().isNotEmpty ? _noteCtrl.text.trim() : null, // dùng làm ghi chú/voucher
      items: cart.selectedItems.map((i) => OrderItemRequest(
        productId: i.productId,
        quantity: i.quantity,
      )).toList(),
    );

    try {
      final order = await orderProvider.createOrder(
        orderRequest,
        auth.userId!,
      );

      if (order != null) {
        // Tải lại giỏ hàng từ BE
        await cart.loadCart(auth.userId!);
        if (!mounted) return;

        if (_pm == 'vnpay') {
          final paymentProvider = context.read<PaymentProvider>();
          final url = await paymentProvider.createVNPayUrl(order.orderId);
          if (!mounted) return;

          if (url != null) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => VNPayPaymentScreen(
                  order: order,
                  paymentUrl: url,
                  token: auth.accessToken!,
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(paymentProvider.error ?? 'Không thể tạo link thanh toán'),
                backgroundColor: AppColors.destructive,
              ),
            );
          }
        } else if (_pm == 'bank') {
          // Hiển thị thông tin chuyển khoản
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => AlertDialog(
              title: const Text('Chuyển khoản ngân hàng'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Vui lòng chuyển khoản đến:', style: TextStyle(fontSize: 13, color: AppColors.mutedForeground)),
                  const SizedBox(height: 12),
                  _BankInfoRow(label: 'Ngân hàng', value: 'Vietcombank'),
                  _BankInfoRow(label: 'Số tài khoản', value: '1234567890'),
                  _BankInfoRow(label: 'Chủ tài khoản', value: 'ELECTRO SHOP'),
                  _BankInfoRow(label: 'Số tiền', value: formatVND(cart.totalPayable.round())),
                  _BankInfoRow(label: 'Nội dung', value: 'DH${order.orderId}'),
                  const SizedBox(height: 12),
                  const Text(
                    'Đơn hàng sẽ được xử lý sau khi xác nhận thanh toán.',
                    style: TextStyle(fontSize: 12, color: AppColors.mutedForeground),
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
                      MaterialPageRoute(builder: (_) => OrderSuccessScreen(order: order)),
                    );
                  },
                  child: const Text('Đã chuyển khoản'),
                ),
              ],
            ),
          );
        } else {
          // COD
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => OrderSuccessScreen(order: order)),
          );
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(orderProvider.error ?? 'Đặt hàng thất bại, vui lòng thử lại'),
            backgroundColor: AppColors.destructive,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.destructive,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final items = cart.selectedItems; // List<ApiCartItemResponse>

    final subtotal = cart.selectedSubtotal;
    final shipping = cart.shippingFee;
    final total = cart.totalPayable;

    return Scaffold(
      appBar: const ElectroAppBar(title: AppStrings.checkoutTitle),
      body: Column(
        children: [
          // Stepper
          Container(
            padding: const EdgeInsets.fromLTRB(AppSizes.p24, AppSizes.p12, AppSizes.p24, AppSizes.p16),
            decoration: const BoxDecoration(
              color: AppColors.background,
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [AppStrings.stepAddress, AppStrings.stepPayment, AppStrings.stepConfirm].asMap().entries.map((e) {
                final idx = e.key;
                final label = e.value;
                final done = idx < 2;
                final active = idx == 2;
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
                                      '${idx + 1}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: active ? Colors.white : AppColors.mutedForeground,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: AppSizes.p4),
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
                      if (idx < 2)
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
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Address Form
                    CheckoutSection(
                      title: AppStrings.stepAddress,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _nameCtrl,
                            decoration: const InputDecoration(
                              labelText: AppStrings.fullNameLabel,
                              prefixIcon: Icon(Icons.person_outline),
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            validator: (v) => v == null || v.trim().isEmpty ? AppStrings.errEmptyFields : null,
                          ),
                          const SizedBox(height: AppSizes.p12),
                          TextFormField(
                            controller: _phoneCtrl,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: AppStrings.phoneLabel,
                              prefixIcon: Icon(Icons.phone_outlined),
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return AppStrings.errEmptyFields;
                              if (v.trim().length < 10) return AppStrings.errInvalidPhone;
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSizes.p12),
                          TextFormField(
                            controller: _addressCtrl,
                            maxLines: 2,
                            decoration: const InputDecoration(
                              labelText: AppStrings.addressLabel,
                              prefixIcon: Icon(Icons.location_on_outlined),
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            validator: (v) => v == null || v.trim().isEmpty ? AppStrings.errEmptyFields : null,
                          ),
                        ],
                      ),
                    ),

                    // Products — dùng ApiCartItemResponse trực tiếp
                    CheckoutSection(
                      title: '${AppStrings.productsTitle} (${items.length})',
                      child: Column(
                        children: items.map((item) => CheckoutItemRow(item: item)).toList(),
                      ),
                    ),

                    // Payment methods
                    CheckoutSection(
                      title: AppStrings.paymentMethod,
                      child: Column(
                        children: _methods
                            .map((m) => GestureDetector(
                                  onTap: () => setState(() => _pm = m.id),
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: AppSizes.p8),
                                    padding: const EdgeInsets.all(AppSizes.p12),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: _pm == m.id ? AppColors.primary : AppColors.border,
                                        width: _pm == m.id ? 1.5 : 1,
                                      ),
                                      color: _pm == m.id ? AppColors.primary.withValues(alpha: 0.05) : Colors.transparent,
                                      borderRadius: BorderRadius.circular(AppSizes.r12),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(m.emoji, style: const TextStyle(fontSize: 24)),
                                        const SizedBox(width: AppSizes.p12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                m.label,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.secondary,
                                                ),
                                              ),
                                              Text(
                                                m.sub,
                                                style: const TextStyle(fontSize: 11, color: AppColors.mutedForeground),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: 20,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: _pm == m.id ? AppColors.primary : AppColors.border,
                                              width: 2,
                                            ),
                                          ),
                                          child: _pm == m.id
                                              ? Center(
                                                  child: Container(
                                                    width: 10,
                                                    height: 10,
                                                    decoration: const BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: AppColors.primary,
                                                    ),
                                                  ),
                                                )
                                              : null,
                                        ),
                                      ],
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),

                    // Note
                    CheckoutSection(
                      title: AppStrings.orderNotes,
                      child: Container(
                        padding: const EdgeInsets.all(AppSizes.p12),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextFormField(
                          controller: _noteCtrl,
                          maxLines: 3,
                          minLines: 2,
                          decoration: const InputDecoration(
                            hintText: AppStrings.orderNotesHint,
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ),

                    // Summary
                    CheckoutSection(
                      child: Column(
                        children: [
                          _Row(AppStrings.subtotal, formatVND(subtotal.round())),
                          const SizedBox(height: AppSizes.p8),
                          _Row(
                            AppStrings.shipping,
                            shipping == 0 ? AppStrings.free : formatVND(shipping.round()),
                            valueColor: shipping == 0 ? AppColors.success : null,
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: AppSizes.p10),
                            child: Divider(color: AppColors.border),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(AppStrings.totalPayable, style: AppTextStyles.h3),
                              ShaderMask(
                                shaderCallback: (b) => AppColors.primaryGradient.createShader(b),
                                child: Text(
                                  formatVND(total.round()),
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSizes.p12),
                  ],
                ),
              ),
            ),
          ),

          // Bottom bar
          Container(
            padding: EdgeInsets.fromLTRB(AppSizes.p12, AppSizes.p10, AppSizes.p12, AppSizes.p10 + MediaQuery.of(context).padding.bottom),
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
                    const Text(AppStrings.total, style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                    ShaderMask(
                      shaderCallback: (b) => AppColors.primaryGradient.createShader(b),
                      child: Text(
                        formatVND(total.round()),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: AppSizes.p12),
                Expanded(
                  child: AppButton(
                    label: _isLoading ? null : AppStrings.placeOrder,
                    variant: AppButtonVariant.gradient,
                    size: AppButtonSize.lg,
                    disabled: items.isEmpty || _isLoading,
                    onPressed: items.isEmpty || _isLoading ? null : _placeOrder,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : null,
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
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: valueColor ?? AppColors.secondary,
          ),
        ),
      ],
    );
  }
}

class _BankInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _BankInfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.mutedForeground)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.secondary)),
        ],
      ),
    );
  }
}
