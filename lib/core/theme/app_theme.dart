import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand tokens (edit these later when you finalize Aurex colors)
  static const Color primary = Color(0xFF0B1B2B); // deep navy
  static const Color lazyBlack = Color.fromARGB(13, 0, 0, 0); // deep navy
  static const Color accent = Color(0xFFFFC247); // gold/amber
  static const Color bg = Color(0xFFF7F8FA); // light background
  static const Color surface = Colors.white;

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
      ).copyWith(primary: primary, secondary: accent, surface: surface),
    );

    return base.copyWith(
      scaffoldBackgroundColor: bg,
      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        headlineLarge: GoogleFonts.inter(
          fontSize: 44,
          fontWeight: FontWeight.w800,
          height: 1.1,
          color: const Color(0xFF0B1B2B),
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          height: 1.15,
          color: const Color(0xFF0B1B2B),
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF0B1B2B),
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          height: 1.5,
          color: const Color(0xFF243443),
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          height: 1.5,
          color: const Color(0xFF3A4A59),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: primary,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0xFFE8ECF1)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: accent, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),
    );
  }
}
