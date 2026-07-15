import 'package:flutter/foundation.dart';
import '../models/api_models.dart';
import 'api_service.dart';

class ProductService {
  final ApiService _api = ApiService();

  Future<ApiPage<ApiProductResponse>> getProducts({
    String? keyword,
    int? categoryId,
    int? brandId,
    int page = 0,
    int size = 20,
    String? sort,
  }) async {
    final j = await _api.get('/products', params: {
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
    final j = await _api.get('/products/$id');
    return ApiProductResponse.fromJson(j['data'] as Map<String, dynamic>);
  }

  Future<List<ApiCategoryResponse>> getCategories({int size = 100}) async {
    final j = await _api.get('/categories', params: {'page': '0', 'size': size.toString()});
    final data = j['data'] as Map<String, dynamic>;
    return ApiPage.fromJson(data, ApiCategoryResponse.fromJson).content;
  }

  Future<List<ApiBrandResponse>> getBrands({int size = 100}) async {
    final j = await _api.get('/brands', params: {'page': '0', 'size': size.toString()});
    final data = j['data'] as Map<String, dynamic>;
    return ApiPage.fromJson(data, ApiBrandResponse.fromJson).content;
  }

  Future<List<ApiProductAttributeResponse>> getProductAttributes(int productId) async {
    final j = await _api.get('/product-attributes/product/$productId');
    final data = j['data'] as List<dynamic>? ?? [];
    return data.map((e) => ApiProductAttributeResponse.fromJson(e)).toList();
  }

  Future<ApiPage<ApiReviewResponse>> getProductReviews(
    int productId, {
    int page = 0,
    int size = 20,
  }) async {
    final j = await _api.get('/reviews', params: {
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
    final j = await _api.get('/reviews/product/$productId/rating-stats');
    return ApiRatingStatsResponse.fromJson(j['data'] as Map<String, dynamic>);
  }

  Future<List<String>> getHomeBannerUrls() async {
    try {
      final j = await _api.get('/api/banners/home');
      final data = j['data'] as Map<String, dynamic>?;
      if (data == null) return [];
      final mainList = data['main'] as List<dynamic>? ?? [];
      return mainList
          .map((e) => e['imageUrl'] as String?)
          .where((url) => url != null && url.isNotEmpty)
          .cast<String>()
          .toList();
    } catch (e) {
      debugPrint('Error loading home banners: $e');
      return [];
    }
  }
}
