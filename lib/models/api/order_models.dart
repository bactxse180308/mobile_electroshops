import 'common_models.dart';

class OrderItemRequest {
  final int productId;
  final int quantity;

  const OrderItemRequest({required this.productId, required this.quantity});

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'quantity': quantity,
      };
}

class CreateOrderRequest {
  final String shippingAddress;
  final String paymentMethod;
  final String? voucherCode;
  final List<OrderItemRequest> items;

  const CreateOrderRequest({
    required this.shippingAddress,
    required this.paymentMethod,
    this.voucherCode,
    required this.items,
  });

  Map<String, dynamic> toJson() => {
        'shippingAddress': shippingAddress,
        'paymentMethod': paymentMethod,
        if (voucherCode != null && voucherCode!.isNotEmpty)
          'voucherCode': voucherCode,
        'items': items.map((i) => i.toJson()).toList(),
      };
}

class ApiOrderItemResponse {
  final int orderDetailId;
  final int productId;
  final String productName;
  final String? productImage;
  final int quantity;
  final double unitPrice;
  final double subtotal;
  final String? branchName;
  final int? branchId;

  const ApiOrderItemResponse({
    required this.orderDetailId,
    required this.productId,
    required this.productName,
    this.productImage,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    this.branchName,
    this.branchId,
  });

  factory ApiOrderItemResponse.fromJson(Map<String, dynamic> json) {
    return ApiOrderItemResponse(
      orderDetailId: json['orderDetailId'] as int? ?? 0,
      productId: json['productId'] as int? ?? 0,
      productName: json['productName'] as String? ?? '',
      productImage: json['productImage'] as String?,
      quantity: json['quantity'] as int? ?? 1,
      unitPrice: parseNum(json['unitPrice']),
      subtotal: parseNum(json['subtotal']),
      branchName: json['branchName'] as String?,
      branchId: json['branchId'] as int?,
    );
  }
}

class OrderResponse {
  final int orderId;
  final int userId;
  final String? userFullName;
  final String
      orderStatus; // PENDING | CONFIRMED | SHIPPED | DELIVERED | CANCELLED
  final String paymentMethod;
  final String paymentStatus; // PENDING | SUCCESS | FAILED | REFUNDED
  final String? shippingAddress;
  final double totalAmount;
  final double discountAmount;
  final double finalAmount;
  final String? voucherCode;
  final String? cancelReason;
  final String? orderDate; // ISO string từ LocalDateTime
  final String? updatedAt;
  final List<ApiOrderItemResponse> orderItems;

  const OrderResponse({
    required this.orderId,
    required this.userId,
    this.userFullName,
    required this.orderStatus,
    required this.paymentMethod,
    required this.paymentStatus,
    this.shippingAddress,
    required this.totalAmount,
    required this.discountAmount,
    required this.finalAmount,
    this.voucherCode,
    this.cancelReason,
    this.orderDate,
    this.updatedAt,
    required this.orderItems,
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    final rawItems = json['orderItems'] as List<dynamic>? ?? [];
    return OrderResponse(
      orderId: json['orderId'] as int? ?? 0,
      userId: json['userId'] as int? ?? 0,
      userFullName: json['userFullName'] as String?,
      orderStatus: json['orderStatus'] as String? ?? 'PENDING',
      paymentMethod: json['paymentMethod'] as String? ?? '',
      paymentStatus: json['paymentStatus'] as String? ?? 'PENDING',
      shippingAddress: json['shippingAddress'] as String?,
      totalAmount: parseNum(json['totalAmount']),
      discountAmount: parseNum(json['discountAmount']),
      finalAmount: parseNum(json['finalAmount']),
      voucherCode: json['voucherCode'] as String?,
      cancelReason: json['cancelReason'] as String?,
      orderDate: json['orderDate'] as String?,
      updatedAt: json['updatedAt'] as String?,
      orderItems: rawItems
          .map((e) => ApiOrderItemResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
