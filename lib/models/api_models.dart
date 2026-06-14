/// Models ánh xạ chính xác JSON response từ Spring Boot backend.
/// ApiResponse<T> wrapper: { "status": int, "message": str, "data": T }
/// Paginated: data có dạng { "content": [...], "totalElements": int, "last": bool, ... }

// ─────────────────────────────────────────────
// Wrapper chung cho tất cả API response
// ─────────────────────────────────────────────
class ApiWrapper<T> {
  final int status;
  final String message;
  final T? data;

  const ApiWrapper({required this.status, required this.message, this.data});

  factory ApiWrapper.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromData,
  ) {
    return ApiWrapper(
      status: json['status'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      data: json['data'] != null ? fromData(json['data']) : null,
    );
  }
}

// ─────────────────────────────────────────────
// Spring Data Page<T> response structure
// ─────────────────────────────────────────────
class ApiPage<T> {
  final List<T> content;
  final int totalElements;
  final int totalPages;
  final int number; // current page (0-based)
  final bool last;

  const ApiPage({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.number,
    required this.last,
  });

  factory ApiPage.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromItem,
  ) {
    final rawContent = json['content'] as List<dynamic>? ?? [];

    // totalElements từ Spring có thể là int hoặc long → dùng num để an toàn
    int parseCount(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is double) return v.toInt();
      if (v is num) return v.toInt();
      return int.tryParse(v.toString()) ?? 0;
    }

    return ApiPage(
      content: rawContent
          .map((e) => fromItem(e as Map<String, dynamic>))
          .toList(),
      totalElements: parseCount(json['totalElements']),
      totalPages: parseCount(json['totalPages'] ?? 1),
      number: parseCount(json['number'] ?? 0),
      last: json['last'] as bool? ?? true,
    );
  }
}

// ─────────────────────────────────────────────
// ProductResponse từ BE
// ─────────────────────────────────────────────
class ApiProductResponse {
  final int productId;
  final String productName;
  final double price;
  final int? categoryId;
  final String? categoryName;
  final int? brandId;
  final String? brandName;
  final int quantity; // tồn kho
  final String? status; // "AVAILABLE" | "OUT_OF_STOCK" | ...
  final double? originalPrice;
  final int? discountPercent;
  final double? rating;
  final int? soldCount;
  final String? descriptionDetails;
  final String? mainImage;
  final List<String> imageUrls;

  const ApiProductResponse({
    required this.productId,
    required this.productName,
    required this.price,
    this.categoryId,
    this.categoryName,
    this.brandId,
    this.brandName,
    required this.quantity,
    this.status,
    this.originalPrice,
    this.discountPercent,
    this.rating,
    this.soldCount,
    this.descriptionDetails,
    this.mainImage,
    required this.imageUrls,
  });

  factory ApiProductResponse.fromJson(Map<String, dynamic> json) {
    // price / originalPrice: BE trả BigDecimal, JSON là số thực hoặc int
    final rawPrice = json['price'];
    final rawOriginal = json['originalPrice'];

    double parseNum(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    final rawUrls = json['imageUrls'] as List<dynamic>? ?? [];
    return ApiProductResponse(
      productId: json['productId'] as int? ?? 0,
      productName: json['productName'] as String? ?? '',
      price: parseNum(rawPrice),
      categoryId: json['categoryId'] as int?,
      categoryName: json['categoryName'] as String?,
      brandId: json['brandId'] as int?,
      brandName: json['brandName'] as String?,
      quantity: json['quantity'] as int? ?? 0,
      status: json['status'] as String?,
      originalPrice: rawOriginal != null ? parseNum(rawOriginal) : null,
      discountPercent: json['discountPercent'] as int?,
      rating: (json['rating'] as num?)?.toDouble(),
      soldCount: json['soldCount'] as int?,
      descriptionDetails: json['descriptionDetails'] as String?,
      mainImage: json['mainImage'] as String?,
      imageUrls: rawUrls.map((e) => e.toString()).toList(),
    );
  }

  /// Danh sách ảnh đầy đủ
  List<String> get allImages {
    final result = <String>[];
    if (mainImage != null && mainImage!.isNotEmpty) result.add(mainImage!);
    for (final u in imageUrls) {
      if (u.isNotEmpty && u != mainImage) result.add(u);
    }
    if (result.isEmpty) {
      result.add('https://picsum.photos/seed/${productId}_cover/600/600');
    }
    return result;
  }

  bool get isAvailable => (status?.toUpperCase() ?? '') == 'AVAILABLE' && quantity > 0;
}

// ─────────────────────────────────────────────
// CategoryResponse từ BE
// ─────────────────────────────────────────────
class ApiCategoryResponse {
  final int categoryId;
  final String categoryName;
  final String? description;
  final String? imageUrl;

  const ApiCategoryResponse({
    required this.categoryId,
    required this.categoryName,
    this.description,
    this.imageUrl,
  });

