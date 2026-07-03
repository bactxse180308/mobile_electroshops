import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

class StoreFilterChips extends StatelessWidget {
  final List<String> cities;
  final String selectedCity;
  final ValueChanged<String> onSelected;

  const StoreFilterChips({
    super.key,
    required this.cities,
    required this.selectedCity,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final city in cities) ...[
            _CityChip(
              label: city,
              selected: selectedCity == city,
              onTap: () => onSelected(city),
            ),
            if (city != cities.last) const SizedBox(width: AppSizes.p8),
          ],
        ],
      ),
    );
  }
}

class _CityChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CityChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primary.withValues(alpha: 0.12),
      backgroundColor: AppColors.muted,
      side: BorderSide(
        color: selected ? AppColors.primary : Colors.transparent,
      ),
      labelStyle: TextStyle(
        color: selected ? AppColors.primary : AppColors.secondary,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.r8),
      ),
    );
  }
}
