import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF2563EB);
  static const primaryDark = Color(0xFF1D4ED8);
  static const accent = Color(0xFFF59E0B);
  static const success = Color(0xFF10B981);
  static const successDark = Color(0xFF059669);
  static const destructive = Color(0xFFEF4444);
  static const background = Color(0xFFFFFFFF);
  static const muted = Color(0xFFF1F5F9);
  static const card = Color(0xFFFFFFFF);
  static const border = Color(0xFFE2E8F0);
  static const secondary = Color(0xFF1E293B);
  static const mutedForeground = Color(0xFF94A3B8);
  static const primaryForeground = Color(0xFFFFFFFF);

  static const heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0F172A), Color(0xFF1E3A5F), Color(0xFF0F172A)],
    stops: [0.0, 0.5, 1.0],
  );

  static const flashGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFDC2626), Color(0xFFEA580C)],
  );

  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
  );

  static const successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF10B981), Color(0xFF059669)],
  );

  static const neonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
  );

  static const profileGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
  );

  static const searchBgGradient = LinearGradient(
    colors: [Color(0xFFE0F2FE), Color(0xFFF0FDF4), Color(0xFFFEF3C7)],
  );

  static const mapRoadLine = Color(0xFF94A3B8);
  static const mapRoadActive = Color(0xFF3B82F6);
  static const mapRoadSuccess = Color(0xFF10B981);
  static const wifiErrBg = Color(0x1AEF4444);
  static const onboarding1 = Color(0xFF4F46E5);
  static const onboarding2 = Color(0xFF10B981);
}
