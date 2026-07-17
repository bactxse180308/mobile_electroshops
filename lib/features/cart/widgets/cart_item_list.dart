import 'package:flutter/material.dart';
import '../../../../models/api_models.dart';
import 'cart_item_card.dart';

class CartItemList extends StatelessWidget {
  final List<ApiCartItemResponse> items;
  final Set<int> selectedIds;
  final void Function(int productId) onToggle;
  final void Function(int productId, int quantity) onUpdateQuantity;
  final void Function(int productId) onRemove;

  const CartItemList({
    super.key,
    required this.items,
    required this.selectedIds,
    required this.onToggle,
    required this.onUpdateQuantity,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items.map((item) => CartItemCard(
        item: item,
        selected: selectedIds.contains(item.productId),
        onToggle: () => onToggle(item.productId),
        onIncrease: () => onUpdateQuantity(item.productId, item.quantity + 1),
        onDecrease: () {
          if (item.quantity > 1) {
            onUpdateQuantity(item.productId, item.quantity - 1);
          }
        },
        onRemove: () => onRemove(item.productId),
      )).toList(),
    );
  }
}
