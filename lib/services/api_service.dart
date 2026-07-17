import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/api_models.dart';

/// Service trung tâm để giao tiếp với Spring Boot backend.
class ApiService {
  // true -> Emulator (10.0.2.2). false -> Máy thật (IP LAN 192.168.1.11 của PC).
  static const bool _useEmulator = false;
  // Truyền lúc chạy: flutter run --dart-define=API_HOST=192.168.x.x
  static const String _lanHost =
      String.fromEnvironment('API_HOST', defaultValue: '192.168.1.11');
  static String get _androidHost => _useEmulator ? '10.0.2.2' : _lanHost;

  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8080/api/v1';
    try {
      return Platform.isAndroid
          ? 'http://$_androidHost:8080/api/v1'
          : 'http://localhost:8080/api/v1';
    } catch (_) {
      return 'http://localhost:8080/api/v1';
    }
  }

  static const Duration _timeout = Duration(seconds: 15);

  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // ── Token helper ─────────────────────────────────────────────────────────
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  // Refresh token mechanism to handle access token expiration (401 Unauthorized)
  bool _isRefreshing = false;
  Future<String?>? _refreshTokenFuture;

  Future<String?> _refreshAccessToken() async {
    if (_isRefreshing) {
      debugPrint('[API] Waiting for existing token refresh operation...');
      return _refreshTokenFuture;
    }

    _isRefreshing = true;
    final completer = Completer<String?>();
    _refreshTokenFuture = completer.future;

    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refresh_token');
      if (refreshToken == null) {
        debugPrint('[API] Refresh token not found in storage.');
        completer.complete(null);
        return null;
      }

      final uri = Uri.parse('$baseUrl/auth/refresh');
      debugPrint('[API] Refreshing access token...');
      final response = await http.post(
        uri,
        headers: _baseHeaders(),
        body: json.encode({'refreshToken': refreshToken}),
      ).timeout(_timeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = utf8.decode(response.bodyBytes);
        final decoded = json.decode(body) as Map<String, dynamic>;
        final data = decoded['data'] as Map<String, dynamic>;
        
        final newAccessToken = data['accessToken'] as String;
        final newRefreshToken = data['refreshToken'] as String?;

        await prefs.setString('access_token', newAccessToken);
        if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
          await prefs.setString('refresh_token', newRefreshToken);
        }
        
        debugPrint('[API] Access token refreshed successfully.');
        completer.complete(newAccessToken);
      } else {
        debugPrint('[API] Failed to refresh token: ${response.statusCode}');
        // Clear expired tokens so the user is forced to log in again
        await prefs.remove('access_token');
        await prefs.remove('refresh_token');
        completer.complete(null);
      }
    } catch (e) {
      debugPrint('[API] Error during token refresh: $e');
      completer.complete(null);
    } finally {
      _isRefreshing = false;
      _refreshTokenFuture = null;
    }

    return completer.future;
  }

  Map<String, String> _baseHeaders({String? token}) {
    final h = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      h['Authorization'] = 'Bearer $token';
    }
    return h;
  }

  // ── HTTP Helpers ──────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> _get(String path, {Map<String, String?>? params}) async {
    final cleanParams = <String, String>{};
    params?.forEach((k, v) { if (v != null) cleanParams[k] = v; });
    final uri = Uri.parse('$baseUrl$path').replace(
      queryParameters: cleanParams.isEmpty ? null : cleanParams,
    );
    debugPrint('[API] GET $uri');
    return _send(http.get(uri, headers: _baseHeaders()), path);
  }

  Future<Map<String, dynamic>> _authGet(String path, {Map<String, String?>? params}) async {
    final token = await _getToken();
    final cleanParams = <String, String>{};
    params?.forEach((k, v) { if (v != null) cleanParams[k] = v; });
    final uri = Uri.parse('$baseUrl$path').replace(
      queryParameters: cleanParams.isEmpty ? null : cleanParams,
    );
    debugPrint('[API] GET(auth) $uri');
    try {
      return await _send(http.get(uri, headers: _baseHeaders(token: token)), path);
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        final newToken = await _refreshAccessToken();
        if (newToken != null) {
          debugPrint('[API] Retrying GET(auth) $uri with new token');
          return await _send(http.get(uri, headers: _baseHeaders(token: newToken)), path);
        }
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _authPost(String path, Map<String, dynamic> body, {Map<String, String?>? params}) async {
    final token = await _getToken();
    final cleanParams = <String, String>{};
    params?.forEach((k, v) { if (v != null) cleanParams[k] = v; });
    final uri = Uri.parse('$baseUrl$path').replace(
      queryParameters: cleanParams.isEmpty ? null : cleanParams,
    );
    debugPrint('[API] POST(auth) $uri');
    try {
      return await _send(
        http.post(uri, headers: _baseHeaders(token: token), body: json.encode(body)),
        path,
      );
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        final newToken = await _refreshAccessToken();
        if (newToken != null) {
          debugPrint('[API] Retrying POST(auth) $uri with new token');
          return await _send(
            http.post(uri, headers: _baseHeaders(token: newToken), body: json.encode(body)),
            path,
          );
        }
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _authPatch(String path, {Map<String, String?>? params}) async {
    final token = await _getToken();
    final cleanParams = <String, String>{};
    params?.forEach((k, v) { if (v != null) cleanParams[k] = v; });
    final uri = Uri.parse('$baseUrl$path').replace(
      queryParameters: cleanParams.isEmpty ? null : cleanParams,
    );
    debugPrint('[API] PATCH(auth) $uri');
    try {
      return await _send(http.patch(uri, headers: _baseHeaders(token: token)), path);
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        final newToken = await _refreshAccessToken();
        if (newToken != null) {
          debugPrint('[API] Retrying PATCH(auth) $uri with new token');
          return await _send(http.patch(uri, headers: _baseHeaders(token: newToken)), path);
        }
      }
      rethrow;
    }
  }

  Future<void> _authDelete(String path, {Map<String, String?>? params}) async {
    final token = await _getToken();
    final cleanParams = <String, String>{};
    params?.forEach((k, v) { if (v != null) cleanParams[k] = v; });
    final uri = Uri.parse('$baseUrl$path').replace(
      queryParameters: cleanParams.isEmpty ? null : cleanParams,
    );
    debugPrint('[API] DELETE(auth) $uri');

    Future<void> sendRequest(String? currentToken) async {
      try {
        final response = await http
            .delete(uri, headers: _baseHeaders(token: currentToken))
            .timeout(_timeout);
        debugPrint('[API] ${response.statusCode} ← $path');
        if (response.statusCode >= 200 && response.statusCode < 300) return;
        final body = utf8.decode(response.bodyBytes);
        debugPrint('[API] Error body: $body');
        throw ApiException(
          statusCode: response.statusCode,
          message: 'HTTP ${response.statusCode}',
        );
      } on SocketException catch (e) {
        throw ApiException(statusCode: 0, message: 'Không thể kết nối server: $e');
      } on ApiException {
        rethrow;
      } catch (e) {
        throw ApiException(statusCode: 0, message: e.toString());
      }
    }

    try {
      await sendRequest(token);
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        final newToken = await _refreshAccessToken();
        if (newToken != null) {
          debugPrint('[API] Retrying DELETE(auth) $uri with new token');
          await sendRequest(newToken);
          return;
        }
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _send(Future<http.Response> req, String path) async {
    try {
      final response = await req.timeout(_timeout);
      debugPrint('[API] ${response.statusCode} ← $path');
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = utf8.decode(response.bodyBytes);
        return json.decode(body) as Map<String, dynamic>;
      }
      final body = utf8.decode(response.bodyBytes);
      debugPrint('[API] Error body: $body');
      throw ApiException(
        statusCode: response.statusCode,
        message: 'HTTP ${response.statusCode}: ${response.reasonPhrase}',
      );
    } on SocketException catch (e) {
      debugPrint('[API] SocketException: $e → $path');
      throw ApiException(
        statusCode: 0,
        message: 'Không thể kết nối server. Kiểm tra BE đang chạy.',
      );
    } on http.ClientException catch (e) {
      throw ApiException(statusCode: 0, message: e.message);
    } on ApiException {
      rethrow;
    } catch (e) {
      debugPrint('[API] Unknown error: $e');
      throw ApiException(statusCode: 0, message: e.toString());
    }
  }

  // ── Products ─────────────────────────────────────────────────────────────

  Future<ApiPage<ApiProductResponse>> getProducts({
    String? keyword,
    int? categoryId,
    int? brandId,
    int page = 0,
    int size = 20,
    String? sort,
  }) async {
    final j = await _get('/products', params: {
      if (keyword != null && keyword.isNotEmpty) 'keyword': keyword,
      if (categoryId != null) 'categoryId': categoryId.toString(),
      if (brandId != null) 'brandId': brandId.toString(),
      'page': page.toString(),
      'size': size.toString(),
      if (sort != null) 'sort': sort,
    });
    final data = j['data'] as Map<String, dynamic>;
    return ApiPage.fromJson(data, ApiProductResponse.fromJson);
  }

  Future<ApiProductResponse> getProductById(int id) async {
    final j = await _get('/products/$id');
    return ApiProductResponse.fromJson(j['data'] as Map<String, dynamic>);
  }

  // ── Categories ───────────────────────────────────────────────────────────

  Future<List<ApiCategoryResponse>> getCategories({int size = 100}) async {
    final j = await _get('/categories', params: {'page': '0', 'size': size.toString()});
    final data = j['data'] as Map<String, dynamic>;
    return ApiPage.fromJson(data, ApiCategoryResponse.fromJson).content;
  }

  // ── Brands ───────────────────────────────────────────────────────────────

  Future<List<ApiBrandResponse>> getBrands({int size = 100}) async {
    final j = await _get('/brands', params: {'page': '0', 'size': size.toString()});
    final data = j['data'] as Map<String, dynamic>;
    return ApiPage.fromJson(data, ApiBrandResponse.fromJson).content;
  }

  // ── Attributes & Reviews ─────────────────────────────────────────────────

  Future<List<ApiProductAttributeResponse>> getProductAttributes(int productId) async {
    final j = await _get('/product-attributes/product/$productId');
    final data = j['data'] as List<dynamic>? ?? [];
    return data.map((e) => ApiProductAttributeResponse.fromJson(e)).toList();
  }

  Future<ApiPage<ApiReviewResponse>> getProductReviews(
    int productId, {
    int page = 0,
    int size = 20,
  }) async {
    final j = await _get('/reviews', params: {
      'productId': productId.toString(),
      'page': page.toString(),
      'size': size.toString(),
    });
    return ApiPage.fromJson(
      j['data'] as Map<String, dynamic>,
      ApiReviewResponse.fromJson,
    );
  }

  Future<ApiRatingStatsResponse> getProductRatingStats(int productId) async {
    final j = await _get('/reviews/product/$productId/rating-stats');
    return ApiRatingStatsResponse.fromJson(j['data'] as Map<String, dynamic>);
  }

  // ── Cart ─────────────────────────────────────────────────────────────────

  /// Lấy giỏ hàng của user (yêu cầu đăng nhập)
  Future<ApiCartResponse> getCart(int userId) async {
    final j = await _authGet('/cart/$userId');
    return ApiCartResponse.fromJson(j['data'] as Map<String, dynamic>);
  }

  /// Thêm sản phẩm vào giỏ
  Future<ApiCartResponse> addToCart(
    int userId,
    int productId,
    int quantity,
  ) async {
    final j = await _authPost('/cart/$userId/items', {
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
    final j = await _authPatch(
      '/cart/$userId/items/$productId',
      params: {'quantity': quantity.toString()},
    );
    return ApiCartResponse.fromJson(j['data'] as Map<String, dynamic>);
  }

  /// Xoá sản phẩm khỏi giỏ
  Future<void> removeCartItem(int userId, int productId) async {
    await _authDelete('/cart/$userId/items/$productId');
  }

  /// Xoá toàn bộ giỏ hàng
  Future<void> clearCart(int userId) async {
    await _authDelete('/cart/$userId');
  }

  // ── Order API ─────────────────────────────────────────────────────────────

  /// Tạo đơn hàng mới — BE: POST /orders?userId={userId}
  Future<OrderResponse> createOrder(
    CreateOrderRequest request,
    int userId,
  ) async {
    final j = await _authPost('/orders', request.toJson(), params: {'userId': userId.toString()});
    return OrderResponse.fromJson(j['data'] as Map<String, dynamic>);
  }

  /// Lấy danh sách đơn hàng của user
  Future<ApiPage<OrderResponse>> getMyOrders(
    int userId,
    String token, {
    int page = 0,
    int size = 10,
  }) async {
    final j = await _authGet('/orders/user/$userId', params: {
      'page': '$page',
      'size': '$size',
    });
    return ApiPage.fromJson(
      j['data'] as Map<String, dynamic>,
      (e) => OrderResponse.fromJson(e as Map<String, dynamic>),
    );

  }

  /// Lấy chi tiết đơn hàng theo ID
  Future<OrderResponse> getOrderById(int id, String token) async {
    final j = await _authGet('/orders/$id');
    return OrderResponse.fromJson(j['data'] as Map<String, dynamic>);
  }

  /// Hủy đơn hàng
  Future<void> cancelOrder(int id, String token) async {
    await _authPatch('/orders/$id/cancel');
  }

  // ── Payment ───────────────────────────────────────────────────────────────

  /// Tạo VNPay payment URL — BE: POST /payments/vnpay/create
  Future<String> createVNPayUrl(int orderId) async {
    final j = await _authPost(
      '/payments/vnpay/create',
      {},
      params: {
        'orderId': orderId.toString(),
        'type': 'NORMAL',
      },
    );
    final data = j['data'] as Map<String, dynamic>;
    return data['paymentUrl'] as String;
  }
}


// ── Exception ────────────────────────────────────────────────────────────────
class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException($statusCode): $message';
}
