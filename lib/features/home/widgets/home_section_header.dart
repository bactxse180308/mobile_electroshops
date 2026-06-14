import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_sizes.dart';

class HomeSectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onViewAllTap;

  const HomeSectionHeader({
    super.key,
    required this.title,
    this.onViewAllTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSizes.p16, AppSizes.p20, AppSizes.p16, AppSizes.p10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.h2),
          if (onViewAllTap != null)
            GestureDetector(
              onTap: onViewAllTap,
              child: Row(
                children: const [
                  Text(
                    AppStrings.viewAll,
                    style: TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600),
                  ),
                  Icon(Icons.chevron_right, size: 16, color: AppColors.primary),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
