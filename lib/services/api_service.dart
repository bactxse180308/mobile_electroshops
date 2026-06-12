import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/api_models.dart';

/// Service trung tâm để giao tiếp với Spring Boot backend.
class ApiService {
  // Đổi dòng bên dưới tuỳ theo môi trường test:
  static const String baseUrl = 'http://10.0.2.2:8080/api/v1';    // ← Android Emulator
  //static const String baseUrl = 'http://192.168.1.236:8080/api/v1';  // ← Device thật / Docker

  static const Duration _timeout = Duration(seconds: 15);

  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  Map<String, String> _authHeaders(String? token) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

  // ── HTTP Helper ──────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> _get(
    String path, {
    Map<String, String?>? params,
    String? token,
  }) async {
    final cleanParams = <String, String>{};
    params?.forEach((k, v) {
      if (v != null) cleanParams[k] = v;
    });

    final uri = Uri.parse('$baseUrl$path').replace(
      queryParameters: cleanParams.isEmpty ? null : cleanParams,
    );

    debugPrint('[API] GET $uri');

    try {
      final response = await http
          .get(uri, headers: _authHeaders(token))
          .timeout(_timeout);

      debugPrint('[API] ${response.statusCode} ← $path');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = utf8.decode(response.bodyBytes);
        return json.decode(body) as Map<String, dynamic>;
      } else {
        final body = utf8.decode(response.bodyBytes);
        debugPrint('[API] Error body: $body');
        throw ApiException(
          statusCode: response.statusCode,
          message: 'HTTP ${response.statusCode}: ${response.reasonPhrase}',
        );
      }
    } on SocketException catch (e) {
      debugPrint('[API] SocketException: $e → URL: $uri');
      throw ApiException(
        statusCode: 0,
        message: 'Không thể kết nối đến server ($uri). Kiểm tra BE đang chạy và IP trong api_service.dart.',
      );
    } on http.ClientException catch (e) {
      debugPrint('[API] ClientException: $e');
      throw ApiException(statusCode: 0, message: e.message);
    } on ApiException {
      rethrow;
    } catch (e) {
      debugPrint('[API] Unknown error: $e');
      throw ApiException(statusCode: 0, message: e.toString());
    }
  }

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body, {
    Map<String, String?>? params,
    String? token,
  }) async {
    final cleanParams = <String, String>{};
    params?.forEach((k, v) {
      if (v != null) cleanParams[k] = v;
    });

    final uri = Uri.parse('$baseUrl$path').replace(
      queryParameters: cleanParams.isEmpty ? null : cleanParams,
    );

    debugPrint('[API] POST $uri');

    try {
      final response = await http
          .post(
            uri,
            headers: _authHeaders(token),
            body: json.encode(body),
          )
          .timeout(_timeout);

      debugPrint('[API] ${response.statusCode} ← $path');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = utf8.decode(response.bodyBytes);
        if (decoded.isEmpty) return {};
        return json.decode(decoded) as Map<String, dynamic>;
      } else {
        final decoded = utf8.decode(response.bodyBytes);
        debugPrint('[API] Error body: $decoded');
        String message = 'HTTP ${response.statusCode}: ${response.reasonPhrase}';
        try {
          final errJson = json.decode(decoded) as Map<String, dynamic>;
          message = errJson['message'] as String? ?? message;
        } catch (_) {}
        throw ApiException(statusCode: response.statusCode, message: message);
      }
    } on SocketException catch (e) {
      debugPrint('[API] SocketException: $e → URL: $uri');
      throw ApiException(
        statusCode: 0,
        message: 'Không thể kết nối đến server ($uri). Kiểm tra BE đang chạy và IP trong api_service.dart.',
      );
    } on http.ClientException catch (e) {
      debugPrint('[API] ClientException: $e');
      throw ApiException(statusCode: 0, message: e.message);
    } on ApiException {
      rethrow;
    } catch (e) {
      debugPrint('[API] Unknown error: $e');
      throw ApiException(statusCode: 0, message: e.toString());
    }
  }

  T _parseData<T>(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromData,
  ) {
    final data = json['data'];
    if (data is Map<String, dynamic>) {
      return fromData(data);
    }
    throw ApiException(statusCode: 0, message: 'Dữ liệu phản hồi không hợp lệ');
  }

  // ── Products ─────────────────────────────────────────────────────────────

  /// Lấy danh sách sản phẩm với filter và phân trang.
  ///
  /// [keyword] — từ khoá tìm kiếm  
  /// [categoryId] — lọc theo danh mục  
  /// [brandId] — lọc theo thương hiệu  
  /// [page] — trang hiện tại (0-based)  
  /// [size] — số sản phẩm mỗi trang  
  /// [sort] — ví dụ: "price,asc" | "price,desc" | "soldCount,desc" | "createdDate,desc"
  Future<ApiPage<ApiProductResponse>> getProducts({
    String? keyword,
    int? categoryId,
    int? brandId,
    int page = 0,
    int size = 20,
    String? sort,
  }) async {
    final json = await _get('/products', params: {
      if (keyword != null && keyword.isNotEmpty) 'keyword': keyword,
      if (categoryId != null) 'categoryId': categoryId.toString(),
      if (brandId != null) 'brandId': brandId.toString(),
      'page': page.toString(),
      'size': size.toString(),
      if (sort != null) 'sort': sort,
    });

    final data = json['data'] as Map<String, dynamic>;
    return ApiPage.fromJson(data, ApiProductResponse.fromJson);
  }

  /// Lấy chi tiết một sản phẩm theo ID.
  Future<ApiProductResponse> getProductById(int id) async {
    final json = await _get('/products/$id');
    final data = json['data'] as Map<String, dynamic>;
    return ApiProductResponse.fromJson(data);
  }

  // ── Categories ───────────────────────────────────────────────────────────

  /// Lấy toàn bộ danh mục (mặc định size=100, đủ cho mọi trường hợp).
  Future<List<ApiCategoryResponse>> getCategories({int size = 100}) async {
    final json = await _get('/categories', params: {
      'page': '0',
      'size': size.toString(),
    });

    final data = json['data'] as Map<String, dynamic>;
    final page = ApiPage.fromJson(data, ApiCategoryResponse.fromJson);
    return page.content;
  }

  // ── Brands ───────────────────────────────────────────────────────────────

  /// Lấy toàn bộ thương hiệu.
  Future<List<ApiBrandResponse>> getBrands({int size = 100}) async {
    final json = await _get('/brands', params: {
      'page': '0',
      'size': size.toString(),
    });

    final data = json['data'] as Map<String, dynamic>;
    final page = ApiPage.fromJson(data, ApiBrandResponse.fromJson);
    return page.content;
  }

  // ── Orders ───────────────────────────────────────────────────────────────

  Future<OrderResponse> createOrder(
    CreateOrderRequest request,
    String token,
    int userId,
  ) async {
    final json = await _post(
      '/orders',
      request.toJson(),
      params: {'userId': userId.toString()},
      token: token,
    );
    return _parseData(json, OrderResponse.fromJson);
  }

  Future<ApiPage<OrderResponse>> getMyOrders(
    int userId,
    String token, {
    int page = 0,
  }) async {
    final json = await _get(
      '/orders',
      token: token,
      params: {
        'userId': userId.toString(),
        'page': page.toString(),
        'size': '20',
      },
    );
    final data = json['data'] as Map<String, dynamic>;
    return ApiPage.fromJson(data, OrderResponse.fromJson);
  }

  Future<OrderResponse> getOrderById(int id, String token) async {
    final json = await _get('/orders/$id', token: token);
    return _parseData(json, OrderResponse.fromJson);
  }

  Future<bool> cancelOrder(int id, String token) async {
    await _post('/orders/$id/cancel', {}, token: token);
    return true;
  }

  // ── Vouchers ─────────────────────────────────────────────────────────────

  Future<VoucherValidateResponse> validateVoucher(
    String code,
    int userId,
    String token,
  ) async {
    final json = await _get(
      '/vouchers/validate',
      params: {'code': code, 'userId': userId.toString()},
      token: token,
    );
    debugPrint('[Voucher] Raw response: $json');
    return VoucherValidateResponse.fromApiResponse(json);
  }

  Future<Map<String, dynamic>> getVoucherDetails(
    String code,
    int userId,
    double orderTotal,
    String token,
  ) async {
    final json = await _get(
      '/vouchers/validate-details',
      params: {
        'code': code,
        'userId': userId.toString(),
        'orderTotal': orderTotal.toString(),
      },
      token: token,
    );
    return json['data'] as Map<String, dynamic>;
  }

  // ── Store branches ───────────────────────────────────────────────────────

  Future<List<StoreBranchResponse>> getStoreBranches() async {
    final json = await _get('/branches', params: {
      'page': '0',
      'size': '100',
    });
    final data = json['data'];

    if (data is List<dynamic>) {
      return data
          .map((e) => StoreBranchResponse.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    if (data is Map<String, dynamic>) {
      if (data['content'] is List<dynamic>) {
        final page = ApiPage.fromJson(data, StoreBranchResponse.fromJson);
        return page.content;
      }
    }
    return [];
  }

  // ── Payments ─────────────────────────────────────────────────────────────

  Future<VnpayPaymentResponse> createVnpayPayment(
    int orderId,
    double amount,
    String orderInfo,
    String token,
  ) async {
    final json = await _post(
      '/payments/vnpay/create',
      {
        'amount': amount,
        'orderInfo': orderInfo,
      },
      params: {'orderId': orderId.toString()},
      token: token,
    );
    return _parseData(json, VnpayPaymentResponse.fromJson);
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
