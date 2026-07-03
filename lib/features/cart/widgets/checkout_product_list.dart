import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../models/api_models.dart';
import 'checkout_item_row.dart';
import 'checkout_section.dart';

class CheckoutProductList extends StatelessWidget {
  final List<ApiCartItemResponse> items;

  const CheckoutProductList({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return CheckoutSection(
      title: '${AppStrings.productsTitle} (${items.length})',
      child: items.isEmpty
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSizes.p12),
              child: Text(
                'Chưa có sản phẩm nào được chọn.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.mutedForeground,
                ),
              ),
            )
          : Column(
              children:
                  items.map((item) => CheckoutItemRow(item: item)).toList(),
            ),
    );
  }
}
