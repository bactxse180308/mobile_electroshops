import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_strings.dart';

class ProductShippingCard extends StatelessWidget {
  const ProductShippingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(AppSizes.p16, AppSizes.p12, AppSizes.p16, 0),
      padding: const EdgeInsets.all(AppSizes.p16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.r12),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: const [
          _InfoRow(icon: Icons.local_shipping_outlined, text: AppStrings.ship2h),
          Divider(height: AppSizes.p12, color: AppColors.border),
          _InfoRow(icon: Icons.verified_user_outlined, text: AppStrings.warranty12m),
          Divider(height: AppSizes.p12, color: AppColors.border),
          _InfoRow(icon: Icons.replay_outlined, text: AppStrings.return7d),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: AppSizes.iconSm, color: AppColors.primary),
        const SizedBox(width: AppSizes.p12),
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 12, color: AppColors.secondary)),
        ),
      ],
    );
  }
}
