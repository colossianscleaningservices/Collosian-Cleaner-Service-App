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

  // Max bounds constraints for responsive layout
  static const double maxMobileWidth = 480.0;
  static const double maxTabletWidth = 768.0;

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

class AppSpacing {
  AppSpacing._();

  static const double xxs = 4.0;
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // EdgeInsets helpers for quick layout padding
  static const EdgeInsets paddingXS = EdgeInsets.all(xs);
  static const EdgeInsets paddingSM = EdgeInsets.all(sm);
  static const EdgeInsets paddingMD = EdgeInsets.all(md);
  static const EdgeInsets paddingLG = EdgeInsets.all(lg);
  
  static const EdgeInsets horizontalXS = EdgeInsets.symmetric(horizontal: xs);
  static const EdgeInsets horizontalSM = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets horizontalMD = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets horizontalLG = EdgeInsets.symmetric(horizontal: lg);

  static const EdgeInsets verticalXS = EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets verticalSM = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets verticalMD = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets verticalLG = EdgeInsets.symmetric(vertical: lg);
}

class AppGradients {
  AppGradients._();

  static Gradient primary(BuildContext context) => LinearGradient(
        colors: [
          context.colorScheme.primary,
          context.colorScheme.primary.withValues(alpha: 0.8),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static Gradient secondary(BuildContext context) => LinearGradient(
        colors: [
          context.colorScheme.secondary,
          context.colorScheme.secondary.withValues(alpha: 0.8),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static Gradient success(BuildContext context) => LinearGradient(
        colors: [
          const Color(0xFF10B981),
          const Color(0xFF059669),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static Gradient warning(BuildContext context) => LinearGradient(
        colors: [
          const Color(0xFFF59E0B),
          const Color(0xFFD97706),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static Gradient error(BuildContext context) => LinearGradient(
        colors: [
          context.colorScheme.error,
          context.colorScheme.error.withValues(alpha: 0.8),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
}

class AppShadows {
  AppShadows._();

  static List<BoxShadow> light(BuildContext context) => [
        BoxShadow(
          color: context.colorScheme.shadow.withValues(alpha: 0.04),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> medium(BuildContext context) => [
        BoxShadow(
          color: context.colorScheme.shadow.withValues(alpha: 0.06),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: context.colorScheme.shadow.withValues(alpha: 0.02),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> highlight(BuildContext context, {Color? color}) => [
        BoxShadow(
          color: (color ?? context.colorScheme.primary).withValues(alpha: 0.12),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ];
}

