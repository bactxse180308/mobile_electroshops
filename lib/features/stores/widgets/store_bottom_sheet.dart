import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/models.dart';
import 'store_card.dart';
import 'store_filter_chips.dart';
import 'store_search_bar.dart';

class StoreBottomSheet extends StatelessWidget {
  final List<Store> stores;
  final List<String> cities;
  final String selectedCity;
  final String selectedStoreId;
  final String query;
  final bool hasUserLocation;
  final TextEditingController searchController;
  final ScrollController listController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSearchClear;
  final ValueChanged<String> onCityChanged;
  final ValueChanged<Store> onStoreTap;
  final ValueChanged<Store> onCall;
  final ValueChanged<Store> onDirections;
  final String Function(Store store) distanceLabelBuilder;

  const StoreBottomSheet({
    super.key,
    required this.stores,
    required this.cities,
    required this.selectedCity,
    required this.selectedStoreId,
    required this.query,
    required this.hasUserLocation,
    required this.searchController,
    required this.listController,
    required this.onSearchChanged,
    required this.onSearchClear,
    required this.onCityChanged,
    required this.onStoreTap,
    required this.onCall,
    required this.onDirections,
    required this.distanceLabelBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Color(0x20000000),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: AppSizes.p10),
            width: 42,
            height: AppSizes.p4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.p16,
              AppSizes.p10,
              AppSizes.p16,
              AppSizes.p8,
            ),
            child: Column(
              children: [
                _StoreSheetHeader(
                  count: stores.length,
                  hasUserLocation: hasUserLocation,
                ),
                const SizedBox(height: AppSizes.p10),
                StoreSearchBar(
                  controller: searchController,
                  query: query,
                  onChanged: onSearchChanged,
                  onClear: onSearchClear,
                ),
                const SizedBox(height: AppSizes.p10),
                StoreFilterChips(
                  cities: cities,
                  selectedCity: selectedCity,
                  onSelected: onCityChanged,
                ),
              ],
            ),
          ),
          Expanded(
            child: stores.isEmpty
                ? const _EmptyStores()
                : ListView.separated(
                    controller: listController,
                    padding: const EdgeInsets.fromLTRB(
                      AppSizes.p16,
                      0,
                      AppSizes.p16,
                      AppSizes.p16,
                    ),
                    itemCount: stores.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSizes.p10),
                    itemBuilder: (context, index) {
                      final store = stores[index];
                      return StoreCard(
                        store: store,
                        active: store.id == selectedStoreId,
                        distance: distanceLabelBuilder(store),
                        onTap: () => onStoreTap(store),
                        onCall: () => onCall(store),
                        onDirections: () => onDirections(store),
                      );
                    },
                  ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

class _StoreSheetHeader extends StatelessWidget {
  final int count;
  final bool hasUserLocation;

  const _StoreSheetHeader({
    required this.count,
    required this.hasUserLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            '$count ${AppStrings.storesCount}',
            style: AppTextStyles.h3,
          ),
        ),
        if (hasUserLocation)
          const Text(
            'Gần bạn nhất',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }
}

class _EmptyStores extends StatelessWidget {
  const _EmptyStores();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(AppSizes.p24),
        child: Text(
          'Không tìm thấy cửa hàng phù hợp.',
          style: TextStyle(color: AppColors.mutedForeground, fontSize: 13),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
