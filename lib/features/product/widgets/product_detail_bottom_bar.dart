import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../models/models.dart';
import '../../chat/screens/chat_screen.dart';

class ProductDetailBottomBar extends StatelessWidget {
  final Product product;
  final VoidCallback onAddToCart;
  final VoidCallback onBuyNow;

  const ProductDetailBottomBar({
    super.key,
    required this.product,
    required this.onAddToCart,
    required this.onBuyNow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSizes.p12,
        AppSizes.p10,
        AppSizes.p12,
        AppSizes.p10 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          // Admin không chat với vai trò khách → ẩn nút chat cho ADMIN.
          if (context.watch<AuthProvider>().role != 'ADMIN') ...[
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(attachProduct: product),
                ),
              ),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(AppSizes.r12),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.chat_bubble_outline, size: 18, color: AppColors.primary),
                    Text(
                      AppStrings.chat,
                      style: TextStyle(fontSize: 9, color: AppColors.secondary),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: AppSizes.p8),
          ],
          Expanded(
            child: AppButton(
              label: AppStrings.addToCart,
              variant: AppButtonVariant.secondary,
              disabled: product.stock == 0,
              onPressed: onAddToCart,
            ),
          ),
          const SizedBox(width: AppSizes.p8),
          Expanded(
            child: AppButton(
              label: AppStrings.buyNow,
              variant: AppButtonVariant.gradient,
              disabled: product.stock == 0,
              onPressed: onBuyNow,
            ),
          ),
        ],
      ),
    );
  }
}
