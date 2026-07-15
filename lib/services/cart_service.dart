import '../models/api_models.dart';
import 'api_service.dart';

class CartService {
  final ApiService _api = ApiService();

  /// Lấy giỏ hàng của user (yêu cầu đăng nhập)
  Future<ApiCartResponse> getCart(int userId) async {
    final j = await _api.authGet('/cart/$userId');
    return ApiCartResponse.fromJson(j['data'] as Map<String, dynamic>);
  }

  /// Thêm sản phẩm vào giỏ
  Future<ApiCartResponse> addToCart(
    int userId,
    int productId,
    int quantity,
  ) async {
    final j = await _api.authPost('/cart/$userId/items', {
      'productId': productId,
      'quantity': quantity,
    });
    return ApiCartResponse.fromJson(j['data'] as Map<String, dynamic>);
  }

  /// Cập nhật số lượng sản phẩm trong giỏ
  Future<ApiCartResponse> updateCartItem(
    int userId,
    int productId,
    int quantity,
  ) async {
    final j = await _api.authPatch(
      '/cart/$userId/items/$productId',
      params: {'quantity': quantity.toString()},
    );
    return ApiCartResponse.fromJson(j['data'] as Map<String, dynamic>);
  }

  /// Xoá sản phẩm khỏi giỏ
  Future<void> removeCartItem(int userId, int productId) async {
    await _api.authDelete('/cart/$userId/items/$productId');
  }

  /// Xoá toàn bộ giỏ hàng
  Future<void> clearCart(int userId) async {
    await _api.authDelete('/cart/$userId');
  }
}
