import 'package:ccs_app/export.dart';
import 'package:google_fonts/google_fonts.dart';

// Shared text theme entry point (WAVTech-style), using Manrope.
final TextTheme textTheme = GoogleFonts.manropeTextTheme(
  Typography.material2021().englishLike,
);

ButtonStyle filledIconButtonStyle(BuildContext context) => ButtonStyle(
      backgroundColor: WidgetStateProperty.all(
        context.colorScheme.secondaryContainer.withValues(alpha: 0.6),
      ),
      iconColor: WidgetStateProperty.all(context.colorScheme.secondary),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(UiConstants.radiusLarge)),
      ),
      padding: WidgetStateProperty.all(const EdgeInsets.all(8)),
    );
