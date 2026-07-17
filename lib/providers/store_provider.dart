import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import '../core/utils/map_utils.dart';
import '../data/seed_data.dart';
import '../models/models.dart';

class StoreProvider extends ChangeNotifier {
  static const String allCities = 'Tất cả';
  static const List<String> cityFilters = [allCities, 'TP.HCM', 'Hà Nội'];

  LatLng? _userLocation;
  String _selectedId = stores.first.id;
  String _cityFilter = allCities;
  String _query = '';
  String? _locationMessage;
  bool _isLocating = true;

  LatLng? get userLocation => _userLocation;
  String get selectedId => _selectedId;
  String get cityFilter => _cityFilter;
  String get query => _query;
  String? get locationMessage => _locationMessage;
  bool get isLocating => _isLocating;

  List<String> get cities => cityFilters;

  Future<void> loadUserLocation() async {
    _isLocating = true;
    _locationMessage = null;
    notifyListeners();

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
      _userLocation = LatLng(position.latitude, position.longitude);
      _isLocating = false;
      _ensureSelectedVisible();
      notifyListeners();
    } catch (_) {
      _setLocationUnavailable(
        'Không thể lấy vị trí hiện tại. Vui lòng thử lại sau.',
      );
    }
  }

  void _setLocationUnavailable(String message) {
    _locationMessage = message;
    _isLocating = false;
    notifyListeners();
  }

  void setSearchQuery(String value) {
    _query = value;
    _ensureSelectedVisible();
    notifyListeners();
  }

  void clearSearch() {
    _query = '';
    _ensureSelectedVisible();
    notifyListeners();
  }

  void setCityFilter(String city) {
    _cityFilter = city;
    _ensureSelectedVisible();
    notifyListeners();
  }

  void selectStore(Store store) {
    _selectedId = store.id;
    notifyListeners();
  }

  void _ensureSelectedVisible() {
    final visible = visibleStores;
    if (visible.isEmpty) return;
    if (!visible.any((store) => store.id == _selectedId)) {
      _selectedId = visible.first.id;
    }
  }

  List<Store> get visibleStores {
    final q = _query.trim().toLowerCase();
    final result = stores.where((store) {
      final matchesCity =
          _cityFilter == allCities || store.city == _cityFilter;
      final searchable =
          '${store.name} ${store.district} ${store.city} ${store.address}'
              .toLowerCase();
      return matchesCity && (q.isEmpty || searchable.contains(q));
    }).toList();

    final location = _userLocation;
    if (location != null) {
      result.sort((a, b) {
        final distanceA = distanceFromUser(a);
        final distanceB = distanceFromUser(b);
        return distanceA.compareTo(distanceB);
      });
    }
    return result;
  }

  Store? get selectedStore {
    final visible = visibleStores;
    if (visible.isEmpty) return null;
    return visible.firstWhere(
      (store) => store.id == _selectedId,
      orElse: () => visible.first,
    );
  }

  double distanceFromUser(Store store) {
    final location = _userLocation;
    if (location == null) return double.infinity;
    return calculateDistanceKm(
      location.latitude,
      location.longitude,
      store.lat,
      store.lng,
    );
  }
}
