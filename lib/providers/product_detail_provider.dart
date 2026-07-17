import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../models/api_models.dart';
import '../services/product_service.dart';
import '../services/api_service.dart';
import '../core/constants/app_strings.dart';

class ProductDetailProvider extends ChangeNotifier {
  final ProductService _api = ProductService();

  Product? _product;
  List<Product> _related = [];
  List<ApiProductAttributeResponse> _attributes = [];
  ApiPage<ApiReviewResponse>? _reviewsPage;
  ApiRatingStatsResponse? _ratingStats;

  bool _isLoading = true;
  String? _errorMessage;

  // ── Getters ──────────────────────────────────────────────────────────────
  Product? get product => _product;
  List<Product> get related => _related;
  List<ApiProductAttributeResponse> get attributes => _attributes;
  List<ApiReviewResponse> get reviews => _reviewsPage?.content ?? [];
  ApiRatingStatsResponse? get ratingStats => _ratingStats;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ── Methods ──────────────────────────────────────────────────────────────
  Future<void> loadProduct(String productIdStr) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final id = int.tryParse(productIdStr);
      if (id == null) {
        throw const ApiException(statusCode: 0, message: AppStrings.errInvalidProductId);
      }

      final apiProduct = await _api.getProductById(id);
      _product = Product.fromApi(apiProduct);

      if (apiProduct.categoryId != null) {
        final relatedPage = await _api.getProducts(
          categoryId: apiProduct.categoryId,
          size: 8,
        );
        _related = relatedPage.content
            .where((p) => p.productId != id)
            .take(6)
            .map((p) => Product.fromApi(p))
            .toList();
      }

      final attrs = await _api.getProductAttributes(id);
      final stats = await _api.getProductRatingStats(id);
      final revs = await _api.getProductReviews(id, size: 10);

      _attributes = attrs;
      _ratingStats = stats;
      _reviewsPage = revs;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
