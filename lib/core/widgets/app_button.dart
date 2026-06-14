import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

enum AppButtonVariant { primary, secondary, ghost, gradient, danger }
enum AppButtonSize { sm, md, lg }

class AppButton extends StatelessWidget {
  final Widget? child;
  final String? label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool fullWidth;
  final bool disabled;

  const AppButton({
    super.key,
    this.child,
    this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.md,
    this.fullWidth = false,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final double height = size == AppButtonSize.sm 
        ? AppSizes.btnHeightSm 
        : size == AppButtonSize.lg 
            ? AppSizes.btnHeightLg 
            : AppSizes.btnHeightMd;
            
    final double fontSize = size == AppButtonSize.sm ? 13 : size == AppButtonSize.lg ? 16 : 14;
    final double hPad = size == AppButtonSize.sm ? 14 : size == AppButtonSize.lg ? 24 : 18;

    Widget content = child ?? Text(
      label ?? '',
      style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600),
    );

    if (variant == AppButtonVariant.gradient) {
      return SizedBox(
        height: height,
        width: fullWidth ? double.infinity : null,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: disabled ? null : AppColors.primaryGradient,
            color: disabled ? AppColors.border : null,
            borderRadius: BorderRadius.circular(AppSizes.r12),
          ),
          child: TextButton(
            onPressed: disabled ? null : onPressed,
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: hPad),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.r12)),
            ),
            child: content,
          ),
        ),
      );
    }

    Color bg, fg;
    Border? border;

    switch (variant) {
      case AppButtonVariant.secondary:
        bg = AppColors.muted;
        fg = AppColors.secondary;
        border = null;
        break;
      case AppButtonVariant.ghost:
        bg = Colors.transparent;
        fg = AppColors.secondary;
        border = null;
        break;
      case AppButtonVariant.danger:
        bg = AppColors.destructive.withOpacity(0.1);
        fg = AppColors.destructive;
        border = null;
        break;
      default:
        bg = AppColors.primary;
        fg = Colors.white;
        border = null;
    }

    return SizedBox(
      height: height,
      width: fullWidth ? double.infinity : null,
      child: TextButton(
        onPressed: disabled ? null : onPressed,
        style: TextButton.styleFrom(
          backgroundColor: disabled ? AppColors.border : bg,
          foregroundColor: disabled ? AppColors.mutedForeground : fg,
          padding: EdgeInsets.symmetric(horizontal: hPad),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.r12),
            side: border != null ? const BorderSide(color: AppColors.border) : BorderSide.none,
          ),
        ),
        child: content,
      ),
    );
  }
}
