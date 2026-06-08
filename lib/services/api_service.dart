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

  // ── HTTP Helper ──────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> _get(
    String path, {
    Map<String, String?>? params,
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
      final response = await http.get(uri, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      }).timeout(_timeout);

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
}

// ── Exception ────────────────────────────────────────────────────────────────
class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException($statusCode): $message';
}
