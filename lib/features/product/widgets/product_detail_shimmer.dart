import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';

class ProductDetailShimmer extends StatelessWidget {
  const ProductDetailShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Image area shimmer
          _AnimatedShimmer(
            child: Container(
              color: Colors.grey[300],
              height: MediaQuery.of(context).size.width,
              width: double.infinity,
            ),
          ),
          const SizedBox(height: AppSizes.p12),
          // Text shimmer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _AnimatedShimmer(
                  child: Container(
                    height: 28,
                    width: 160,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(AppSizes.r6),
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.p10),
                _AnimatedShimmer(
                  child: Container(
                    height: 16,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(AppSizes.r6),
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.p6),
                _AnimatedShimmer(
                  child: Container(
                    height: 16,
                    width: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(AppSizes.r6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedShimmer extends StatelessWidget {
  final Widget child;
  const _AnimatedShimmer({required this.child});

  @override
  Widget build(BuildContext context) => child;
}
