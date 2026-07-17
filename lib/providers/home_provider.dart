import 'package:flutter/foundation.dart' hide Category;
import '../models/models.dart';
import '../services/product_service.dart';
import '../services/api_service.dart';
import '../core/constants/app_assets.dart';

class HomeProvider extends ChangeNotifier {
  final ProductService _api = ProductService();

  List<Category> _categories = [];
  List<Brand> _brands = [];
  List<Product> _flashSale = [];
  List<Product> _bestSellers = [];
  List<Product> _newArrivals = [];
  List<Product> _recentlyViewed = [];
  List<String> _bannerImages = AppAssets.homeBanners;

  bool _isLoading = true;
  String? _errorMessage;
  bool _isInit = false;

  // ── Getters ──────────────────────────────────────────────────────────────
  List<Category> get categories => _categories;
  List<Brand> get brands => _brands;
  List<Product> get flashSale => _flashSale;
  List<Product> get bestSellers => _bestSellers;
  List<Product> get newArrivals => _newArrivals;
  List<Product> get recentlyViewed => _recentlyViewed;
  List<String> get bannerImages => _bannerImages;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ── Methods ──────────────────────────────────────────────────────────────
  Future<void> loadHomeData() async {
    if (_isInit && _isLoading) return; // Tránh gọi nhiều lần cùng lúc
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final cats = await _api.getCategories();
      final brnds = await _api.getBrands();
      final banners = await _api.getHomeBannerUrls();

      _categories = cats.map((e) => Category.fromApi(e)).toList();
      _brands = brnds.map((e) => Brand.fromApi(e)).toList();
      _bannerImages = banners.isNotEmpty ? banners : AppAssets.homeBanners;

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
      
      _isInit = true;
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
