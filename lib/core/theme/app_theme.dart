import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _primary = Color(0xFF6366F1);
const _primaryContainer = Color(0xFF1E1F3A);

class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      colorScheme: const ColorScheme.dark(
        primary: _primary,
        onPrimary: Colors.white,
        primaryContainer: _primaryContainer,
        onPrimaryContainer: Color(0xFFC7C8FF),
        secondary: Color(0xFF14B8A6),
        onSecondary: Colors.white,
        surface: Color(0xFF111218),
        onSurface: Color(0xFFE8E9F0),
        surfaceContainerHighest: Color(0xFF1E1F2E),
        surfaceContainerHigh: Color(0xFF1A1B28),
        surfaceContainer: Color(0xFF161722),
        outline: Color(0xFF3A3B50),
        outlineVariant: Color(0xFF2A2B3D),
        error: Color(0xFFF87171),
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: const Color(0xFF111218),
      cardTheme: CardThemeData(
        color: const Color(0xFF1A1B28),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF2A2B3D), width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1E1F2E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2A2B3D)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primary, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(color: Color(0xFF6B7280)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF1E1F2E),
        selectedColor: _primaryContainer,
        side: const BorderSide(color: Color(0xFF2A2B3D)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        labelStyle: const TextStyle(fontSize: 13),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF161722),
        indicatorColor: _primaryContainer,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? _primary : const Color(0xFF6B7280),
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? _primary : const Color(0xFF6B7280),
            size: 22,
          );
        }),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF2A2B3D),
        thickness: 1,
        space: 1,
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.inter(
            fontSize: 32, fontWeight: FontWeight.w700, color: Colors.white),
        titleLarge: GoogleFonts.inter(
            fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        titleMedium: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFE8E9F0)),
        titleSmall: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFFE8E9F0)),
        bodyLarge: GoogleFonts.inter(
            fontSize: 15, color: const Color(0xFFD1D2E0)),
        bodyMedium: GoogleFonts.inter(
            fontSize: 14, color: const Color(0xFFB8B9CC)),
        bodySmall: GoogleFonts.inter(
            fontSize: 12, color: const Color(0xFF9899B0)),
        labelLarge: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFE8E9F0)),
        labelSmall: GoogleFonts.inter(
            fontSize: 11, color: const Color(0xFF6B7280)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.inter(
              fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _primary,
          side: const BorderSide(color: _primary),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      colorScheme: const ColorScheme.light(
        primary: _primary,
        onPrimary: Colors.white,
        primaryContainer: Color(0xFFE8E8FF),
        onPrimaryContainer: Color(0xFF1E1F3A),
        secondary: Color(0xFF14B8A6),
        surface: Color(0xFFF5F5FA),
        onSurface: Color(0xFF111218),
        surfaceContainerHighest: Color(0xFFFFFFFF),
        surfaceContainerHigh: Color(0xFFF0F0F8),
        surfaceContainer: Color(0xFFEAEAF4),
        outline: Color(0xFFDDDDEE),
      ),
      scaffoldBackgroundColor: const Color(0xFFF5F5FA),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE5E5EF), width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF0F0F8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFDDDDEE)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primary, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFE8E8FF),
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? _primary : const Color(0xFF9899B0),
          );
        }),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle:
              GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
