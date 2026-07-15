import 'common_models.dart';

class ApiCartItemResponse {
  final int productId;
  final String productName;
  final String? mainImage;
  final double price;
  final int quantity;
  final double subtotal;

  const ApiCartItemResponse({
    required this.productId,
    required this.productName,
    this.mainImage,
    required this.price,
    required this.quantity,
    required this.subtotal,
  });

  factory ApiCartItemResponse.fromJson(Map<String, dynamic> json) {
    return ApiCartItemResponse(
      productId: json['productId'] as int? ?? 0,
      productName: json['productName'] as String? ?? '',
      mainImage: json['mainImage'] as String?,
      price: parseNum(json['price']),
      quantity: json['quantity'] as int? ?? 1,
      subtotal: parseNum(json['subtotal']),
    );
  }
}

class ApiCartResponse {
  final int cartId;
  final int userId;
  final List<ApiCartItemResponse> items;
  final double totalAmount;
  final int totalItems;

  const ApiCartResponse({
    required this.cartId,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.totalItems,
  });

  factory ApiCartResponse.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    return ApiCartResponse(
      cartId: json['cartId'] as int? ?? 0,
      userId: json['userId'] as int? ?? 0,
      items: rawItems
          .map((e) => ApiCartItemResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalAmount: parseNum(json['totalAmount']),
      totalItems: json['totalItems'] as int? ?? 0,
    );
  }
}
