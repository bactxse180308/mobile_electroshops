import '../models/api_models.dart';
import 'api_service.dart';

class OrderService {
  final ApiService _api = ApiService();

  /// Tạo đơn hàng mới — BE: POST /orders?userId={userId}
  Future<OrderResponse> createOrder(
    CreateOrderRequest request,
    int userId,
  ) async {
    final j = await _api.authPost('/orders', request.toJson(),
        params: {'userId': userId.toString()});
    return OrderResponse.fromJson(j['data'] as Map<String, dynamic>);
  }

  /// Lấy danh sách đơn hàng của user
  Future<ApiPage<OrderResponse>> getMyOrders(
    int userId,
    String token, {
    int page = 0,
    int size = 10,
    String? status,
  }) async {
    final j = await _api.authGet('/orders/user/$userId', params: {
      'page': '$page',
      'size': '$size',
      if (status != null) 'status': status,
    });
    return ApiPage.fromJson(
      j['data'] as Map<String, dynamic>,
      OrderResponse.fromJson,
    );
  }

  /// Lấy chi tiết đơn hàng theo ID
  Future<OrderResponse> getOrderById(int id, String token) async {
    final j = await _api.authGet('/orders/$id');
    return OrderResponse.fromJson(j['data'] as Map<String, dynamic>);
  }

  /// Hủy đơn hàng
  Future<void> cancelOrder(int id, String token) async {
    await _api.authPatch('/orders/$id/cancel');
  }
}
