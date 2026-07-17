class ApiWishlistResponse {
  final int wishlistId;
  final int userId;
  final String? createdDate;
  final List<ApiWishlistItemResponse> items;

  ApiWishlistResponse({
    required this.wishlistId,
    required this.userId,
    this.createdDate,
    required this.items,
  });

  factory ApiWishlistResponse.fromJson(Map<String, dynamic> json) {
    return ApiWishlistResponse(
      wishlistId: json['wishlistId'] ?? 0,
      userId: json['userId'] ?? 0,
      createdDate: json['createdDate'],
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => ApiWishlistItemResponse.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class ApiWishlistItemResponse {
  final int productId;
  final String productName;
  final String? productImageUrl;
  final String? createdDate;

  ApiWishlistItemResponse({
    required this.productId,
    required this.productName,
    this.productImageUrl,
    this.createdDate,
  });

  factory ApiWishlistItemResponse.fromJson(Map<String, dynamic> json) {
    return ApiWishlistItemResponse(
      productId: json['productId'] ?? 0,
      productName: json['productName'] ?? '',
      productImageUrl: json['productImageUrl'],
      createdDate: json['createdDate'],
    );
  }
}
