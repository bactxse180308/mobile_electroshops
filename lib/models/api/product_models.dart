import 'common_models.dart';

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
    final rawPrice = json['price'];
    final rawOriginal = json['originalPrice'];
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

  bool get isAvailable =>
      (status?.toUpperCase() ?? '') == 'AVAILABLE' && quantity > 0;
}

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
