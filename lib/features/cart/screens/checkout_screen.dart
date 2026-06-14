import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/cart_provider.dart';
import '../../../core/utils/format_utils.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/top_app_bar.dart';
import '../widgets/checkout_item_row.dart';
import '../widgets/checkout_section.dart';
import 'order_success_screen.dart';

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
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Address
                  CheckoutSection(
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.location_on_outlined, size: 20, color: AppColors.primary),
                        ),
                        const SizedBox(width: AppSizes.p12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    AppStrings.mockUserName,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                  SizedBox(width: AppSizes.p8),
                                  Text(AppStrings.mockUserPhone, style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                                ],
                              ),
                              SizedBox(height: 2),
                              Text(
                                AppStrings.mockUserAddress,
                                style: TextStyle(fontSize: 12, color: AppColors.mutedForeground),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
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
                      child: const TextField(
                        maxLines: 3,
                        minLines: 2,
                        decoration: InputDecoration(
                          hintText: AppStrings.orderNotesHint,
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: TextStyle(fontSize: 13),
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
                    label: AppStrings.placeOrder,
                    variant: AppButtonVariant.gradient,
                    size: AppButtonSize.lg,
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const OrderSuccessScreen()),
                      );
                    },
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
