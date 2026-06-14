import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_theme.dart';

class ProductImages extends StatefulWidget {
  final List<String> images;
  const ProductImages({super.key, required this.images});

  @override
  State<ProductImages> createState() => _ProductImagesState();
}

class _ProductImagesState extends State<ProductImages> {
  int _imgIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
      return Container(
        height: 250,
        color: AppColors.muted,
        child: const Icon(Icons.image_not_supported, size: 64, color: AppColors.mutedForeground),
      );
    }

    return Column(
      children: [
        Stack(
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: GestureDetector(
                onHorizontalDragEnd: (d) {
                  if (d.primaryVelocity == null) return;
                  if (d.primaryVelocity! < -200 && _imgIndex < widget.images.length - 1) {
                    setState(() => _imgIndex++);
                  } else if (d.primaryVelocity! > 200 && _imgIndex > 0) {
                    setState(() => _imgIndex--);
                  }
                },
                child: Image.network(
                  widget.images[_imgIndex],
                  fit: BoxFit.cover,
                  loadingBuilder: (_, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      color: AppColors.muted,
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                      ),
                    );
                  },
                  errorBuilder: (_, __, ___) => Container(
                    color: AppColors.muted,
                    child: const Icon(Icons.image_not_supported, size: 64, color: AppColors.mutedForeground),
                  ),
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + AppSizes.p8,
              left: AppSizes.p12,
              child: _CircleBtn(icon: Icons.chevron_left, onTap: () => Navigator.pop(context)),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + AppSizes.p8,
              right: AppSizes.p12,
              child: Row(
                children: [
                  _CircleBtn(icon: Icons.favorite_border, onTap: () {}),
                  const SizedBox(width: AppSizes.p8),
                  _CircleBtn(icon: Icons.share_outlined, onTap: () {}),
                ],
              ),
            ),
            if (widget.images.length > 1)
              Positioned(
                bottom: AppSizes.p12,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    widget.images.length,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: i == _imgIndex ? 20 : AppSizes.p6,
                      height: AppSizes.p6,
                      decoration: BoxDecoration(
                        color: i == _imgIndex ? AppColors.primary : Colors.white70,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        if (widget.images.length > 1)
          SizedBox(
            height: 72,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16, vertical: AppSizes.p8),
              itemCount: widget.images.length,
              separatorBuilder: (_, __) => const SizedBox(width: AppSizes.p8),
              itemBuilder: (context, i) => GestureDetector(
                onTap: () => setState(() => _imgIndex = i),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    border: Border.all(color: i == _imgIndex ? AppColors.primary : Colors.transparent, width: 2),
                    borderRadius: BorderRadius.circular(AppSizes.r8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppSizes.r6),
                    child: Image.network(
                      widget.images[i],
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(color: AppColors.muted),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          boxShadow: AppShadows.card,
        ),
        child: Icon(icon, size: AppSizes.iconMd, color: AppColors.secondary),
      ),
    );
  }
}
