import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../models/models.dart';
import '../../../../models/api_models.dart';
import 'product_specs_tab.dart';
import 'product_reviews_tab.dart';

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
      return ProductSpecsTab(attributes: widget.attributes);
    }
    return ProductReviewsTab(
      product: widget.product,
      ratingStats: widget.ratingStats,
      reviews: widget.reviews,
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
