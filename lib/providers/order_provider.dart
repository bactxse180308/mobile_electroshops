import 'package:flutter/foundation.dart';
import '../models/api_models.dart';
import '../services/api_service.dart';

class OrderProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<OrderResponse> _orders = [];
  OrderResponse? _currentOrder;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _isCancelling = false;
  String? _error;
  int _currentPage = 0;
  bool _hasMore = true;

  List<OrderResponse> get orders => _orders;
  OrderResponse? get currentOrder => _currentOrder;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get isCancelling => _isCancelling;
  String? get error => _error;
  bool get hasMore => _hasMore;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<OrderResponse?> createOrder(
    CreateOrderRequest request,
    int userId,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final order = await _api.createOrder(request, userId);
      _currentOrder = order;
      _orders = [order, ..._orders];
      return order;
    } catch (e) {
      _error = e is ApiException ? e.message : e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMyOrders(
    String token,
    int userId, {
    bool refresh = false,
  }) async {
    if (refresh) {
      _currentPage = 0;
      _hasMore = true;
      _orders = [];
    }
    if (!_hasMore && !refresh) return;

    if (refresh) {
      _isLoading = true;
    } else {
      _isLoadingMore = true;
    }
    _error = null;
    notifyListeners();

    try {
      final page = await _api.getMyOrders(userId, token, page: _currentPage);
      if (refresh) {
        _orders = page.content;
      } else {
        _orders = [..._orders, ...page.content];
      }
      _hasMore = !page.last;
      _currentPage = page.number + 1;
    } catch (e) {
      _error = e is ApiException ? e.message : e.toString();
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<OrderResponse?> fetchOrderById(int id, String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final order = await _api.getOrderById(id, token);
      _currentOrder = order;
      return order;
    } catch (e) {
      _error = e is ApiException ? e.message : e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> cancelOrder(int id, String token) async {
    _isCancelling = true;
    _error = null;
    notifyListeners();

    try {
      await _api.cancelOrder(id, token);
      final order = await _api.getOrderById(id, token);
      _currentOrder = order;
      _orders = _orders
          .map((item) => item.orderId == order.orderId ? order : item)
          .toList();
      return true;
    } catch (e) {
      _error = e is ApiException ? e.message : e.toString();
      return false;
    } finally {
      _isCancelling = false;
      notifyListeners();
    }
  }

  void setCurrentOrder(OrderResponse? order) {
    _currentOrder = order;
    notifyListeners();
  }
}
