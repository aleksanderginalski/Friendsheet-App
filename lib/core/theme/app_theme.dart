import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // Color palette from design brief (US-049)
  static const Color primary = Color(0xFF43A047);
  static const Color primaryLight = Color(0xFF76D275);
  static const Color primaryDark = Color(0xFF2E7D32);
  static const Color secondary = Color(0xFFFFB300);
  static const Color surface = Color(0xFFFAFAF7);
  static const Color surfaceSubtle = Color(0xFFF0EDE8);
  static const Color onSurface = Color(0xFF1C1B1F);
  static const Color error = Color(0xFFE53935);

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: secondary,
        surface: surface,
        error: error,
        onPrimary: Colors.white,
        onSecondary: onSurface,
        onSurface: onSurface,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: surface,
      textTheme: GoogleFonts.nunitoTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.nunito(
          fontSize: 30,
          fontWeight: FontWeight.w800,
          height: 1.2,
          color: onSurface,
        ),
        headlineMedium: GoogleFonts.nunito(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          height: 1.2,
          color: onSurface,
        ),
        headlineSmall: GoogleFonts.nunito(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          height: 1.2,
          color: onSurface,
        ),
        bodyLarge: GoogleFonts.nunito(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.5,
          color: onSurface,
        ),
        bodyMedium: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.5,
          color: onSurface,
        ),
        labelSmall: GoogleFonts.nunito(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          height: 1.4,
          letterSpacing: 0.4,
          color: onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: onSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.nunito(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: onSurface,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: Color(0xFF9E9E9E),
      ),
    );
  }
}