  factory ApiCategoryResponse.fromJson(Map<String, dynamic> json) {
    return ApiCategoryResponse(
      categoryId: json['categoryId'] as int? ?? 0,
      categoryName: json['categoryName'] as String? ?? '',
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );
  }
}

// ─────────────────────────────────────────────
// BrandResponse từ BE
// ─────────────────────────────────────────────
class ApiBrandResponse {
  final int brandId;
  final String brandName;
  final String? country;
  final String? description;
  final String? logoUrl;
  final String? imageUrl;

  const ApiBrandResponse({
    required this.brandId,
    required this.brandName,
    this.country,
    this.description,
    this.logoUrl,
    this.imageUrl,
  });

  factory ApiBrandResponse.fromJson(Map<String, dynamic> json) {
    return ApiBrandResponse(
      brandId: json['brandId'] as int? ?? 0,
      brandName: json['brandName'] as String? ?? '',
      country: json['country'] as String?,
      description: json['description'] as String?,
      logoUrl: json['logoUrl'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );
  }
}

// ─────────────────────────────────────────────
// AttributeResponse & ReviewResponse từ BE
// ─────────────────────────────────────────────
class ApiProductAttributeResponse {
  final int attributeId;
  final String attributeName;
  final String attributeValue;

  const ApiProductAttributeResponse({
    required this.attributeId,
    required this.attributeName,
    required this.attributeValue,
  });

  factory ApiProductAttributeResponse.fromJson(Map<String, dynamic> json) {
    return ApiProductAttributeResponse(
      attributeId: json['attributeId'] as int? ?? 0,
      attributeName: json['attributeName'] as String? ?? '',
      attributeValue: json['attributeValue'] as String? ?? '',
    );
  }
}

class ApiReviewResponse {
  final int reviewId;
  final int productId;
  final int userId;
  final String userName;
  final int rating;
  final String comment;
  final String? reviewDate;
  final String? reply;

  const ApiReviewResponse({
    required this.reviewId,
    required this.productId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    this.reviewDate,
    this.reply,
  });

  factory ApiReviewResponse.fromJson(Map<String, dynamic> json) {
    return ApiReviewResponse(
      reviewId: json['reviewId'] as int? ?? 0,
      productId: json['productId'] as int? ?? 0,
      userId: json['userId'] as int? ?? 0,
      userName: json['userName'] as String? ?? 'Khách',
      rating: json['rating'] as int? ?? 5,
      comment: json['comment'] as String? ?? '',
      reviewDate: json['reviewDate'] as String?,
      reply: json['reply'] as String?,
    );
  }
}

class ApiRatingStatsResponse {
  final double averageRating;
  final int totalReviews;
  final Map<String, int> ratingCount;

  const ApiRatingStatsResponse({
    required this.averageRating,
    required this.totalReviews,
    required this.ratingCount,
  });

  factory ApiRatingStatsResponse.fromJson(Map<String, dynamic> json) {
    final Map<String, int> rc = {};
    if (json['ratingCount'] != null) {
      (json['ratingCount'] as Map<String, dynamic>).forEach((k, v) {
        rc[k] = v as int;
      });
    }
    return ApiRatingStatsResponse(
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: json['totalReviews'] as int? ?? 0,
      ratingCount: rc,
    );
  }
}

// ─────────────────────────────────────────────
// Cart Response từ BE  (/api/v1/cart/{userId})
// ─────────────────────────────────────────────
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
    double parseNum(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

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
    double parseNum(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

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

// ─────────────────────────────────────────────
// Order Models
// ─────────────────────────────────────────────

class CreateOrderRequest {
  final int userId;
  final String paymentMethod;
  final String shippingAddress;
  final List<int> cartItemIds;

  const CreateOrderRequest({
    required this.userId,
    required this.paymentMethod,
    required this.shippingAddress,
    required this.cartItemIds,
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'paymentMethod': paymentMethod,
    'shippingAddress': shippingAddress,
    'cartItemIds': cartItemIds,
  };
}

class OrderResponse {
  final int orderId;
  final int userId;
  final String status;
  final String paymentMethod;
  final String? shippingAddress;
  final double totalAmount;
  final List<ApiCartItemResponse> items;
  final String? createdAt;

  const OrderResponse({
    required this.orderId,
    required this.userId,
    required this.status,
    required this.paymentMethod,
    this.shippingAddress,
    required this.totalAmount,
    required this.items,
    this.createdAt,
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    double parseNum(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    final rawItems = json['items'] as List<dynamic>? ?? [];
    return OrderResponse(
      orderId: json['orderId'] as int? ?? 0,
      userId: json['userId'] as int? ?? 0,
      status: json['status'] as String? ?? '',
      paymentMethod: json['paymentMethod'] as String? ?? '',
      shippingAddress: json['shippingAddress'] as String?,
      totalAmount: parseNum(json['totalAmount']),
      items: rawItems
          .map((e) => ApiCartItemResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['createdAt'] as String?,
    );
  }
}


