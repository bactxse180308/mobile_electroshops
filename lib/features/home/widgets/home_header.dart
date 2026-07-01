import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_sizes.dart';

class HomeHeader extends StatelessWidget {
  final int cartCount;
  final int chatCount;
  final VoidCallback onNotificationTap;
  final VoidCallback onCartTap;
  final VoidCallback onChatTap;
  final VoidCallback onSearchTap;

  const HomeHeader({
    super.key,
    required this.cartCount,
    required this.chatCount,
    required this.onNotificationTap,
    required this.onCartTap,
    required this.onChatTap,
    required this.onSearchTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.heroGradient),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + AppSizes.p12,
        left: AppSizes.p16,
        right: AppSizes.p16,
        bottom: AppSizes.p20,
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 16, color: Colors.white),
              const SizedBox(width: AppSizes.p4),
              const Text(
                AppStrings.locationLabel,
                style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
              ),
              const Icon(Icons.expand_more, size: 16, color: Colors.white),
              const Spacer(),
              IconButton(
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 22),
                    if (chatCount > 0)
                      Positioned(
                        top: -4,
                        right: -6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            gradient: AppColors.flashGradient,
                            borderRadius: BorderRadius.circular(AppSizes.r8),
                          ),
                          constraints: const BoxConstraints(minWidth: 16),
                          child: Text(
                            chatCount > 99 ? '99+' : '$chatCount',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                  ],
                ),
                onPressed: onChatTap,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: AppSizes.p4),
              IconButton(
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.notifications_outlined, color: Colors.white, size: 22),
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                      ),
                    ),
                  ],
                ),
                onPressed: onNotificationTap,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: AppSizes.p4),
              IconButton(
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 22),
                    if (cartCount > 0)
                      Positioned(
                        top: -4,
                        right: -6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            gradient: AppColors.flashGradient,
                            borderRadius: BorderRadius.circular(AppSizes.r8),
                          ),
                          child: Text(
                            '$cartCount',
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                  ],
                ),
                onPressed: onCartTap,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.p12),
          GestureDetector(
            onTap: onSearchTap,
            child: Container(
              height: AppSizes.btnHeightMd,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(AppSizes.r12),
                boxShadow: AppShadows.lift,
              ),
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
              child: const Row(
                children: [
                  Icon(Icons.search, size: 20, color: AppColors.primary),
                  SizedBox(width: AppSizes.p8),
                  Text(AppStrings.searchHint, style: TextStyle(color: AppColors.mutedForeground, fontSize: 14)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
