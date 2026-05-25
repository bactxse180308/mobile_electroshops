import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/cart_provider.dart';
import '../data/seed_data.dart';
import '../utils/format_utils.dart';
import '../widgets/app_button.dart';
import '../widgets/top_app_bar.dart';
import 'order_success_screen.dart';

const _methods = [
  (id: 'cod', label: 'Thanh toán khi nhận hàng', sub: 'Kiểm tra hàng trước khi thanh toán', emoji: '💵'),
  (id: 'bank', label: 'Chuyển khoản ngân hàng', sub: 'Vietcombank · ACB · Techcombank', emoji: '🏦'),
  (id: 'vnpay', label: 'Ví VNPay', sub: 'Quét QR thanh toán nhanh', emoji: '🟦'),
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
    final items = cart.selectedItems;

    int subtotal = 0;
    for (final i in items) {
      final p = findProduct(i.id);
      if (p != null) subtotal += p.price * i.qty;
    }
    final shipping = subtotal > 500000 ? 0 : 25000;
    const discount = 30000;
    final total = subtotal + shipping - discount;

    return Scaffold(
      appBar: const ElectroAppBar(title: 'Thanh toán'),
      body: Column(
        children: [
          // Stepper
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
                            width: 28, height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: done ? AppColors.successGradient : null,
                              color: active ? AppColors.primary : (done ? null : AppColors.muted),
                              border: active ? null : null,
                            ),
                            child: Center(
                              child: done
                                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                                  : Text('${i + 1}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: active ? Colors.white : AppColors.mutedForeground)),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: done || active ? AppColors.secondary : AppColors.mutedForeground)),
                        ],
                      ),
                      if (i < 2)
                        Expanded(child: Container(height: 2, margin: const EdgeInsets.only(bottom: 16), color: done ? AppColors.success : AppColors.border)),
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
                  _Section(
                    child: Row(
                      children: [
                        Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.location_on_outlined, size: 20, color: AppColors.primary),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text('Nguyễn Minh Tuấn', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.secondary)),
                                  SizedBox(width: 8),
                                  Text('0901 234 567', style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                                ],
                              ),
                              SizedBox(height: 2),
                              Text('123 Nguyễn Huệ, P. Bến Nghé, Quận 1, TP.HCM', style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                            ],
                          ),
                        ),
                        const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                      ],
                    ),
                  ),

                  // Products
                  _Section(
                    title: 'Sản phẩm (${items.length})',
                    child: Column(
                      children: items.map((item) {
                        final p = findProduct(item.id);
                        if (p == null) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(p.images[0], width: 56, height: 56, fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(width: 56, height: 56, color: AppColors.muted),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(p.name, style: const TextStyle(fontSize: 12, color: AppColors.secondary), maxLines: 2, overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('x${item.qty}', style: const TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                                        Text(formatVND(p.price * item.qty), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
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

                  // Payment methods
                  _Section(
                    title: 'Phương thức thanh toán',
                    child: Column(
                      children: _methods.map((m) => GestureDetector(
                        onTap: () => setState(() => _pm = m.id),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: _pm == m.id ? AppColors.primary : AppColors.border, width: _pm == m.id ? 1.5 : 1),
                            color: _pm == m.id ? AppColors.primary.withOpacity(0.05) : Colors.transparent,
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
                                width: 20, height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: _pm == m.id ? AppColors.primary : AppColors.border, width: 2),
                                ),
                                child: _pm == m.id
                                    ? Center(child: Container(width: 10, height: 10, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primary)))
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      )).toList(),
                    ),
                  ),

                  // Note
                  _Section(
                    title: 'Ghi chú đơn hàng',
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(10)),
                      child: const TextField(
                        maxLines: 3,
                        minLines: 2,
                        decoration: InputDecoration(
                          hintText: 'Lời nhắn cho shop (tuỳ chọn)',
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ),

                  // Summary
                  _Section(
                    child: Column(
                      children: [
                        _Row('Tạm tính', formatVND(subtotal)),
                        const SizedBox(height: 8),
                        _Row('Vận chuyển', shipping == 0 ? 'Miễn phí' : formatVND(shipping), valueColor: shipping == 0 ? AppColors.success : null),
                        const SizedBox(height: 8),
                        _Row('Giảm giá', '-${formatVND(discount)}', valueColor: AppColors.success),
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

          // Bottom bar
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
                    label: 'Đặt hàng',
                    variant: AppButtonVariant.gradient,
                    size: AppButtonSize.lg,
                    onPressed: () {
                      context.read<CartProvider>().clear();
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const OrderSuccessScreen()));
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
