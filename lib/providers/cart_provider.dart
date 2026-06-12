import 'package:flutter/foundation.dart';
import '../models/models.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [
    CartItem(id: 'p1', qty: 2, selected: true),
    CartItem(id: 'p4', qty: 1, selected: true),
    CartItem(id: 'p5', qty: 1, selected: false),
  ];

  List<CartItem> get items => _items;

  int get totalCount => _items.fold(0, (sum, i) => sum + i.qty);

  List<CartItem> get selectedItems => _items.where((i) => i.selected).toList();

  bool get allSelected => _items.isNotEmpty && _items.every((i) => i.selected);

  void add(String id, {int qty = 1}) {
    final existing = _items.cast<CartItem?>().firstWhere(
      (i) => i!.id == id,
      orElse: () => null,
    );
    if (existing != null) {
      existing.qty += qty;
    } else {
      _items.add(CartItem(id: id, qty: qty, selected: true));
    }
    notifyListeners();
  }

  void remove(String id) {
    _items.removeWhere((i) => i.id == id);
    notifyListeners();
  }

  void setQty(String id, int qty) {
    final item = _items.cast<CartItem?>().firstWhere(
      (i) => i!.id == id,
      orElse: () => null,
    );
    if (item != null) {
      item.qty = qty < 1 ? 1 : qty;
      notifyListeners();
    }
  }

  void toggle(String id) {
    final item = _items.cast<CartItem?>().firstWhere(
      (i) => i!.id == id,
      orElse: () => null,
    );
    if (item != null) {
      item.selected = !item.selected;
      notifyListeners();
    }
  }

  void toggleAll(bool selected) {
    for (final item in _items) {
      item.selected = selected;
    }
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  void removeSelected() {
    _items.removeWhere((i) => i.selected);
    notifyListeners();
  }
}

