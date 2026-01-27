import 'package:flutter/material.dart';

import 'styles.dart';

// WAVTech-style: explicit Material 3 ColorSchemes + minimal ThemeData.
// Since most UI is custom, keep component overrides close to zero.

const ColorScheme lightColorScheme = ColorScheme(
  brightness: Brightness.light,

  primary: Color(0xFF071E4F), // CCS navy
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFFD6E0FF),
  onPrimaryContainer: Color(0xFF071533),

  secondary: Color(0xFF4FB6FF), // CCS sky-blue accent
  onSecondary: Color(0xFF071E4F),
  secondaryContainer: Color(0xFFD6EFFF),
  onSecondaryContainer: Color(0xFF071533),

  tertiary: Color(0xFF3DD6C6), // optional calm teal for statuses
  onTertiary: Color(0xFF06201D),
  tertiaryContainer: Color(0xFFCFFAF5),
  onTertiaryContainer: Color(0xFF06201D),

  error: Color(0xFFDE0730),
  onError: Color(0xFFFFFFFF),
  errorContainer: Color(0xFFFFDAD4),
  onErrorContainer: Color(0xFF410001),

  surface: Color(0xFFECF0F5), // subtle bluish-grey
  onSurface: Color(0xFF0F172A),
  onSurfaceVariant: Color(0xFF64748B),

  surfaceTint: Color(0xFF071E4F),

  outline: Color(0xFFC6D3E6),
  outlineVariant: Color(0xFFE6ECF5),

  shadow: Color(0x33000000),
  scrim: Color(0x33000000),

  inverseSurface: Color(0xFF1B2538),
  inversePrimary: Color(0xFF9AB1E8),

  primaryFixed: Color(0xFFD6E0FF),
  onPrimaryFixed: Color(0xFF071533),
  primaryFixedDim: Color(0xFFAFC1F0),
  onPrimaryFixedVariant: Color(0xFF1F3D7A),

  secondaryFixed: Color(0xFFD6EFFF),
  onSecondaryFixed: Color(0xFF071533),
  secondaryFixedDim: Color(0xFF9FD5FF),
  onSecondaryFixedVariant: Color(0xFF0A2A4B),

  tertiaryFixed: Color(0xFFCFFAF5),
  onTertiaryFixed: Color(0xFF06201D),
  tertiaryFixedDim: Color(0xFF7FEADF),
  onTertiaryFixedVariant: Color(0xFF0B3B35),

  surfaceDim: Color(0xFFE8EEF7),
  surfaceBright: Color(0xFFFFFFFF),
  surfaceContainerLowest: Color(0xFFFFFFFF),
  surfaceContainerLow: Color(0xFFF7F9FE),
  surfaceContainer: Color(0xFFF1F5FB),
  surfaceContainerHigh: Color(0xFFEAF1FA),
  surfaceContainerHighest: Color(0xFFFFFFFF),
);

const ColorScheme darkColorScheme = ColorScheme(
  brightness: Brightness.dark,

  primary: Color(0xFF9AB1E8),
  onPrimary: Color(0xFF0B183A),
  primaryContainer: Color(0xFF1A2A4A),
  onPrimaryContainer: Color(0xFFC5D4F0),

  secondary: Color(0xFF4FB6FF),
  onSecondary: Color(0xFF071533),
  secondaryContainer: Color(0xFF0F2B52),
  onSecondaryContainer: Color(0xFFCFE9FF),

  tertiary: Color(0xFF3DD6C6),
  onTertiary: Color(0xFF06201D),
  tertiaryContainer: Color(0xFF0B3B35),
  onTertiaryContainer: Color(0xFFCFFAF5),

  error: Color(0xFFDE0730),
  onError: Color(0xFFFFFFFF),
  errorContainer: Color(0xFF410001),
  onErrorContainer: Color(0xFFFFDAD4),

  surface: Color(0xFF101320),
  onSurface: Color(0xFFE1E6FF),
  onSurfaceVariant: Color(0xFFC2C9DF),

  surfaceTint: Color(0xFF9AB1E8),

  outline: Color(0xFF49506A),
  outlineVariant: Color(0xFF30364E),

  shadow: Color(0x40000000),
  scrim: Color(0x66000000),

  inverseSurface: Color(0xFFF1F3FA),
  inversePrimary: Color(0xFF1F3D7A),

  primaryFixed: Color(0xFFD6E0FF),
  onPrimaryFixed: Color(0xFF071533),
  primaryFixedDim: Color(0xFFAFC1F0),
  onPrimaryFixedVariant: Color(0xFF1F3D7A),

  secondaryFixed: Color(0xFFD6EFFF),
  onSecondaryFixed: Color(0xFF071533),
  secondaryFixedDim: Color(0xFF9FD5FF),
  onSecondaryFixedVariant: Color(0xFF0A2A4B),

  tertiaryFixed: Color(0xFFCFFAF5),
  onTertiaryFixed: Color(0xFF06201D),
  tertiaryFixedDim: Color(0xFF7FEADF),
  onTertiaryFixedVariant: Color(0xFF0B3B35),

  surfaceDim: Color(0xFF0C0F1A),
  surfaceBright: Color(0xFF1A2030),
  surfaceContainerLowest: Color(0xFF05060C),
  surfaceContainerLow: Color(0xFF111728),
  surfaceContainer: Color(0xFF161E31),
  surfaceContainerHigh: Color(0xFF1F273B),
  surfaceContainerHighest: Color(0xFF293247),
);

ThemeData getTheme(ColorScheme colorScheme) {
  return ThemeData(
      useMaterial3: true,
      brightness: colorScheme.brightness,
      colorScheme: colorScheme,
      textTheme: textTheme.apply(
        bodyColor: colorScheme.onSurface,
        displayColor: colorScheme.onSurface,
      ),
      scaffoldBackgroundColor: colorScheme.surface,
      canvasColor: colorScheme.surfaceContainerHighest,
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.primary,
        indicatorColor: colorScheme.primaryContainer.withValues(alpha: 0.2),
        labelTextStyle: WidgetStateTextStyle.resolveWith((states) {
          final baseStyle = textTheme.labelLarge ?? const TextStyle();
          if (states.contains(WidgetState.selected)) {
            return baseStyle.copyWith(color: colorScheme.secondary);
          }
          return baseStyle.copyWith(
            color: colorScheme.onPrimary.withValues(alpha: 0.5),
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: colorScheme.secondary);
          }
          return IconThemeData(color: colorScheme.onPrimary.withValues(alpha: 0.5));
        }),
      ),
    );
}

