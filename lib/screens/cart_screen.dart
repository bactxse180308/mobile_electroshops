import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../models/api_models.dart';
import '../utils/format_utils.dart';
import '../widgets/empty_state.dart';
import '../widgets/app_button.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  final ValueChanged<int>? onNavigate;
  const CartScreen({super.key, this.onNavigate});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    // Reload cart mỗi khi vào màn hình (phòng hết hạn cache)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final cart = context.read<CartProvider>();
      if (auth.isAuthenticated && auth.userId != null) {
        cart.loadCart(auth.userId!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final cart = context.watch<CartProvider>();
    final items = cart.items;

    // Chưa đăng nhập
    if (!auth.isAuthenticated) {
      return Column(
        children: [
          _CartHeader(itemCount: 0, onClear: null),
          Expanded(
            child: EmptyState(
              icon: Icons.lock_outline,
              title: 'Bạn chưa đăng nhập',
              body: 'Đăng nhập để xem và quản lý giỏ hàng của bạn.',
              action: AppButton(
                label: 'Đăng nhập',
                variant: AppButtonVariant.gradient,
                onPressed: () => Navigator.pushNamed(context, '/login'),
              ),
            ),
          ),
        ],
      );
    }

    // Đang tải
    if (cart.isLoading && items.isEmpty) {
      return Column(
        children: [
          _CartHeader(itemCount: 0, onClear: null),
          const Expanded(
            child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          ),
        ],
      );
    }

    // Giỏ trống
    if (items.isEmpty) {
      return Column(
        children: [
          _CartHeader(itemCount: 0, onClear: null),
          Expanded(
            child: EmptyState(
              icon: Icons.shopping_bag_outlined,
              title: 'Giỏ hàng trống',
              body: 'Khám phá sản phẩm và thêm vào giỏ của bạn.',
              action: AppButton(
                label: 'Tiếp tục mua sắm',
                onPressed: () => widget.onNavigate?.call(0),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        _CartHeader(
          itemCount: items.length,
          onClear: () async {
            final userId = auth.userId;
            if (userId == null) return;
            final confirm = await _confirmDialog(
              context,
              title: 'Xoá tất cả?',
              message: 'Bạn có chắc muốn xoá toàn bộ giỏ hàng?',
            );
            if (confirm == true && mounted) {
              await cart.clearAllItems(userId);
              if (mounted && cart.error != null) {
                _showError(cart.error!);
                cart.clearError();
              }
            }
          },
        ),

        // Chọn tất cả
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: AppColors.background,
          child: Row(
            children: [
              _Checkbox(
                checked: cart.allSelected,
                onTap: () => cart.toggleSelectAll(!cart.allSelected),
              ),
              const SizedBox(width: 8),
              const Text(
                'Chọn tất cả',
                style: TextStyle(fontSize: 14, color: AppColors.secondary),
              ),
              const Spacer(),
              if (cart.isLoading)
                const SizedBox(
                  width: 16, height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                ),
            ],
          ),
        ),

        // Danh sách sản phẩm
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                ...items.map((item) => _CartItemCard(
                  item: item,
                  selected: cart.selectedIds.contains(item.productId),
                  onToggle: () => cart.toggleSelect(item.productId),
                  onIncrease: () {
                    final uid = auth.userId;
                    if (uid == null) return;
                    cart.updateQty(uid, item.productId, item.quantity + 1);
                  },
                  onDecrease: () {
                    final uid = auth.userId;
                    if (uid == null) return;
                    if (item.quantity > 1) {
                      cart.updateQty(uid, item.productId, item.quantity - 1);
                    }
                  },
                  onRemove: () async {
                    final uid = auth.userId;
                    if (uid == null) return;
                    await cart.removeItem(uid, item.productId);
                    if (mounted && cart.error != null) {
                      _showError(cart.error!);
                      cart.clearError();
                    }
                  },
                )),

                // Coupon
                _CouponInput(),

                // Tóm tắt đơn hàng
                _OrderSummary(cart: cart),

                const SizedBox(height: 12),
              ],
            ),
          ),
        ),

        // Nút thanh toán
        Container(
          padding: EdgeInsets.fromLTRB(12, 10, 12, 10 + MediaQuery.of(context).padding.bottom),
          decoration: const BoxDecoration(
            color: AppColors.background,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: _CheckoutBar(cart: cart),
        ),
      ],
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.destructive),
    );
  }

  Future<bool?> _confirmDialog(BuildContext ctx, {required String title, required String message}) {
    return showDialog<bool>(
      context: ctx,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xoá', style: TextStyle(color: AppColors.destructive)),
          ),
        ],
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────
class _CartHeader extends StatelessWidget {
  final int itemCount;
  final VoidCallback? onClear;
  const _CartHeader({required this.itemCount, this.onClear});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).padding.top + 56,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Text('Giỏ hàng ($itemCount)', style: AppTextStyles.h3),
          const Spacer(),
          if (itemCount > 0 && onClear != null)
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 22, color: AppColors.secondary),
              onPressed: onClear,
            ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}

