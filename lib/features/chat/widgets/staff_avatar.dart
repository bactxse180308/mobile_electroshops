import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Avatar nhân viên — có ảnh thì hiện ảnh, lỗi/không có thì hiện chữ cái đầu.
class StaffAvatar extends StatelessWidget {
  final String? name;
  final String? avatarUrl;
  const StaffAvatar({super.key, this.name, this.avatarUrl});

  static const double _radius = 16;

  @override
  Widget build(BuildContext context) {
    final initial = (name != null && name!.isNotEmpty) ? name![0].toUpperCase() : 'E';
    final fallback = CircleAvatar(
      radius: _radius,
      backgroundColor: AppColors.primary,
      child: Text(initial,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
    );

    if (avatarUrl == null || avatarUrl!.isEmpty) return fallback;

    return ClipOval(
      child: Image.network(
        avatarUrl!,
        width: _radius * 2,
        height: _radius * 2,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback,
      ),
    );
  }
}
