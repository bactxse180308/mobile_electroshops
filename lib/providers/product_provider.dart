import 'package:flutter/foundation.dart' hide Category;
import '../models/models.dart';
import '../models/api_models.dart';
import '../services/api_service.dart';

class ProductProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  // ── Home State ────────────────────────────────────────────────────────────
  List<Category> _homeCategories = [];
  List<Brand> _homeBrands = [];
  List<Product> _flashSale = [];
  List<Product> _bestSellers = [];
  List<Product> _newArrivals = [];
  List<Product> _recentlyViewed = [];

  bool _isLoadingHome = false;
  String? _homeError;

  List<Category> get homeCategories => _homeCategories;
  List<Brand> get homeBrands => _homeBrands;
  List<Product> get flashSale => _flashSale;
  List<Product> get bestSellers => _bestSellers;
  List<Product> get newArrivals => _newArrivals;
  List<Product> get recentlyViewed => _recentlyViewed;
  bool get isLoadingHome => _isLoadingHome;
  String? get homeError => _homeError;

  // ── Detail State ──────────────────────────────────────────────────────────
  Product? _currentProduct;
  List<Product> _relatedProducts = [];
  List<ApiProductAttributeResponse> _currentAttributes = [];
  ApiRatingStatsResponse? _currentRatingStats;
  ApiPage<ApiReviewResponse>? _currentReviewsPage;

  bool _isLoadingDetail = false;
  String? _detailError;

  Product? get currentProduct => _currentProduct;
  List<Product> get relatedProducts => _relatedProducts;
  List<ApiProductAttributeResponse> get currentAttributes => _currentAttributes;
  ApiRatingStatsResponse? get currentRatingStats => _currentRatingStats;
  ApiPage<ApiReviewResponse>? get currentReviewsPage => _currentReviewsPage;
  bool get isLoadingDetail => _isLoadingDetail;
  String? get detailError => _detailError;

  // ── Home Methods ──────────────────────────────────────────────────────────
  Future<void> loadHomeData() async {
    _isLoadingHome = true;
    _homeError = null;
    notifyListeners();

    try {
      final cats = await _api.getCategories();
      final brnds = await _api.getBrands();

      _homeCategories = cats.map((e) => Category.fromApi(e)).toList();
      _homeBrands = brnds.map((e) => Brand.fromApi(e)).toList();

      List<Product> flash = [];
      List<Product> best = [];
      List<Product> newArr = [];

      try {
        final p = await _api.getProducts(size: 20);
        final all = p.content.map((e) => Product.fromApi(e)).toList();
        flash = List.from(all)..sort((a, b) => (b.oldPrice - b.price).compareTo(a.oldPrice - a.price));
        best = List.from(all)..sort((a, b) => b.sold.compareTo(a.sold));
        newArr = List.from(all);
      } catch (e) {
        debugPrint('Load products error: $e');
      }

      _flashSale = flash.take(6).toList();
      _bestSellers = best.take(4).toList();
      _newArrivals = newArr.take(4).toList();
      _recentlyViewed = best.skip(4).take(4).toList();
    } catch (e) {
      _homeError = e is ApiException ? e.message : e.toString();
    } finally {
      _isLoadingHome = false;
      notifyListeners();
    }
  }

  // ── Detail Methods ────────────────────────────────────────────────────────
  Future<void> loadProductDetail(int id) async {
    _isLoadingDetail = true;
    _detailError = null;
    notifyListeners();

    try {
      final apiProduct = await _api.getProductById(id);
      _currentProduct = Product.fromApi(apiProduct);

      List<Product> related = [];
      if (apiProduct.categoryId != null) {
        final relatedPage = await _api.getProducts(
          categoryId: apiProduct.categoryId,
          size: 8,
        );
        related = relatedPage.content
            .where((p) => p.productId != id)
            .take(6)
            .map((p) => Product.fromApi(p))
            .toList();
      }

      final attrs = await _api.getProductAttributes(id);
      final stats = await _api.getProductRatingStats(id);
      final revs = await _api.getProductReviews(id, size: 10);

      _relatedProducts = related;
      _currentAttributes = attrs;
      _currentRatingStats = stats;
      _currentReviewsPage = revs;
    } catch (e) {
      _detailError = e is ApiException ? e.message : e.toString();
    } finally {
      _isLoadingDetail = false;
      notifyListeners();
    }
  }

  void resetDetail() {
    _currentProduct = null;
    _relatedProducts = [];
    _currentAttributes = [];
    _currentRatingStats = null;
    _currentReviewsPage = null;
    _isLoadingDetail = false;
    _detailError = null;
    notifyListeners();
  }

  // ── Shared Methods (for CategoriesScreen etc.) ────────────────────────────
  Future<List<ApiBrandResponse>> getBrands() => _api.getBrands();
  Future<List<ApiCategoryResponse>> getCategories() => _api.getCategories();

  Future<ApiPage<ApiProductResponse>> getProducts({
    String? keyword,
    int? categoryId,
    int? brandId,
    int? page,
    int? size,
    String? sort,
  }) {
    return _api.getProducts(
      keyword: keyword,
      categoryId: categoryId,
      brandId: brandId,
      page: page ?? 0,
      size: size ?? 10,
      sort: sort,
    );
  }
}
