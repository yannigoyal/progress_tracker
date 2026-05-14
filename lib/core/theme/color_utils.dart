import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

abstract final class ThemePalette {
  static const transparent = Colors.transparent;
  static const white = Colors.white;

  static const primary = Color(0xFF6366F1);
  static const primaryDarkContainer = Color(0xFF1E1F3A);
  static const primaryDarkContainerText = Color(0xFFC7C8FF);
  static const primaryLightContainer = Color(0xFFE8E8FF);
  static const secondary = Color(0xFF14B8A6);
  static const danger = Color(0xFFF87171);
  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);

  static const darkSurface = Color(0xFF111218);
  static const darkSurfaceContainerHighest = Color(0xFF1E1F2E);
  static const darkSurfaceContainerHigh = Color(0xFF1A1B28);
  static const darkSurfaceContainer = Color(0xFF161722);
  static const darkOutline = Color(0xFF3A3B50);
  static const darkOutlineVariant = Color(0xFF2A2B3D);
  static const darkOnSurface = Color(0xFFE8E9F0);
  static const darkBodyLarge = Color(0xFFD1D2E0);
  static const darkBodyMedium = Color(0xFFB8B9CC);
  static const darkBodySmall = Color(0xFF9899B0);

  static const lightSurface = Color(0xFFF5F5FA);
  static const lightSurfaceContainerHighest = white;
  static const lightSurfaceContainerHigh = Color(0xFFF0F0F8);
  static const lightSurfaceContainer = Color(0xFFEAEAF4);
  static const lightOutline = Color(0xFFDDDDEE);
  static const lightOutlineVariant = Color(0xFFE5E5EF);

  static const neutral = Color(0xFF6B7280);
  static const neutralLight = Color(0xFF9899B0);

  static const categoryContent = Color(0xFFEC4899);
  static const categoryProject = Color(0xFF8B5CF6);
}

extension ColorUtil on BuildContext {
  Brightness get _br => Theme.of(this).brightness;
  bool get _light => _br == Brightness.light;

  Color dynamicColor({required int light, required int dark}) =>
      _light ? Color(light) : Color(dark);

  Color dynamicColour({required Color light, required Color dark}) =>
      _light ? light : dark;

  Color get transparent => ThemePalette.transparent;
  Color get white => ThemePalette.white;

  Color get primary => ThemePalette.primary;
  Color get primaryDarkContainer => ThemePalette.primaryDarkContainer;
  Color get primaryDarkContainerText => ThemePalette.primaryDarkContainerText;
  Color get primaryLightContainer => ThemePalette.primaryLightContainer;
  Color get secondary => ThemePalette.secondary;
  Color get danger => ThemePalette.danger;

  // Brand
  Color get brandColor1 =>
      dynamicColour(light: HexColor('#5D48D0'), dark: HexColor('#7B68EE'));
  Color get brandColor2 =>
      dynamicColour(light: HexColor('#FF6B6B'), dark: HexColor('#FF8E8E'));

  // Background
  Color get bgPrimary =>
      dynamicColour(light: HexColor('#FFFFFF'), dark: HexColor('#121212'));
  Color get bgSecondary =>
      dynamicColour(light: HexColor('#F5F5F5'), dark: HexColor('#1E1E1E'));
  Color get bgCard =>
      dynamicColour(light: HexColor('#FFFFFF'), dark: HexColor('#252525'));

  // Text
  Color get textPrimary =>
      dynamicColour(light: HexColor('#1A1A1A'), dark: HexColor('#F0F0F0'));
  Color get textSecondary =>
      dynamicColour(light: HexColor('#6B6B6B'), dark: HexColor('#A0A0A0'));
  Color get textHint =>
      dynamicColour(light: HexColor('#ADADAD'), dark: HexColor('#5C5C5C'));

  // Status
  Color get success => ThemePalette.success;
  Color get warning => ThemePalette.warning;
  Color get error =>
      dynamicColour(light: HexColor('#E74C3C'), dark: HexColor('#C0392B'));
  Color get info =>
      dynamicColour(light: HexColor('#3498DB'), dark: HexColor('#2980B9'));

  Color get darkSurface => ThemePalette.darkSurface;
  Color get darkSurfaceContainerHighest =>
      ThemePalette.darkSurfaceContainerHighest;
  Color get darkSurfaceContainerHigh => ThemePalette.darkSurfaceContainerHigh;
  Color get darkSurfaceContainer => ThemePalette.darkSurfaceContainer;
  Color get darkOutline => ThemePalette.darkOutline;
  Color get darkOutlineVariant => ThemePalette.darkOutlineVariant;
  Color get darkOnSurface => ThemePalette.darkOnSurface;
  Color get darkBodyLarge => ThemePalette.darkBodyLarge;
  Color get darkBodyMedium => ThemePalette.darkBodyMedium;
  Color get darkBodySmall => ThemePalette.darkBodySmall;

  Color get lightSurface => ThemePalette.lightSurface;
  Color get lightSurfaceContainerHighest =>
      ThemePalette.lightSurfaceContainerHighest;
  Color get lightSurfaceContainerHigh => ThemePalette.lightSurfaceContainerHigh;
  Color get lightSurfaceContainer => ThemePalette.lightSurfaceContainer;
  Color get lightOutline => ThemePalette.lightOutline;
  Color get lightOutlineVariant => ThemePalette.lightOutlineVariant;

  Color get neutral => ThemePalette.neutral;
  Color get neutralLight => ThemePalette.neutralLight;

  // Border
  Color get borderLight =>
      dynamicColour(light: HexColor('#E0E0E0'), dark: HexColor('#2C2C2C'));
  Color get borderMid =>
      dynamicColour(light: HexColor('#BDBDBD'), dark: HexColor('#3D3D3D'));

  // Surface
  Color get surfaceElevated =>
      dynamicColour(light: HexColor('#FAFAFA'), dark: HexColor('#1C1C1C'));

  Color get categoryDsa => primary;
  Color get categoryContent => ThemePalette.categoryContent;
  Color get categoryWorkout => success;
  Color get categoryReading => warning;
  Color get categoryLearning => secondary;
  Color get categoryMisc => neutral;
  Color get categoryProject => ThemePalette.categoryProject;
}
