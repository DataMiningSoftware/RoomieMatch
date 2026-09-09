import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand palette (unchanged from original app)
  static const Color primary = Color(0xFF1C8585); // teal
  static const Color primaryLight = Color(0xFFE3EFEF); // light teal
  static const Color accent = Color(0xFFC7FBD2); // light green
  static const Color accentStrong = Color(0xFF6BC47D); // mid green

  // Neutrals
  static const Color background = Color(0xFFFDFDFD);
  static const Color textDark = Color(0xFF173333);
  static const Color textMuted = Color(0xFF7C8B8B);
  static const Color cardBorder = Color(0xFFE6EDED);

  // Swipe action colours
  static const Color nope = Color(0xFFE4574C);
  static const Color like = Color(0xFF35B37E);
  static const Color superLike = Color(0xFF3A9BE8);
  static const Color rewind = Color(0xFFF5B93E);
}

class AppTheme {
  AppTheme._();

  static const String fontFamily = 'Poppins';

  static ThemeData light() {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.accentStrong,
      surface: Colors.white,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: fontFamily,
      scaffoldBackgroundColor: AppColors.background,
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
        fontFamily: fontFamily,
        bodyColor: AppColors.textDark,
        displayColor: AppColors.textDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.primary),
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          color: AppColors.textDark,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF0F7F7),
        hintStyle: const TextStyle(color: AppColors.textMuted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}
