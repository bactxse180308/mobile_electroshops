import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/map_utils.dart';
import '../../../core/widgets/top_app_bar.dart';
import '../../../models/models.dart';
import '../../../providers/store_provider.dart';
import '../widgets/store_bottom_sheet.dart';
import '../widgets/store_map_view.dart';

class StoresScreen extends StatefulWidget {
  const StoresScreen({super.key});

  @override
  State<StoresScreen> createState() => _StoresScreenState();
}

class _StoresScreenState extends State<StoresScreen> {
  static const _defaultCameraTarget = LatLng(10.7769, 106.7009);

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _listController = ScrollController();
  final Map<String, String> _symbolStoreIds = {};

  MapLibreMapController? _mapController;
  bool _isMapReady = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<StoreProvider>();
      provider.loadUserLocation().then((_) {
        final location = provider.userLocation;
        if (location != null) {
          _mapController?.animateCamera(
            CameraUpdate.newLatLngZoom(location, 13),
          );
        }
        _refreshMarkersSoon();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _listController.dispose();
    _mapController?.onSymbolTapped.remove(_onSymbolTapped);
    _mapController = null;
    super.dispose();
  }

  void _onMapCreated(MapLibreMapController controller) {
    _mapController = controller;
    controller.onSymbolTapped.add(_onSymbolTapped);
  }

  void _onStyleLoaded() {
    setState(() => _isMapReady = true);
    _refreshMarkersSoon();
  }

  void _onSymbolTapped(Symbol symbol) {
    final storeId = _symbolStoreIds[symbol.id];
    if (storeId == null) return;

    final provider = context.read<StoreProvider>();
    final visibleStores = provider.visibleStores;
    if (visibleStores.isEmpty) return;

    final store = visibleStores.firstWhere(
      (item) => item.id == storeId,
      orElse: () => visibleStores.first,
    );
    _selectStore(provider, store, scrollToCard: true);
  }

  void _setSearchQuery(StoreProvider provider, String value) {
    provider.setSearchQuery(value);
    _refreshMarkersSoon();
  }

  void _clearSearch(StoreProvider provider) {
    _searchController.clear();
    provider.clearSearch();
    _refreshMarkersSoon();
  }

  void _setCityFilter(StoreProvider provider, String city) {
    provider.setCityFilter(city);
    _refreshMarkersSoon();

    final store = provider.selectedStore;
    if (store != null) _moveCameraToStore(store);
  }

  void _selectStore(StoreProvider provider, Store store, {bool scrollToCard = false}) {
    provider.selectStore(store);
    _moveCameraToStore(store);
    if (scrollToCard) _scrollToStore(provider, store);
    _refreshMarkersSoon();
  }

  Future<void> _moveCameraToStore(Store store) async {
    await _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(store.lat, store.lng), 15),
    );
  }

  Future<void> _focusUserLocation(StoreProvider provider) async {
    final location = provider.userLocation;
    if (location == null) {
      await provider.loadUserLocation();
      if (!mounted) return;
      if (provider.userLocation == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.locationMessage ?? 'Chưa có vị trí hiện tại.'),
          ),
        );
      } else {
        await _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(provider.userLocation!, 14),
        );
        _refreshMarkersSoon();
      }
      return;
    }

    await _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(location, 14),
    );
  }

  void _scrollToStore(StoreProvider provider, Store store) {
    final index = provider.visibleStores.indexWhere((item) => item.id == store.id);
    if (index < 0 || !_listController.hasClients) return;
    _listController.animateTo(
      index * 138,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  void _refreshMarkersSoon() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _refreshMarkers();
    });
  }

  Future<void> _refreshMarkers() async {
    final controller = _mapController;
    if (controller == null || !_isMapReady) return;

    final provider = context.read<StoreProvider>();
    await controller.clearSymbols();
    _symbolStoreIds.clear();

    for (final store in provider.visibleStores) {
      final active = store.id == provider.selectedId;
      final symbol = await controller.addSymbol(
        SymbolOptions(
          geometry: LatLng(store.lat, store.lng),
          textField: '●',
          textSize: active ? 34 : 26,
          textColor: active ? '#2563EB' : '#1E293B',
          textHaloColor: '#FFFFFF',
          textHaloWidth: active ? 2.6 : 2,
        ),
      );
      _symbolStoreIds[symbol.id] = store.id;
    }
  }

  Future<void> _callStore(Store store) async {
    try {
      await openDialer(store.phone);
    } catch (_) {
      if (!mounted) return;
      _showSnackBar('Không thể mở trình gọi điện.');
    }
  }

  Future<void> _openDirections(Store store) async {
    try {
      await openGoogleMaps(store.lat, store.lng, store.name);
    } catch (_) {
      if (!mounted) return;
      _showSnackBar('Không thể mở Google Maps.');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _formatDistance(Store store, StoreProvider provider) {
    if (provider.userLocation == null) return store.city;
    final distance = provider.distanceFromUser(store);
    if (distance == double.infinity) return store.city;
    if (distance < 1) return '${(distance * 1000).round()} m';
    return '${distance.toStringAsFixed(distance < 10 ? 1 : 0)} km';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StoreProvider>();

    return Scaffold(
      appBar: ElectroAppBar(
        title: AppStrings.ourStores,
        right: IconButton(
          icon: const Icon(
            Icons.my_location_outlined,
            size: AppSizes.iconLg,
            color: AppColors.secondary,
          ),
          onPressed: () => _focusUserLocation(provider),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 6,
            child: StoreMapView(
              defaultCameraTarget: _defaultCameraTarget,
              userLocation: provider.userLocation,
              isMapReady: _isMapReady,
              isLocating: provider.isLocating,
              locationMessage: provider.locationMessage,
              onMapCreated: _onMapCreated,
              onStyleLoaded: _onStyleLoaded,
            ),
          ),
          Expanded(
            flex: 5,
            child: StoreBottomSheet(
              stores: provider.visibleStores,
              cities: provider.cities,
              selectedCity: provider.cityFilter,
              selectedStoreId: provider.selectedId,
              query: provider.query,
              hasUserLocation: provider.userLocation != null,
              searchController: _searchController,
              listController: _listController,
              onSearchChanged: (val) => _setSearchQuery(provider, val),
              onSearchClear: () => _clearSearch(provider),
              onCityChanged: (val) => _setCityFilter(provider, val),
              onStoreTap: (store) => _selectStore(provider, store),
              onCall: _callStore,
              onDirections: _openDirections,
              distanceLabelBuilder: (store) => _formatDistance(store, provider),
            ),
          ),
        ],
      ),
    );
  }
}
