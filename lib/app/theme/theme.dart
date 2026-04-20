import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'styles.dart';

/// Maps [AdaptiveThemeMode] to Flutter [ThemeMode] for [MaterialApp]/[GetMaterialApp].
ThemeMode themeModeFromAdaptive(AdaptiveThemeMode mode) {
  switch (mode) {
    case AdaptiveThemeMode.light:
      return ThemeMode.light;
    case AdaptiveThemeMode.dark:
      return ThemeMode.dark;
    case AdaptiveThemeMode.system:
      return ThemeMode.system;
  }
}

const ColorScheme lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF071E4F),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFFD6E0FF),
  onPrimaryContainer: Color(0xFF071533),
  secondary: Color(0xFF4FB6FF),
  onSecondary: Color(0xFF071E4F),
  secondaryContainer: Color(0xFFD6EFFF),
  onSecondaryContainer: Color(0xFF071533),
  tertiary: Color(0xFF3DD6C6),
  onTertiary: Color(0xFF06201D),
  tertiaryContainer: Color(0xFFCFFAF5),
  onTertiaryContainer: Color(0xFF06201D),
  error: Color(0xFFDE0730),
  onError: Color(0xFFFFFFFF),
  errorContainer: Color(0xFFFFDAD4),
  onErrorContainer: Color(0xFF410001),
  surface: Color(0xFFECF0F5),
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
  var timePickerTheme = TimePickerThemeData(
    backgroundColor: colorScheme.surfaceContainerHighest,
    dayPeriodColor: WidgetStateColor.resolveWith((states) => states.contains(WidgetState.selected) ? colorScheme.primary : colorScheme.outlineVariant),
    dayPeriodTextColor: WidgetStateColor.resolveWith((states) => states.contains(WidgetState.selected) ? colorScheme.onPrimary : colorScheme.onSurfaceVariant),
    dialBackgroundColor: colorScheme.secondaryContainer,
    dialHandColor: colorScheme.primary,
    dialTextColor: WidgetStateColor.resolveWith((states) => states.contains(WidgetState.selected) ? colorScheme.onPrimary : colorScheme.primary),
    hourMinuteColor: WidgetStateColor.resolveWith((states) => states.contains(WidgetState.selected) ? colorScheme.primary : colorScheme.outlineVariant),
    hourMinuteTextColor: WidgetStateColor.resolveWith((states) => states.contains(WidgetState.selected) ? colorScheme.onPrimary : colorScheme.primary),
    hourMinuteTextStyle: textTheme.headlineMedium?.copyWith(
      fontSize: 28,
      fontWeight: FontWeight.w800,
    ),
    dayPeriodTextStyle: textTheme.titleMedium?.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
    dialTextStyle: textTheme.titleMedium?.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w400,
    ),
    helpTextStyle: textTheme.titleMedium?.copyWith(fontSize: 16, fontWeight: FontWeight.w600, color: colorScheme.onSurface),
    timeSelectorSeparatorColor: WidgetStateColor.resolveWith((states) => colorScheme.primary),
  );

  var datePickerTheme = DatePickerThemeData(
    backgroundColor: colorScheme.surfaceContainerHighest,
    headerBackgroundColor: colorScheme.secondaryContainer,
    headerForegroundColor: colorScheme.onSecondaryContainer,
    headerHeadlineStyle: textTheme.headlineMedium?.copyWith(
      fontSize: 24,
      fontWeight: FontWeight.w800,
    ),
    headerHelpStyle: textTheme.titleMedium?.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: colorScheme.onSurfaceVariant,
    ),
    weekdayStyle: textTheme.titleSmall?.copyWith(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: colorScheme.onSurfaceVariant,
    ),
    dayBackgroundColor: WidgetStateColor.resolveWith((states) => states.contains(WidgetState.selected) ? colorScheme.primary : Colors.transparent),
    dayForegroundColor: WidgetStateColor.resolveWith((states) => states.contains(WidgetState.selected) ? colorScheme.onPrimary : colorScheme.onSurface),
    dayOverlayColor: WidgetStateProperty.resolveWith((states) => colorScheme.primary.withValues(alpha: 0.12)),
    dayStyle: textTheme.bodyLarge?.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    todayForegroundColor: WidgetStatePropertyAll(colorScheme.primary),
    todayBackgroundColor: WidgetStateProperty.all(colorScheme.primary.withValues(alpha: .12)),
    todayBorder: BorderSide(
      color: colorScheme.primary,
      width: 1,
    ),
    yearBackgroundColor: WidgetStateColor.resolveWith((states) => states.contains(WidgetState.selected) ? colorScheme.primary : Colors.transparent),
    yearForegroundColor: WidgetStateColor.resolveWith((states) => states.contains(WidgetState.selected) ? colorScheme.onPrimary : colorScheme.onSurfaceVariant),
    yearOverlayColor: WidgetStateProperty.resolveWith((states) => colorScheme.primary.withValues(alpha: 0.12)),
    yearStyle: textTheme.bodyLarge?.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    cancelButtonStyle: ButtonStyle(foregroundColor: WidgetStateProperty.all(colorScheme.onSurfaceVariant)),
    confirmButtonStyle: ButtonStyle(foregroundColor: WidgetStateProperty.all(colorScheme.primary)),
  );

  final isDark = colorScheme.brightness == Brightness.dark;

  return ThemeData(
    useMaterial3: true,
    brightness: colorScheme.brightness,
    colorScheme: colorScheme,
    textTheme: textTheme.apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    ),
    timePickerTheme: timePickerTheme,
    datePickerTheme: datePickerTheme,
    scaffoldBackgroundColor: colorScheme.surface,
    canvasColor: colorScheme.surfaceContainerHighest,
    splashFactory: InkSparkle.splashFactory,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
      },
    ),
    dividerTheme: DividerThemeData(
      color: colorScheme.outlineVariant,
      thickness: 1,
      space: 1,
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 2,
      centerTitle: false,
      backgroundColor: colorScheme.surface.withValues(alpha: 0.94),
      surfaceTintColor: colorScheme.surfaceTint.withValues(alpha: 0.12),
      foregroundColor: colorScheme.primary,
      systemOverlayStyle: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        // Never use infinite min width: breaks Row/Flex (e.g. inline actions on web).
        minimumSize: WidgetStateProperty.all(const Size(0, 48)),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        elevation: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return 0.0;
          if (states.contains(WidgetState.pressed)) return 0.0;
          return 1.0;
        }),
        animationDuration: const Duration(milliseconds: 200),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: colorScheme.primary,
      indicatorColor: colorScheme.primaryContainer.withValues(alpha: 0.2),
      labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
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
