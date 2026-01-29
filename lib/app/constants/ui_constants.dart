import '../../export.dart';

class UiConstants {
  UiConstants._();

  static const EdgeInsets padding = EdgeInsets.all(18);
  static const double gap = 12;

  // Dimensions
  static const double defaultPadding = 16;
  static const double defaultMargin = 16;
  static const double defaultRadius = 12;
  static const double defaultIconSize = 24;
  static const double defaultButtonHeight = 48;
  static const double defaultInputHeight = 48;

  static const double margin32 = 32;
  static const double margin36 = 36;

  // Border Radius System (6-16 based on element size)
  static const double radiusSmall = 6; // Small icons, tiny chips
  static const double radiusMedium = 10; // Medium icons, small buttons
  static const double radiusDefault = 12; // Default for buttons, text fields
  static const double radiusLarge = 14; // Cards, containers
  static const double radiusXLarge = 16; // Large cards, FABs (max)

  // Size-based radius helpers
  static double radiusForSize(double size) {
    if (size <= 32) return radiusSmall;
    if (size <= 48) return radiusMedium;
    if (size <= 64) return radiusDefault;
    if (size <= 96) return radiusLarge;
    return radiusXLarge;
  }
}
