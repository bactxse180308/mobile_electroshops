import 'package:flutter/foundation.dart';
import '../core/constants/app_strings.dart';
import '../models/models.dart';
import '../models/api_models.dart';
import '../services/product_service.dart';
import '../services/api_service.dart';
import '../features/product/widgets/filter_sheet.dart';

class CategoriesProvider extends ChangeNotifier {
  final ProductService _api = ProductService();

  // ── Data state ────────────────────────────────────────────────────────────
  List<Product> _products = [];
  int _totalElements = 0;
  bool _isLastPage = false;
  
  List<ApiBrandResponse> _apiBrands = [];
  List<ApiCategoryResponse> _apiCategories = [];

  // ── Loading state ─────────────────────────────────────────────────────────
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;
  int _currentPage = 0;

  // ── Filter state ──────────────────────────────────────────────────────────
  String _searchQuery = '';
  String _sort = AppStrings.sortPopular;
  int? _selectedCategoryId;
  int? _selectedBrandId;
  String? _pickedPrice;
  double _minRating = 0;

  // ── Getters ──────────────────────────────────────────────────────────────
  List<Product> get products => _products;
  int get totalElements => _totalElements;
  bool get isLastPage => _isLastPage;

  List<ApiBrandResponse> get apiBrands => _apiBrands;
  List<ApiCategoryResponse> get apiCategories => _apiCategories;

  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;
  
  String get searchQuery => _searchQuery;
  String get sort => _sort;
  int? get selectedCategoryId => _selectedCategoryId;
  int? get selectedBrandId => _selectedBrandId;
  String? get pickedPrice => _pickedPrice;
  double get minRating => _minRating;

  int get activeFilters =>
      (_selectedCategoryId != null ? 1 : 0) +
      (_selectedBrandId != null ? 1 : 0) +
      (_pickedPrice != null ? 1 : 0) +
      (_minRating > 0 ? 1 : 0);

  // ── Initialization ────────────────────────────────────────────────────────
  void init({int? categoryId, int? brandId, String? query}) {
    _selectedCategoryId = categoryId;
    _selectedBrandId = brandId;
    _searchQuery = query ?? '';
    _loadBrandsAndCategories();
    loadProducts(reset: true);
  }

  // ── Sort mapping ──────────────────────────────────────────────────────────
  String? _sortParam(String sort) {
    if (sort == AppStrings.sortPriceAsc) return 'price,asc';
    if (sort == AppStrings.sortPriceDesc) return 'price,desc';
    if (sort == AppStrings.sortNewest) return 'createdDate,desc';
    if (sort == AppStrings.sortRatingDesc) return 'rating,desc';
    return 'soldCount,desc'; // Phổ biến
  }

  // ── Actions ───────────────────────────────────────────────────────────────
  void setSearchQuery(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    loadProducts(reset: true);
  }

  void setSort(String sort) {
    if (_sort == sort) return;
    _sort = sort;
    loadProducts(reset: true);
  }

  void applyFilter(int? catId, int? brandId, String? price, double rating) {
    _selectedCategoryId = catId;
    _selectedBrandId = brandId;
    _pickedPrice = price;
    _minRating = rating;
    loadProducts(reset: true);
  }

  Future<void> _loadBrandsAndCategories() async {
    try {
      final brands = await _api.getBrands();
      final cats = await _api.getCategories();
      _apiBrands = brands;
      _apiCategories = cats;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> loadProducts({bool reset = false}) async {
    if (reset) {
      _isLoading = true;
      _errorMessage = null;
      _currentPage = 0;
      _isLastPage = false;
      _products.clear();
      notifyListeners();
    } else {
      if (_isLastPage || _isLoadingMore || _isLoading) return;
      _isLoadingMore = true;
      _currentPage++;
      notifyListeners();
    }

    try {
      final apiPage = await _api.getProducts(
        keyword: _searchQuery.trim().isEmpty ? null : _searchQuery.trim(),
        categoryId: _selectedCategoryId,
        brandId: _selectedBrandId,
        page: _currentPage,
        size: 20,
        sort: _sortParam(_sort),
      );

      final newProducts = apiPage.content.map((e) => Product.fromApi(e)).toList();

      // Client-side filtering
      final filtered = newProducts.where((p) {
        if (_minRating > 0 && p.rating < _minRating) return false;
        if (_pickedPrice != null) {
          final band = FilterSheet.priceBands.firstWhere((b) => b['id'] == _pickedPrice);
          if (p.price < (band['min'] as int) || p.price > (band['max'] as int)) return false;
        }
        return true;
      }).toList();

      if (reset) {
        _products = filtered;
      } else {
        _products.addAll(filtered);
      }

      _totalElements = apiPage.totalElements;
      _isLastPage = apiPage.last;
    } on ApiException catch (e) {
      if (reset) {
        _errorMessage = e.message;
      }
    } catch (e) {
      if (reset) {
        _errorMessage = e.toString();
      }
    } finally {
      if (reset) {
        _isLoading = false;
      } else {
        _isLoadingMore = false;
      }
      notifyListeners();
    }
  }
}
