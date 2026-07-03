import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/map_utils.dart';
import '../../../core/widgets/top_app_bar.dart';
import '../../../data/seed_data.dart';
import '../../../models/models.dart';
import '../widgets/store_bottom_sheet.dart';
import '../widgets/store_map_view.dart';

class StoresScreen extends StatefulWidget {
  const StoresScreen({super.key});

  @override
  State<StoresScreen> createState() => _StoresScreenState();
}

class _StoresScreenState extends State<StoresScreen> {
  static const _allCities = 'Tất cả';
  static const _cityFilters = [_allCities, 'TP.HCM', 'Hà Nội'];
  static const _defaultCameraTarget = LatLng(10.7769, 106.7009);

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _listController = ScrollController();
  final Map<String, String> _symbolStoreIds = {};

  MapLibreMapController? _mapController;
  LatLng? _userLocation;
  String _selectedId = stores.first.id;
  String _cityFilter = _allCities;
  String _query = '';
  String? _locationMessage;
  bool _isLocating = true;
  bool _isMapReady = false;

  @override
  void initState() {
    super.initState();
    _loadUserLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _listController.dispose();
    _mapController?.onSymbolTapped.remove(_onSymbolTapped);
    _mapController = null;
    super.dispose();
  }

  List<Store> get _visibleStores {
    final query = _query.trim().toLowerCase();
    final result = stores.where((store) {
      final matchesCity =
          _cityFilter == _allCities || store.city == _cityFilter;
      final searchable =
          '${store.name} ${store.district} ${store.city} ${store.address}'
              .toLowerCase();
      return matchesCity && (query.isEmpty || searchable.contains(query));
    }).toList();

    final location = _userLocation;
    if (location != null) {
      result.sort((a, b) {
        final distanceA = _distanceFromUser(a);
        final distanceB = _distanceFromUser(b);
        return distanceA.compareTo(distanceB);
      });
    }
    return result;
  }

  Store? get _selectedStore {
    final visibleStores = _visibleStores;
    if (visibleStores.isEmpty) return null;
    return visibleStores.firstWhere(
      (store) => store.id == _selectedId,
      orElse: () => visibleStores.first,
    );
  }

  Future<void> _loadUserLocation() async {
    setState(() {
      _isLocating = true;
      _locationMessage = null;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _setLocationUnavailable(
          'Dịch vụ vị trí đang tắt. Vẫn hiển thị danh sách cửa hàng.',
        );
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _setLocationUnavailable(
          'Bạn chưa cấp quyền vị trí. Cửa hàng vẫn hiển thị bình thường.',
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      final location = LatLng(position.latitude, position.longitude);

      if (!mounted) return;
      setState(() {
        _userLocation = location;
        _isLocating = false;
        _ensureSelectedVisible();
      });

      await _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(location, 13),
      );
      _refreshMarkersSoon();
    } catch (_) {
      _setLocationUnavailable(
        'Không thể lấy vị trí hiện tại. Vui lòng thử lại sau.',
      );
    }
  }

  void _setLocationUnavailable(String message) {
    if (!mounted) return;
    setState(() {
      _locationMessage = message;
      _isLocating = false;
    });
    _refreshMarkersSoon();
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

    final visibleStores = _visibleStores;
    if (visibleStores.isEmpty) return;

    final store = visibleStores.firstWhere(
      (item) => item.id == storeId,
      orElse: () => visibleStores.first,
    );
    _selectStore(store, scrollToCard: true);
  }

  void _setSearchQuery(String value) {
    setState(() {
      _query = value;
      _ensureSelectedVisible();
    });
    _refreshMarkersSoon();
  }

  void _clearSearch() {
    _searchController.clear();
    _setSearchQuery('');
  }

  void _setCityFilter(String city) {
    setState(() {
      _cityFilter = city;
      _ensureSelectedVisible();
    });
    _refreshMarkersSoon();

    final store = _selectedStore;
    if (store != null) _moveCameraToStore(store);
  }

  void _ensureSelectedVisible() {
    final visibleStores = _visibleStores;
    if (visibleStores.isEmpty) return;
    if (!visibleStores.any((store) => store.id == _selectedId)) {
      _selectedId = visibleStores.first.id;
    }
  }

  void _selectStore(Store store, {bool scrollToCard = false}) {
    setState(() => _selectedId = store.id);
    _moveCameraToStore(store);
    if (scrollToCard) _scrollToStore(store);
    _refreshMarkersSoon();
  }

  Future<void> _moveCameraToStore(Store store) async {
    await _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(store.lat, store.lng), 15),
    );
  }

  Future<void> _focusUserLocation() async {
    final location = _userLocation;
    if (location == null) {
      await _loadUserLocation();
      if (!mounted) return;
      if (_userLocation == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_locationMessage ?? 'Chưa có vị trí hiện tại.'),
          ),
        );
      }
      return;
    }

    await _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(location, 14),
    );
  }

  void _scrollToStore(Store store) {
    final index = _visibleStores.indexWhere((item) => item.id == store.id);
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

    await controller.clearSymbols();
    _symbolStoreIds.clear();

    for (final store in _visibleStores) {
      final active = store.id == _selectedId;
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

  String _distanceLabel(Store store) {
    if (_userLocation == null) return store.city;

    final distance = _distanceFromUser(store);
    if (distance < 1) return '${(distance * 1000).round()} m';
    return '${distance.toStringAsFixed(distance < 10 ? 1 : 0)} km';
  }

  double _distanceFromUser(Store store) {
    final location = _userLocation;
    if (location == null) return double.infinity;
    return calculateDistanceKm(
      location.latitude,
      location.longitude,
      store.lat,
      store.lng,
    );
  }

  @override
  Widget build(BuildContext context) {
    final visibleStores = _visibleStores;

    return Scaffold(
      appBar: ElectroAppBar(
        title: AppStrings.ourStores,
        right: IconButton(
          icon: const Icon(
            Icons.my_location_outlined,
            size: AppSizes.iconLg,
            color: AppColors.secondary,
          ),
          onPressed: _focusUserLocation,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 6,
            child: StoreMapView(
              defaultCameraTarget: _defaultCameraTarget,
              userLocation: _userLocation,
              isMapReady: _isMapReady,
              isLocating: _isLocating,
              locationMessage: _locationMessage,
              onMapCreated: _onMapCreated,
              onStyleLoaded: _onStyleLoaded,
            ),
          ),
          Expanded(
            flex: 5,
            child: StoreBottomSheet(
              stores: visibleStores,
              cities: _cityFilters,
              selectedCity: _cityFilter,
              selectedStoreId: _selectedId,
              query: _query,
              hasUserLocation: _userLocation != null,
              searchController: _searchController,
              listController: _listController,
              onSearchChanged: _setSearchQuery,
              onSearchClear: _clearSearch,
              onCityChanged: _setCityFilter,
              onStoreTap: _selectStore,
              onCall: _callStore,
              onDirections: _openDirections,
              distanceLabelBuilder: _distanceLabel,
            ),
          ),
        ],
      ),
    );
  }
}
