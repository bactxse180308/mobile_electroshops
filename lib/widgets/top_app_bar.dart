import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ElectroAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool showBack;
  final Widget? right;

  const ElectroAppBar({
    super.key,
    this.title,
    this.showBack = true,
    this.right,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          if (showBack)
            IconButton(
              icon: const Icon(Icons.chevron_left, size: 28, color: AppColors.secondary),
              onPressed: () => Navigator.pop(context),
            )
          else
            const SizedBox(width: 16),
          if (title != null)
            Expanded(
              child: Text(
                title!,
                style: AppTextStyles.h3,
                overflow: TextOverflow.ellipsis,
              ),
            )
          else
            const Spacer(),
          if (right != null) right! else const SizedBox(width: 16),
        ],
      ),
    );
  }
}
