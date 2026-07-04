import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/models.dart';
import 'store_action_buttons.dart';

class StoreCard extends StatelessWidget {
  final Store store;
  final bool active;
  final String distance;
  final VoidCallback onTap;
  final VoidCallback onCall;
  final VoidCallback onDirections;

  const StoreCard({
    super.key,
    required this.store,
    required this.active,
    required this.distance,
    required this.onTap,
    required this.onCall,
    required this.onDirections,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(AppSizes.p12),
        decoration: BoxDecoration(
          border: Border.all(
            color: active ? AppColors.primary : AppColors.border,
            width: active ? 1.5 : 1,
          ),
          color: active
              ? AppColors.primary.withValues(alpha: 0.06)
              : AppColors.background,
          borderRadius: BorderRadius.circular(AppSizes.r12),
          boxShadow: active ? AppShadows.card : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StoreIcon(active: active),
                const SizedBox(width: AppSizes.p10),
                Expanded(child: _StoreInfo(store: store, distance: distance)),
              ],
            ),
            if (active) ...[
              const SizedBox(height: AppSizes.p12),
              StoreActionButtons(
                onCall: onCall,
                onDirections: onDirections,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StoreIcon extends StatelessWidget {
  final bool active;

  const _StoreIcon({required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: active
            ? AppColors.primary
            : AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.r8),
      ),
      child: Icon(
        Icons.storefront_outlined,
        size: AppSizes.iconMd,
        color: active ? Colors.white : AppColors.primary,
      ),
    );
  }
}

class _StoreInfo extends StatelessWidget {
  final Store store;
  final String distance;

  const _StoreInfo({
    required this.store,
    required this.distance,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                store.name,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.secondary,
                ),
              ),
            ),
            const _OpenBadge(),
          ],
        ),
        const SizedBox(height: AppSizes.p4),
        Text(
          store.address,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.mutedForeground,
            height: 1.35,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSizes.p6),
        Wrap(
          spacing: AppSizes.p8,
          runSpacing: AppSizes.p4,
          children: [
            _StoreMeta(icon: Icons.access_time, text: store.hours),
            _StoreMeta(
              icon: Icons.near_me_outlined,
              text: distance,
              emphasized: true,
            ),
            _StoreMeta(
                icon: Icons.location_city_outlined, text: store.district),
          ],
        ),
      ],
    );
  }
}

class _StoreMeta extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool emphasized;

  const _StoreMeta({
    required this.icon,
    required this.text,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: AppSizes.iconXs,
          color: emphasized ? AppColors.primary : AppColors.mutedForeground,
        ),
        const SizedBox(width: AppSizes.p4),
        Text(
          text,
          style: TextStyle(
            fontSize: 11,
            color: emphasized ? AppColors.primary : AppColors.mutedForeground,
            fontWeight: emphasized ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _OpenBadge extends StatelessWidget {
  const _OpenBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.p6,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppSizes.r4),
      ),
      child: const Text(
        AppStrings.openStatus,
        style: TextStyle(
          color: AppColors.success,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
