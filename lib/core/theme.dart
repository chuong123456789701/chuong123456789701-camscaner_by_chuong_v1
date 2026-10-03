// lib/core/theme.dart
// Theme Material 3 — xanh dương #2E6BE6, chữ to, nút to cho người lớn tuổi
import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF2E6BE6);
  static const Color primaryDark = Color(0xFF1E4FB8);
  static const Color accent = Color(0xFF4A90E2);
  static const Color background = Color(0xFFF5F7FB);
  static const Color surface = Colors.white;
  static const Color danger = Color(0xFFE53935);
  static const Color success = Color(0xFF43A047);

  static const double fontBody = 15;
  static const double fontButton = 16;
  static const double fontTitle = 20;
  static const double fontHeadline = 26;

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: background,
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
        fontSizeFactor: 1.05,
        bodyColor: const Color(0xFF1A1A1A),
        displayColor: const Color(0xFF1A1A1A),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontSize: fontTitle,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          textStyle: const TextStyle(
              fontSize: fontButton, fontWeight: FontWeight.w600),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: const TextStyle(
              fontSize: fontButton, fontWeight: FontWeight.w600),
          side: const BorderSide(color: primary, width: 1.5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: const TextStyle(
              fontSize: fontButton, fontWeight: FontWeight.w500),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFD5DCE8)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFD5DCE8)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Color(0xFF2B2B2B),
        contentTextStyle: TextStyle(fontSize: fontBody, color: Colors.white),
      ),
    );
  }
}