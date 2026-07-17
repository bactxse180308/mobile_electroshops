import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

class VNPayCheckingView extends StatelessWidget {
  const VNPayCheckingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: AppSizes.p20),
          Text(
            'Đang kiểm tra kết quả thanh toán…',
            style: TextStyle(
              color: AppColors.mutedForeground,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
