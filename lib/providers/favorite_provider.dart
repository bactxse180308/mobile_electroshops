import 'package:flutter/foundation.dart';
import '../models/api_models.dart';
import '../services/api_service.dart';
import '../services/wishlist_service.dart';

class FavoriteProvider extends ChangeNotifier {
  final WishlistService _wishlistService = WishlistService();
  
  ApiWishlistResponse? _wishlist;
  bool _isLoading = false;
  String? _error;
  
  // Set of product IDs currently in the wishlist for fast lookup
  final Set<int> _favoriteIds = {};

  bool get isLoading => _isLoading;
  String? get error => _error;
  Set<int> get favoriteIds => _favoriteIds;
  List<ApiWishlistItemResponse> get items => _wishlist?.items ?? [];

  bool isFavorite(int productId) => _favoriteIds.contains(productId);

  Future<void> loadWishlist(int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _wishlist = await _wishlistService.getByUser(userId);
      _favoriteIds.clear();
      if (_wishlist != null) {
        _favoriteIds.addAll(_wishlist!.items.map((i) => i.productId));
      }
    } on ApiException catch (e) {
      _error = e.message;
      _wishlist = null;
      _favoriteIds.clear();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(int userId, int productId) async {
    // Optimistic update
    final wasFavorite = _favoriteIds.contains(productId);
    if (wasFavorite) {
      _favoriteIds.remove(productId);
    } else {
      _favoriteIds.add(productId);
    }
    notifyListeners();

    try {
      if (wasFavorite) {
        await _wishlistService.removeItem(userId, productId);
      } else {
        await _wishlistService.addItem(userId, productId);
      }
      // Silently reload to ensure sync
      _wishlist = await _wishlistService.getByUser(userId);
      _favoriteIds.clear();
      _favoriteIds.addAll(_wishlist!.items.map((i) => i.productId));
    } on ApiException catch (e) {
      // Rollback on failure
      if (wasFavorite) {
        _favoriteIds.add(productId);
      } else {
        _favoriteIds.remove(productId);
      }
      _error = e.message;
      notifyListeners();
      rethrow;
    }
  }

  void reset() {
    _wishlist = null;
    _favoriteIds.clear();
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}
