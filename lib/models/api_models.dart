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
