import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/custom_checkbox.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/auth_provider.dart';
import '../widgets/cart_header.dart';
import '../widgets/cart_item_card.dart';
import '../widgets/coupon_input.dart';
import '../widgets/order_summary.dart';
import '../widgets/checkout_bar.dart';

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
          const CartHeader(itemCount: 0, onClear: null),
          Expanded(
            child: EmptyState(
              icon: Icons.lock_outline,
              title: AppStrings.notLoggedIn,
              body: AppStrings.cartLoginPrompt,
              action: AppButton(
                label: AppStrings.loginButton,
                variant: AppButtonVariant.gradient,
                onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
              ),
            ),
          ),
        ],
      );
    }

    // Đang tải
    if (cart.isLoading && items.isEmpty) {
      return const Column(
        children: [
          CartHeader(itemCount: 0, onClear: null),
          Expanded(
            child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          ),
        ],
      );
    }

    // Giỏ trống
    if (items.isEmpty) {
      return Column(
        children: [
          const CartHeader(itemCount: 0, onClear: null),
          Expanded(
            child: EmptyState(
              icon: Icons.shopping_bag_outlined,
              title: AppStrings.cartEmpty,
              body: AppStrings.cartEmptyPrompt,
              action: AppButton(
                label: AppStrings.continueShopping,
                onPressed: () => widget.onNavigate?.call(0),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        CartHeader(
          itemCount: items.length,
          onClear: () async {
            final userId = auth.userId;
            if (userId == null) return;
            final confirm = await _confirmDialog(
              context,
              title: AppStrings.confirmClearCart,
              message: AppStrings.confirmClearCartMsg,
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
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16, vertical: AppSizes.p10),
          color: AppColors.background,
          child: Row(
            children: [
              CustomCheckbox(
                checked: cart.allSelected,
                onTap: () => cart.toggleSelectAll(!cart.allSelected),
              ),
              const SizedBox(width: AppSizes.p8),
              const Text(
                AppStrings.selectAll,
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
                ...items.map((item) => CartItemCard(
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
                const CouponInput(),

                // Tóm tắt đơn hàng
                OrderSummary(cart: cart),

                const SizedBox(height: AppSizes.p12),
              ],
            ),
          ),
        ),

        // Nút thanh toán
        Container(
          padding: EdgeInsets.fromLTRB(AppSizes.p12, AppSizes.p10, AppSizes.p12, AppSizes.p10 + MediaQuery.of(context).padding.bottom),
          decoration: const BoxDecoration(
            color: AppColors.background,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: CheckoutBar(cart: cart),
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
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text(AppStrings.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(AppStrings.delete, style: TextStyle(color: AppColors.destructive)),
          ),
        ],
      ),
    );
  }
}
