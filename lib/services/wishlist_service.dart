import '../models/api_models.dart';
import 'api_service.dart';

class WishlistService {
  final ApiService _api = ApiService();

  Future<ApiWishlistResponse> getByUser(int userId) async {
    final res = await _api.authGet('/wishlist/$userId');
    if (res['data'] != null) {
      return ApiWishlistResponse.fromJson(res['data']);
    }
    throw const ApiException(statusCode: 0, message: 'Dữ liệu không hợp lệ');
  }

  Future<ApiWishlistResponse> addItem(int userId, int productId) async {
    final res = await _api.authPost('/wishlist/$userId/items/$productId', {});
    if (res['data'] != null) {
      return ApiWishlistResponse.fromJson(res['data']);
    }
    throw const ApiException(statusCode: 0, message: 'Dữ liệu không hợp lệ');
  }

  Future<void> removeItem(int userId, int productId) async {
    await _api.authDelete('/wishlist/$userId/items/$productId');
  }

  Future<void> clearWishlist(int userId) async {
    await _api.authDelete('/wishlist/$userId');
  }

  Future<bool> isProductInWishlist(int userId, int productId) async {
    final res = await _api.authGet('/wishlist/$userId/items/$productId/check');
    if (res['data'] != null) {
      return res['data'] as bool;
    }
    return false;
  }
}
