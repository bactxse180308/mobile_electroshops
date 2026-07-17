class ApiVoucherResponse {
  final int voucherId;
  final String voucherCode;
  final String description;
  final double discountValue;
  final String discountType;
  final double minOrderValue;
  final double maxDiscount;
  final int usedCount;
  final String? validFrom;
  final String? validTo;
  final int usageLimit;
  final bool isActive;
  final bool isValid;
  final String? userStatus;

  ApiVoucherResponse({
    required this.voucherId,
    required this.voucherCode,
    required this.description,
    required this.discountValue,
    required this.discountType,
    required this.minOrderValue,
    required this.maxDiscount,
    required this.usedCount,
    this.validFrom,
    this.validTo,
    required this.usageLimit,
    required this.isActive,
    required this.isValid,
    this.userStatus,
  });

  factory ApiVoucherResponse.fromJson(Map<String, dynamic> json) {
    return ApiVoucherResponse(
      voucherId: json['voucherId'] ?? 0,
      voucherCode: json['voucherCode'] ?? '',
      description: json['description'] ?? '',
      discountValue: (json['discountValue'] ?? 0).toDouble(),
      discountType: json['discountType'] ?? 'PERCENTAGE',
      minOrderValue: (json['minOrderValue'] ?? 0).toDouble(),
      maxDiscount: (json['maxDiscount'] ?? 0).toDouble(),
      usedCount: json['usedCount'] ?? 0,
      validFrom: json['validFrom'],
      validTo: json['validTo'],
      usageLimit: json['usageLimit'] ?? 0,
      isActive: json['isActive'] ?? false,
      isValid: json['isValid'] ?? false,
      userStatus: json['userStatus'],
    );
  }
}
