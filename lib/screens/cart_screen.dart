import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/cart_provider.dart';
import '../data/seed_data.dart';
import '../utils/format_utils.dart';
import '../widgets/empty_state.dart';
import '../widgets/app_button.dart';

class CartScreen extends StatelessWidget {
  final ValueChanged<int>? onNavigate;
  const CartScreen({super.key, this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final items = cart.items;

    return Column(
      children: [
        Container(
          height: MediaQuery.of(context).padding.top + 56,
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          decoration: const BoxDecoration(
            color: AppColors.background,
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              Text('Giỏ hàng (${items.length})', style: AppTextStyles.h3),
              const Spacer(),
              if (items.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 22, color: AppColors.secondary),
                  onPressed: () {
                    context.read<CartProvider>().clear();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xoá tất cả'), backgroundColor: AppColors.success));
                  },
                ),
              const SizedBox(width: 4),
            ],
          ),
        ),
        if (items.isEmpty)
          Expanded(
            child: EmptyState(
              icon: Icons.shopping_bag_outlined,
              title: 'Giỏ hàng trống',
              body: 'Khám phá sản phẩm và thêm vào giỏ của bạn.',
              action: AppButton(
                label: 'Tiếp tục mua sắm',
                onPressed: () => onNavigate?.call(0),
              ),
            ),
          )
        else ...[
          // Select all
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppColors.background,
            child: Row(
              children: [
                _Checkbox(
                  checked: cart.allSelected,
                  onTap: () => cart.toggleAll(!cart.allSelected),
                ),
                const SizedBox(width: 8),
                const Text('Chọn tất cả', style: TextStyle(fontSize: 14, color: AppColors.secondary)),
              ],
            ),
          ),

          // Cart items
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ...items.map((item) {
                    final p = findProduct(item.id);
                    if (p == null) return const SizedBox.shrink();
                    return Container(
                      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: AppShadows.card,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: _Checkbox(
                              checked: item.selected,
                              onTap: () => context.read<CartProvider>().toggle(item.id),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(p.images[0], width: 80, height: 80, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(width: 80, height: 80, color: AppColors.muted),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p.name, style: const TextStyle(fontSize: 13, color: AppColors.secondary), maxLines: 2, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 2),
                                Text(p.brand, style: const TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(formatVND(p.price), style: AppTextStyles.price),
                                          Text(formatVND(p.oldPrice), style: AppTextStyles.priceOld),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.mutedForeground),
                                          onPressed: () {
                                            context.read<CartProvider>().remove(item.id);
                                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xoá sản phẩm'), backgroundColor: AppColors.success));
                                          },
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(8)),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              _QtyButton(icon: Icons.remove, onTap: item.qty > 1 ? () => context.read<CartProvider>().setQty(item.id, item.qty - 1) : null),
                                              SizedBox(width: 28, child: Text('${item.qty}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                                              _QtyButton(icon: Icons.add, onTap: () => context.read<CartProvider>().setQty(item.id, item.qty + 1)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  // Coupon input
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), boxShadow: AppShadows.card),
                    child: Row(
                      children: [
                        const Icon(Icons.local_offer_outlined, size: 20, color: AppColors.accent),
                        const SizedBox(width: 8),
                        const Expanded(child: TextField(decoration: InputDecoration(hintText: 'Nhập mã giảm giá', border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero), style: TextStyle(fontSize: 13))),
                        AppButton(label: 'Áp dụng', size: AppButtonSize.sm, onPressed: () {}),
                      ],
                    ),
                  ),

                  // Order summary
                  _OrderSummary(cart: cart),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          // Checkout bar
          Container(
            padding: EdgeInsets.fromLTRB(12, 10, 12, 10 + MediaQuery.of(context).padding.bottom),
            decoration: const BoxDecoration(
              color: AppColors.background,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: _CheckoutBtn(cart: cart),
          ),
        ],
      ],
    );
  }
}

class _OrderSummary extends StatelessWidget {
  final CartProvider cart;
  const _OrderSummary({required this.cart});

  @override
  Widget build(BuildContext context) {
    final selected = cart.selectedItems;
    int subtotal = 0;
    for (final i in selected) {
      final p = findProduct(i.id);
      if (p != null) subtotal += p.price * i.qty;
    }
    final shipping = subtotal > 0 ? (subtotal > 500000 ? 0 : 25000) : 0;
    const discount = 30000;
    final total = subtotal + shipping - (subtotal > 0 ? discount : 0);

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), boxShadow: AppShadows.card),
      child: Column(
        children: [
          _SummaryRow(label: 'Tạm tính (${selected.length} sp)', value: formatVND(subtotal)),
          const SizedBox(height: 8),
          _SummaryRow(label: 'Phí vận chuyển', value: shipping == 0 ? 'Miễn phí' : formatVND(shipping)),
          const SizedBox(height: 8),
          _SummaryRow(label: 'Giảm giá', value: subtotal > 0 ? '-${formatVND(discount)}' : '0 ₫', valueColor: AppColors.success),
          const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(color: AppColors.border)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tổng', style: AppTextStyles.h3),
              Text(formatVND(total), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary)),
            ],
          ),
        ],
      ),
    );
  }
}

class _CheckoutBtn extends StatelessWidget {
  final CartProvider cart;
  const _CheckoutBtn({required this.cart});

  @override
  Widget build(BuildContext context) {
    final selected = cart.selectedItems;
    int subtotal = 0;
    for (final i in selected) {
      final p = findProduct(i.id);
      if (p != null) subtotal += p.price * i.qty;
    }
    final shipping = subtotal > 0 ? (subtotal > 500000 ? 0 : 25000) : 0;
    final total = subtotal + shipping - (subtotal > 0 ? 30000 : 0);

    return AppButton(
      label: 'Thanh toán (${selected.length}) · ${formatVND(total)}',
      variant: AppButtonVariant.gradient,
      size: AppButtonSize.lg,
      fullWidth: true,
      disabled: selected.isEmpty,
      onPressed: () => Navigator.pushNamed(context, '/checkout'),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _SummaryRow({required this.label, required this.value, this.valueColor});

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

class _Checkbox extends StatelessWidget {
  final bool checked;
  final VoidCallback onTap;
  const _Checkbox({required this.checked, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 20, height: 20,
        decoration: BoxDecoration(
          color: checked ? AppColors.primary : Colors.transparent,
          border: Border.all(color: checked ? AppColors.primary : AppColors.border, width: 1.5),
          borderRadius: BorderRadius.circular(4),
        ),
        child: checked ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _QtyButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28, height: 28,
        child: Icon(icon, size: 14, color: onTap == null ? AppColors.mutedForeground : AppColors.secondary),
      ),
    );
  }
}
