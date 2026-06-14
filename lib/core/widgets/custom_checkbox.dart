import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class CustomCheckbox extends StatelessWidget {
  final bool checked;
  final VoidCallback onTap;

  const CustomCheckbox({
    super.key,
    required this.checked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 20,
        height: 20,
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
