import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

String orderStatusLabel(String status) {
  switch (status.toUpperCase()) {
    case 'PENDING':
      return 'Chờ xử lý';
    case 'CONFIRMED':
      return 'Đã xác nhận';
    case 'PROCESSING':
      return 'Đang chuẩn bị';
    case 'SHIPPED':
      return 'Đang giao hàng';
    case 'DELIVERED':
      return 'Đã giao hàng';
    case 'CANCELLED':
      return 'Đã hủy';
    case 'REFUNDED':
      return 'Đã hoàn tiền';
    default:
      return status;
  }
}

Color orderStatusColor(String status) {
  switch (status.toUpperCase()) {
    case 'PENDING':
      return Colors.orange;
    case 'CONFIRMED':
      return Colors.indigo;
    case 'PROCESSING':
      return Colors.purple;
    case 'SHIPPED':
      return Colors.blue;
    case 'DELIVERED':
      return AppColors.success;
    case 'CANCELLED':
    case 'REFUNDED':
      return AppColors.destructive;
    default:
      return AppColors.mutedForeground;
  }
}
