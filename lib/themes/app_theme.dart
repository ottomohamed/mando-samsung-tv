// lib/themes/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // الألوان الأساسية من التصميم
  static const Color backgroundDark = Color(0xFF0A0E1A); // أزرق داكن جداً
  static const Color accentCyan = Color(0xFF00FFFF); // سماوي
  static const Color accentTeal = Color(0xFF30D5C8); // فيروزي
  static const Color glowBlue = Color(0x4D00AEEF); // توهج أزرق شفاف
  static const Color glassWhite = Color(0x80FFFFFF); // أبيض شفاف لتأثير الزجاج
  static const Color textWhite = Colors.white;
  static const Color textGrey = Color(0xFFB0B0B0);
  static const Color connectedGreen = Color(0xFF4CAF50); // أخضر للتوصيل
  
  // أبعاد ثابتة
  static const double glowRadius = 8.0;
  static const double buttonSize = 60.0;
  static const double iconSize = 30.0;
}