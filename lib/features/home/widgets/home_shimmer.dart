import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/shimmer_box.dart';

class HomeShimmer extends StatelessWidget {
  const HomeShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner shimmer
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSizes.p16, AppSizes.p16, AppSizes.p16, 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.r16),
              child: const ShimmerBox(height: 160, width: double.infinity),
            ),
          ),
          const SizedBox(height: AppSizes.p20),
          // Category shimmer
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSizes.p16),
            child: ShimmerBox(height: 14, width: 80),
          ),
          const SizedBox(height: AppSizes.p12),
          SizedBox(
            height: 90,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
              itemCount: 6,
              separatorBuilder: (_, __) => const SizedBox(width: AppSizes.p12),
              itemBuilder: (_, __) => Column(
                children: const [
                  ShimmerBox(height: 56, width: 56, radius: AppSizes.r16),
                  SizedBox(height: AppSizes.p6),
                  ShimmerBox(height: 10, width: 48),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSizes.p20),
          // Product grid shimmer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: AppSizes.p12,
              mainAxisSpacing: AppSizes.p12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 0.52,
              children: List.generate(
                4,
                (_) => const ShimmerBox(
                  height: double.infinity,
                  width: double.infinity,
                  radius: AppSizes.r12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
