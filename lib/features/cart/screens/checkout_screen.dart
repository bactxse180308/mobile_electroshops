import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/top_app_bar.dart';
import '../../../models/api_models.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/order_provider.dart';
import '../../../providers/payment_provider.dart';
import '../widgets/checkout_bottom_bar.dart';
import '../widgets/checkout_product_list.dart';
import '../widgets/checkout_stepper.dart';
import '../widgets/checkout_summary_card.dart';
import '../widgets/order_note_input.dart';
import '../widgets/payment_method_selector.dart';
import '../widgets/shipping_address_form.dart';
import 'order_success_screen.dart';
import 'vnpay_payment_screen.dart';

const _paymentMethods = [
  PaymentMethodOption(
    id: 'cod',
    label: AppStrings.methodCod,
    subtitle: AppStrings.methodCodSub,
    icon: Icons.payments_outlined,
  ),
  PaymentMethodOption(
    id: 'vnpay',
    label: AppStrings.methodVnpay,
    subtitle: AppStrings.methodVnpaySub,
    icon: Icons.account_balance_wallet_outlined,
  ),
];

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _noteCtrl;

  String _paymentMethod = 'cod';
  bool _isLoading = false;

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
    if (_formKey.currentState?.validate() != true) return;

    final auth = context.read<AuthProvider>();
    final cart = context.read<CartProvider>();
    final orderProvider = context.read<OrderProvider>();

    if (cart.selectedItems.isEmpty) {
      _showMessage('Vui lòng chọn sản phẩm để đặt hàng');
      return;
    }

    if (auth.userId == null || auth.accessToken == null) {
      _showMessage('Vui lòng đăng nhập để đặt hàng');
      return;
    }

    setState(() => _isLoading = true);

    final orderRequest = CreateOrderRequest(
      shippingAddress:
          '${_nameCtrl.text.trim()} | ${_phoneCtrl.text.trim()} | ${_addressCtrl.text.trim()}',
      paymentMethod: _paymentMethod.toUpperCase(),
      voucherCode:
          _noteCtrl.text.trim().isNotEmpty ? _noteCtrl.text.trim() : null,
      items: cart.selectedItems
          .map(
            (item) => OrderItemRequest(
              productId: item.productId,
              quantity: item.quantity,
            ),
          )
          .toList(),
    );

    try {
      final order = await orderProvider.createOrder(
        orderRequest,
        auth.userId!,
      );

      if (!mounted) return;
      if (order == null) {
        _showMessage(
          orderProvider.error ?? 'Đặt hàng thất bại, vui lòng thử lại',
          isError: true,
        );
        return;
      }

      await cart.loadCart(auth.userId!);
      if (!mounted) return;

      if (_paymentMethod == 'vnpay') {
        await _openVNPay(order, auth.accessToken!);
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => OrderSuccessScreen(order: order)),
      );
    } catch (e) {
      if (!mounted) return;
      _showMessage('Có lỗi xảy ra: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _openVNPay(OrderResponse order, String token) async {
    final paymentProvider = context.read<PaymentProvider>();
    final url = await paymentProvider.createVNPayUrl(order.orderId);
    if (!mounted) return;

    if (url == null) {
      _showMessage(
        paymentProvider.error ?? 'Không thể tạo link thanh toán',
        isError: true,
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => VNPayPaymentScreen(
          order: order,
          paymentUrl: url,
          token: token,
        ),
      ),
    );
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.destructive : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final items = cart.selectedItems;

    return Scaffold(
      appBar: const ElectroAppBar(title: AppStrings.checkoutTitle),
      body: Column(
        children: [
          const CheckoutStepper(),
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ShippingAddressForm(
                      nameController: _nameCtrl,
                      phoneController: _phoneCtrl,
                      addressController: _addressCtrl,
                    ),
                    CheckoutProductList(items: items),
                    PaymentMethodSelector(
                      methods: _paymentMethods,
                      selectedMethod: _paymentMethod,
                      onChanged: (method) {
                        setState(() => _paymentMethod = method);
                      },
                    ),
                    OrderNoteInput(controller: _noteCtrl),
                    CheckoutSummaryCard(
                      subtotal: cart.selectedSubtotal,
                      shipping: cart.shippingFee,
                      total: cart.totalPayable,
                    ),
                    const SizedBox(height: AppSizes.p12),
                  ],
                ),
              ),
            ),
          ),
          CheckoutBottomBar(
            total: cart.totalPayable,
            loading: _isLoading,
            disabled: items.isEmpty,
            onPlaceOrder: _placeOrder,
          ),
        ],
      ),
    );
  }
}
