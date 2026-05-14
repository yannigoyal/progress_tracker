import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'color_utils.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      primaryColor: ThemePalette.primary,
      colorScheme: const ColorScheme.dark(
        primary: ThemePalette.primary,
        onPrimary: ThemePalette.white,
        primaryContainer: ThemePalette.primaryDarkContainer,
        onPrimaryContainer: ThemePalette.primaryDarkContainerText,
        secondary: ThemePalette.secondary,
        onSecondary: ThemePalette.white,
        surface: ThemePalette.darkSurface,
        onSurface: ThemePalette.darkOnSurface,
        surfaceContainerHighest: ThemePalette.darkSurfaceContainerHighest,
        surfaceContainerHigh: ThemePalette.darkSurfaceContainerHigh,
        surfaceContainer: ThemePalette.darkSurfaceContainer,
        outline: ThemePalette.darkOutline,
        outlineVariant: ThemePalette.darkOutlineVariant,
        error: ThemePalette.danger,
        onError: ThemePalette.white,
      ),
      scaffoldBackgroundColor: ThemePalette.darkSurface,
      cardTheme: CardThemeData(
        color: ThemePalette.darkSurfaceContainerHigh,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: ThemePalette.darkOutlineVariant,
            width: 1,
          ),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ThemePalette.darkSurfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ThemePalette.darkOutlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ThemePalette.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintStyle: const TextStyle(color: ThemePalette.neutral),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: ThemePalette.darkSurfaceContainerHighest,
        selectedColor: ThemePalette.primaryDarkContainer,
        side: const BorderSide(color: ThemePalette.darkOutlineVariant),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        labelStyle: const TextStyle(fontSize: 13),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: ThemePalette.darkSurfaceContainer,
        indicatorColor: ThemePalette.primaryDarkContainer,
        surfaceTintColor: ThemePalette.transparent,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? ThemePalette.primary : ThemePalette.neutral,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? ThemePalette.primary : ThemePalette.neutral,
            size: 22,
          );
        }),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: ThemePalette.primary,
        foregroundColor: ThemePalette.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dividerTheme: const DividerThemeData(
        color: ThemePalette.darkOutlineVariant,
        thickness: 1,
        space: 1,
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.inter(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: ThemePalette.white,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: ThemePalette.white,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: ThemePalette.darkOnSurface,
        ),
        titleSmall: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: ThemePalette.darkOnSurface,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 15,
          color: ThemePalette.darkBodyLarge,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          color: ThemePalette.darkBodyMedium,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          color: ThemePalette.darkBodySmall,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: ThemePalette.darkOnSurface,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 11,
          color: ThemePalette.neutral,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ThemePalette.primary,
          foregroundColor: ThemePalette.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ThemePalette.primary,
          side: const BorderSide(color: ThemePalette.primary),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      primaryColor: ThemePalette.primary,
      colorScheme: const ColorScheme.light(
        primary: ThemePalette.primary,
        onPrimary: ThemePalette.white,
        primaryContainer: ThemePalette.primaryLightContainer,
        onPrimaryContainer: ThemePalette.primaryDarkContainer,
        secondary: ThemePalette.secondary,
        surface: ThemePalette.lightSurface,
        onSurface: ThemePalette.darkSurface,
        surfaceContainerHighest: ThemePalette.lightSurfaceContainerHighest,
        surfaceContainerHigh: ThemePalette.lightSurfaceContainerHigh,
        surfaceContainer: ThemePalette.lightSurfaceContainer,
        outline: ThemePalette.lightOutline,
      ),
      scaffoldBackgroundColor: ThemePalette.lightSurface,
      cardTheme: CardThemeData(
        color: ThemePalette.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: ThemePalette.lightOutlineVariant,
            width: 1,
          ),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ThemePalette.lightSurfaceContainerHigh,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ThemePalette.lightOutline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ThemePalette.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: ThemePalette.white,
        indicatorColor: ThemePalette.primaryLightContainer,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? ThemePalette.primary : ThemePalette.neutralLight,
          );
        }),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: ThemePalette.primary,
        foregroundColor: ThemePalette.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ThemePalette.primary,
          foregroundColor: ThemePalette.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
