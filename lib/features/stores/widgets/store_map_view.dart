import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/goong_config.dart';
import 'location_permission_banner.dart';

class StoreMapView extends StatelessWidget {
  final LatLng defaultCameraTarget;
  final LatLng? userLocation;
  final bool isMapReady;
  final bool isLocating;
  final String? locationMessage;
  final void Function(MapLibreMapController controller) onMapCreated;
  final VoidCallback onStyleLoaded;

  const StoreMapView({
    super.key,
    required this.defaultCameraTarget,
    required this.userLocation,
    required this.isMapReady,
    required this.isLocating,
    required this.locationMessage,
    required this.onMapCreated,
    required this.onStyleLoaded,
  });

  @override
  Widget build(BuildContext context) {
    if (!GoongConfig.hasMapTilesKey) {
      return const _MapFallback(
        title: 'Thiếu Goong Maptiles key',
        message: 'Vui lòng cấu hình GOONG_MAPTILES_KEY trong file .env.',
      );
    }

    return Stack(
      children: [
        Positioned.fill(
          child: MapLibreMap(
            styleString: GoongConfig.styleUrl,
            initialCameraPosition: CameraPosition(
              target: defaultCameraTarget,
              zoom: 12.5,
            ),
            compassEnabled: false,
            myLocationEnabled: userLocation != null,
            onMapCreated: onMapCreated,
            onStyleLoadedCallback: onStyleLoaded,
          ),
        ),
        if (!isMapReady || isLocating)
          Positioned(
            left: AppSizes.p16,
            top: AppSizes.p16,
            child: _MapStatusPill(
              text: isLocating ? 'Đang lấy vị trí...' : 'Đang tải bản đồ...',
            ),
          ),
        if (locationMessage != null && !isLocating)
          Positioned(
            left: AppSizes.p16,
            right: AppSizes.p16,
            bottom: AppSizes.p16,
            child: LocationPermissionBanner(message: locationMessage!),
          ),
      ],
    );
  }
}

class _MapStatusPill extends StatelessWidget {
  final String text;

  const _MapStatusPill({required this.text});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.r12),
        boxShadow: AppShadows.card,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.p12,
          vertical: AppSizes.p8,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: AppSizes.p8),
            Text(text, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}

class _MapFallback extends StatelessWidget {
  final String title;
  final String message;

  const _MapFallback({
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.searchBgGradient),
      padding: const EdgeInsets.all(AppSizes.p20),
      child: Center(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppSizes.r16),
            boxShadow: AppShadows.card,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.p16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.map_outlined,
                  size: AppSizes.iconXl,
                  color: AppColors.primary,
                ),
                const SizedBox(height: AppSizes.p10),
                Text(title, style: AppTextStyles.h3),
                const SizedBox(height: AppSizes.p6),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
