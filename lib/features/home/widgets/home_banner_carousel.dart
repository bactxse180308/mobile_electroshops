import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

class HomeBannerCarousel extends StatefulWidget {
  final List<String> bannerImages;
  const HomeBannerCarousel({super.key, required this.bannerImages});

  @override
  State<HomeBannerCarousel> createState() => _HomeBannerCarouselState();
}

class _HomeBannerCarouselState extends State<HomeBannerCarousel> {
  int _bannerIndex = 0;
  Timer? _bannerTimer;

  @override
  void initState() {
    super.initState();
    if (widget.bannerImages.isNotEmpty) {
      _bannerTimer = Timer.periodic(const Duration(seconds: 4), (_) {
        if (mounted) {
          setState(() => _bannerIndex = (_bannerIndex + 1) % widget.bannerImages.length);
        }
      });
    }
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.bannerImages.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        AspectRatio(
          aspectRatio: 2,
          child: PageView.builder(
            itemCount: widget.bannerImages.length,
            onPageChanged: (index) => setState(() => _bannerIndex = index),
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: PageController(), // Just standard display
                builder: (context, child) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: AppSizes.p16, vertical: AppSizes.p8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppSizes.r16),
                      image: DecorationImage(
                        image: NetworkImage(widget.bannerImages[index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.bannerImages.length,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _bannerIndex == index ? 16 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _bannerIndex == index ? AppColors.primary : AppColors.mutedForeground.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
