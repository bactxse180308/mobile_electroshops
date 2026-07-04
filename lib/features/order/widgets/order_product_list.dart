import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/format_utils.dart';
import '../../../models/api_models.dart';

class OrderProductList extends StatelessWidget {
  final List<ApiOrderItemResponse> items;

  const OrderProductList({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSizes.p12),
        child: Text(
          'Đơn hàng chưa có sản phẩm.',
          style: TextStyle(fontSize: 13, color: AppColors.mutedForeground),
        ),
      );
    }

    return Column(
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.p12),
              child: _OrderProductRow(item: item),
            ),
          )
          .toList(),
    );
  }
}

class _OrderProductRow extends StatelessWidget {
  final ApiOrderItemResponse item;

  const _OrderProductRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ProductImage(imageUrl: item.productImage),
        const SizedBox(width: AppSizes.p12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.productName,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.secondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSizes.p4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'x${item.quantity}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.mutedForeground,
                    ),
                  ),
                  Text(
                    formatVND(item.unitPrice.round()),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProductImage extends StatelessWidget {
  final String? imageUrl;

  const _ProductImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.r8),
      child: url != null && url.isNotEmpty
          ? Image.network(
              url,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const _ImageFallback(),
            )
          : const _ImageFallback(),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      color: AppColors.muted,
      child: const Icon(
        Icons.image_not_supported_outlined,
        size: 22,
        color: AppColors.mutedForeground,
      ),
    );
  }
}
