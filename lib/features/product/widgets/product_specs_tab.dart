import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../models/api_models.dart';

class ProductSpecsTab extends StatelessWidget {
  final List<ApiProductAttributeResponse> attributes;

  const ProductSpecsTab({super.key, required this.attributes});

  @override
  Widget build(BuildContext context) {
    if (attributes.isEmpty) {
      return const Text(
        AppStrings.specsPlaceholder,
        style: TextStyle(fontSize: 13, color: AppColors.mutedForeground),
      );
    }
    return Column(
      children: attributes
          .map((e) => Container(
                padding: const EdgeInsets.symmetric(vertical: AppSizes.p10),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.border)),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 110,
                      child: Text(
                        e.attributeName,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.mutedForeground,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSizes.p12),
                    Expanded(
                      child: Text(
                        e.attributeValue,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}
