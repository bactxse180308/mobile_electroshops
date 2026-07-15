import 'package:flutter/foundation.dart';
import '../models/api_models.dart';
import '../services/api_service.dart';
import '../services/cart_service.dart';

class CartProvider extends ChangeNotifier {
  // ── State ────────────────────────────────────────────────────────────────
  ApiCartResponse? _cart;
  bool _isLoading = false;
  String? _error;

  // Danh sách productId được chọn để checkout
  final Set<int> _selectedIds = {};

  // ── Getters ──────────────────────────────────────────────────────────────
  ApiCartResponse? get cart => _cart;
  List<ApiCartItemResponse> get items => _cart?.items ?? [];
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get totalCount => items.fold(0, (sum, i) => sum + i.quantity);

  Set<int> get selectedIds => _selectedIds;

  List<ApiCartItemResponse> get selectedItems =>
      items.where((i) => _selectedIds.contains(i.productId)).toList();

  bool get allSelected =>
      items.isNotEmpty && items.every((i) => _selectedIds.contains(i.productId));

  double get selectedSubtotal =>
      selectedItems.fold(0.0, (sum, i) => sum + i.subtotal);

  /// Phí ship: miễn phí nếu đơn ≥ 500k
  double get shippingFee => selectedSubtotal >= 500000 ? 0 : 25000;

  double get totalPayable => selectedSubtotal + shippingFee;

  // ── Load từ BE ────────────────────────────────────────────────────────────

  Future<void> loadCart(int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _cart = await CartService().getCart(userId);
      // Mặc định chọn tất cả sản phẩm
      _selectedIds
        ..clear()
        ..addAll(_cart!.items.map((i) => i.productId));
    } on ApiException catch (e) {
      _error = e.message;
      _cart = null;
      _selectedIds.clear();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Thêm sản phẩm ─────────────────────────────────────────────────────────

  Future<void> addItem(int userId, int productId, int quantity) async {
    try {
      _cart = await CartService().addToCart(userId, productId, quantity);
      // Tự động chọn sản phẩm vừa thêm
      _selectedIds.add(productId);
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      rethrow;
    }
  }

  // ── Cập nhật số lượng ─────────────────────────────────────────────────────

  Future<void> updateQty(int userId, int productId, int quantity) async {
    // Optimistic update
    final idx = _cart?.items.indexWhere((i) => i.productId == productId) ?? -1;
    ApiCartItemResponse? backup;
    if (idx >= 0 && _cart != null) {
      backup = _cart!.items[idx];
      final updatedItem = ApiCartItemResponse(
        productId: backup.productId,
        productName: backup.productName,
        mainImage: backup.mainImage,
        price: backup.price,
        quantity: quantity,
        subtotal: backup.price * quantity,
      );
      final newItems = List<ApiCartItemResponse>.from(_cart!.items);
      newItems[idx] = updatedItem;
      _cart = ApiCartResponse(
        cartId: _cart!.cartId,
        userId: _cart!.userId,
        items: newItems,
        totalAmount: newItems.fold(0.0, (s, i) => s + i.subtotal),
        totalItems: newItems.fold(0, (s, i) => s + i.quantity),
      );
      notifyListeners();
    }

    try {
      _cart = await CartService().updateCartItem(userId, productId, quantity);
      notifyListeners();
    } on ApiException catch (e) {
      // Rollback
      if (backup != null && idx >= 0 && _cart != null) {
        final newItems = List<ApiCartItemResponse>.from(_cart!.items);
        newItems[idx] = backup;
        _cart = ApiCartResponse(
          cartId: _cart!.cartId,
          userId: _cart!.userId,
          items: newItems,
          totalAmount: newItems.fold(0.0, (s, i) => s + i.subtotal),
          totalItems: newItems.fold(0, (s, i) => s + i.quantity),
        );
      }
      _error = e.message;
      notifyListeners();
    }
  }

  // ── Xoá sản phẩm ─────────────────────────────────────────────────────────

  Future<void> removeItem(int userId, int productId) async {
    // Optimistic remove
    if (_cart != null) {
      final newItems = _cart!.items.where((i) => i.productId != productId).toList();
      _cart = ApiCartResponse(
        cartId: _cart!.cartId,
        userId: _cart!.userId,
        items: newItems,
        totalAmount: newItems.fold(0.0, (s, i) => s + i.subtotal),
        totalItems: newItems.fold(0, (s, i) => s + i.quantity),
      );
      _selectedIds.remove(productId);
      notifyListeners();
    }

    try {
      await CartService().removeCartItem(userId, productId);
    } on ApiException catch (e) {
      _error = e.message;
      // Refetch để đồng bộ lại
      await loadCart(userId);
    }
  }

  // ── Xoá toàn bộ ──────────────────────────────────────────────────────────

  Future<void> clearAllItems(int userId) async {
    final backup = _cart;
    _cart = null;
    _selectedIds.clear();
    notifyListeners();

    try {
      await CartService().clearCart(userId);
    } on ApiException catch (e) {
      _cart = backup;
      _error = e.message;
      notifyListeners();
    }
  }

  // ── Chọn sản phẩm ────────────────────────────────────────────────────────

  void toggleSelect(int productId) {
    if (_selectedIds.contains(productId)) {
      _selectedIds.remove(productId);
    } else {
      _selectedIds.add(productId);
    }
    notifyListeners();
  }

  void toggleSelectAll(bool select) {
    if (select) {
      _selectedIds.addAll(items.map((i) => i.productId));
    } else {
      _selectedIds.clear();
    }
    notifyListeners();
  }

  // ── Reset khi logout ──────────────────────────────────────────────────────

  void reset() {
    _cart = null;
    _selectedIds.clear();
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