// ── Cart Item Card ─────────────────────────────────────────────────────────────
class _CartItemCard extends StatelessWidget {
  final ApiCartItemResponse item;
  final bool selected;
  final VoidCallback onToggle;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;

  const _CartItemCard({
    required this.item,
    required this.selected,
    required this.onToggle,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = item.mainImage != null && item.mainImage!.isNotEmpty
        ? item.mainImage!
        : 'https://picsum.photos/seed/${item.productId}/200/200';

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
            child: _Checkbox(checked: selected, onTap: onToggle),
          ),
          const SizedBox(width: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imageUrl,
              width: 80, height: 80,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 80, height: 80,
                color: AppColors.muted,
                child: const Icon(Icons.image_not_supported, color: AppColors.mutedForeground),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: const TextStyle(fontSize: 13, color: AppColors.secondary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(formatVND(item.price.round()), style: AppTextStyles.price),
                          if (item.quantity > 1)
                            Text(
                              '= ${formatVND(item.subtotal.round())}',
                              style: const TextStyle(fontSize: 11, color: AppColors.mutedForeground),
                            ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        // Xoá
                        GestureDetector(
                          onTap: onRemove,
                          child: Container(
                            width: 32, height: 32,
                            alignment: Alignment.center,
                            child: const Icon(Icons.delete_outline, size: 18, color: AppColors.mutedForeground),
                          ),
                        ),
                        // Số lượng
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.border),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _QtyButton(icon: Icons.remove, onTap: item.quantity > 1 ? onDecrease : null),
                              SizedBox(
                                width: 32,
                                child: Text(
                                  '${item.quantity}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                ),
                              ),
                              _QtyButton(icon: Icons.add, onTap: onIncrease),
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
  }
}

// ── Coupon ────────────────────────────────────────────────────────────────────
class _CouponInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: [
          const Icon(Icons.local_offer_outlined, size: 20, color: AppColors.accent),
          const SizedBox(width: 8),
          const Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Nhập mã giảm giá',
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: TextStyle(fontSize: 13),
            ),
          ),
          AppButton(label: 'Áp dụng', size: AppButtonSize.sm, onPressed: () {}),
        ],
      ),
    );
  }
}

// ── Order Summary ─────────────────────────────────────────────────────────────
class _OrderSummary extends StatelessWidget {
  final CartProvider cart;
  const _OrderSummary({required this.cart});

  @override
  Widget build(BuildContext context) {
    final subtotal = cart.selectedSubtotal;
    final shipping = cart.shippingFee;
    final total = cart.totalPayable;
    final count = cart.selectedItems.length;

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          _SummaryRow(
            label: 'Tạm tính ($count sản phẩm)',
            value: formatVND(subtotal.round()),
          ),
          const SizedBox(height: 8),
          _SummaryRow(
            label: 'Phí vận chuyển',
            value: shipping == 0 ? 'Miễn phí' : formatVND(shipping.round()),
          ),
          if (shipping == 0) ...[
            const SizedBox(height: 4),
            Row(
              children: const [
                SizedBox(width: 0),
                Spacer(),
                Icon(Icons.local_shipping_outlined, size: 12, color: AppColors.success),
                SizedBox(width: 4),
                Text(
                  'Đơn hàng ≥ 500.000đ được miễn ship',
                  style: TextStyle(fontSize: 11, color: AppColors.success),
                ),
              ],
            ),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(color: AppColors.border),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tổng thanh toán', style: AppTextStyles.h3),
              Text(
                formatVND(total.round()),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Checkout Bar ──────────────────────────────────────────────────────────────
class _CheckoutBar extends StatelessWidget {
  final CartProvider cart;
  const _CheckoutBar({required this.cart});

  @override
  Widget build(BuildContext context) {
    final selected = cart.selectedItems;
    final total = cart.totalPayable;
    final count = selected.length;

    return AppButton(
      label: count == 0
          ? 'Chọn sản phẩm để thanh toán'
          : 'Thanh toán ($count) · ${formatVND(total.round())}',
      variant: AppButtonVariant.gradient,
      size: AppButtonSize.lg,
      fullWidth: true,
      disabled: count == 0,
      onPressed: count == 0
          ? null
          : () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CheckoutScreen()),
              ),
    );
  }
}

// ── Summary Row ───────────────────────────────────────────────────────────────
class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.mutedForeground)),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.secondary,
          ),
        ),
      ],
    );
  }
}


// ── Checkbox ──────────────────────────────────────────────────────────────────
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
          border: Border.all(
            color: checked ? AppColors.primary : AppColors.border,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: checked
            ? const Icon(Icons.check, size: 14, color: Colors.white)
            : null,
      ),
    );
  }
}

// ── Qty Button ────────────────────────────────────────────────────────────────
class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _QtyButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 30, height: 30,
        child: Icon(
          icon,
          size: 14,
          color: onTap == null ? AppColors.mutedForeground : AppColors.secondary,
        ),
      ),
    );
  }
}
