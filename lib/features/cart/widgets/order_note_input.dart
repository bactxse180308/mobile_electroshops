import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import 'checkout_section.dart';

class OrderNoteInput extends StatelessWidget {
  final TextEditingController controller;

  const OrderNoteInput({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return CheckoutSection(
      title: AppStrings.orderNotes,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.p12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(10),
        ),
        child: TextFormField(
          controller: controller,
          maxLines: 3,
          minLines: 2,
          decoration: const InputDecoration(
            hintText: AppStrings.orderNotesHint,
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
          style: const TextStyle(fontSize: 13),
        ),
      ),
    );
  }
}
