import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../models/models.dart';
import '../../../../models/api_models.dart';

class ProductTabContainer extends StatefulWidget {
  final Product product;
  final List<ApiProductAttributeResponse> attributes;
  final ApiRatingStatsResponse? ratingStats;
  final List<ApiReviewResponse> reviews;

  const ProductTabContainer({
    super.key,
    required this.product,
    required this.attributes,
    required this.ratingStats,
    required this.reviews,
  });

  @override
  State<ProductTabContainer> createState() => _ProductTabContainerState();
}

class _ProductTabContainerState extends State<ProductTabContainer> {
  String _tab = 'specs';

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(AppSizes.p16, AppSizes.p12, AppSizes.p16, 0),
      padding: const EdgeInsets.all(AppSizes.p16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.r12),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          Row(
            children: [
              _TabBtn(
                label: AppStrings.tabDesc,
                active: _tab == 'desc',
                onTap: () => setState(() => _tab = 'desc'),
              ),
              _TabBtn(
                label: AppStrings.tabSpecs,
                active: _tab == 'specs',
                onTap: () => setState(() => _tab = 'specs'),
              ),
              _TabBtn(
                label: '${AppStrings.tabReviews} (${widget.product.reviews})',
                active: _tab == 'rev',
                onTap: () => setState(() => _tab = 'rev'),
              ),
            ],
          ),
          const Divider(height: 1, color: AppColors.border),
          Padding(
            padding: const EdgeInsets.all(AppSizes.p16),
            child: _buildTabContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    if (_tab == 'desc') {
      final desc = widget.product.description;
      return Html(
        data: desc,
        style: {
          "body": Style(
            fontSize: FontSize(14.0),
            color: AppColors.secondary,
            lineHeight: LineHeight(1.6),
            padding: HtmlPaddings.zero,
            margin: Margins.zero,
          ),
        },
      );
    }
    if (_tab == 'specs') {
      if (widget.attributes.isEmpty) {
        return const Text(
          AppStrings.specsPlaceholder,
          style: TextStyle(fontSize: 13, color: AppColors.mutedForeground),
        );
      }
      return Column(
        children: widget.attributes
            .map((e) => Container(
                  padding: const EdgeInsets.symmetric(vertical: AppSizes.p10),
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 110,
                        child: Text(e.attributeName, style: const TextStyle(fontSize: 13, color: AppColors.mutedForeground)),
                      ),
                      const SizedBox(width: AppSizes.p12),
                      Expanded(
                        child: Text(
                          e.attributeValue,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.secondary),
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
      );
    }

    // Reviews tab
    final avgRating = widget.ratingStats?.averageRating ?? widget.product.rating;
    final totalRevs = widget.ratingStats?.totalReviews ?? widget.product.reviews;
    final rc = widget.ratingStats?.ratingCount ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Column(
              children: [
                Text(
                  avgRating.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.secondary),
                ),
                Row(
                  children: List.generate(
                    5,
                    (i) => Icon(
                      Icons.star,
                      size: 12,
                      color: i < avgRating.round() ? AppColors.accent : AppColors.border,
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.p4),
                Text('$totalRevs ${AppStrings.tabReviews.toLowerCase()}', style: const TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
              ],
            ),
            const SizedBox(width: AppSizes.p16),
            Expanded(
              child: Column(
                children: [5, 4, 3, 2, 1].map((s) {
                  final count = rc[s.toString()] ?? 0;
                  final pct = totalRevs > 0 ? count / totalRevs : 0.0;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Text('$s', style: const TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                        const SizedBox(width: AppSizes.p8),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: pct,
                              backgroundColor: AppColors.muted,
                              valueColor: const AlwaysStoppedAnimation(AppColors.accent),
                              minHeight: 6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.p16),
        if (widget.reviews.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: AppSizes.p16),
            child: Text(AppStrings.reviewsEmpty, style: TextStyle(fontSize: 13, color: AppColors.mutedForeground)),
          )
        else
          ...widget.reviews.map((r) => Padding(
                padding: const EdgeInsets.only(top: AppSizes.p12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(color: AppColors.border),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: AppSizes.p16,
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                          child: Text(
                            r.userName.isNotEmpty ? r.userName[0].toUpperCase() : 'U',
                            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 12),
                          ),
                        ),
                        const SizedBox(width: AppSizes.p8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      r.userName,
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.secondary),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (r.reviewDate != null)
                                    Text(
                                      r.reviewDate!.split('T')[0],
                                      style: const TextStyle(fontSize: 11, color: AppColors.mutedForeground),
                                    ),
                                ],
                              ),
                              Row(
                                children: List.generate(
                                  5,
                                  (i) => Icon(
                                    Icons.star,
                                    size: 11,
                                    color: i < r.rating ? AppColors.accent : AppColors.border,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.p6),
                    Text(r.comment, style: const TextStyle(fontSize: 12, color: AppColors.secondary)),
                    if (r.reply != null && r.reply!.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: AppSizes.p8),
                        padding: const EdgeInsets.all(AppSizes.p8),
                        decoration: BoxDecoration(color: AppColors.muted, borderRadius: BorderRadius.circular(AppSizes.r6)),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.support_agent, size: 14, color: AppColors.primary),
                            const SizedBox(width: AppSizes.p6),
                            Expanded(
                              child: Text(
                                r.reply!,
                                style: const TextStyle(fontSize: 12, color: AppColors.secondary),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              )),
      ],
    );
  }
}

class _TabBtn extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _TabBtn({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: AppSizes.btnHeightMd,
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: active ? AppColors.primary : Colors.transparent, width: 2)),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: active ? AppColors.primary : AppColors.mutedForeground,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
