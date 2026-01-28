import 'package:ccs_app/app/widget/common/text.dart';
import 'package:flutter/material.dart';

import '../../constants/ui_constants.dart';

enum ButtonType { primary, outline, transparent, tonal }

class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.textSize = 16,
    this.type = ButtonType.primary,
    this.bgColor,
    this.txtClr,
    this.icon,
    this.btnVerticalPadding = 16,
    this.btnHorizontalPadding = 16,
    this.btnCornerRadius = UiConstants.radiusDefault,
    this.isLoading = false,
  });

  final VoidCallback? onPressed;
  final double textSize;
  final double btnVerticalPadding;
  final double btnHorizontalPadding;
  final double btnCornerRadius;
  final ButtonType type;
  final String label;
  final Color? bgColor;
  final Color? txtClr;
  final IconData? icon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final baseStyle = ButtonStyle(
      padding: WidgetStateProperty.all(EdgeInsets.symmetric(vertical: btnVerticalPadding, horizontal: btnHorizontalPadding)),
      shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(btnCornerRadius))),
    );

    Color fg;
    Color bg;
    BorderSide? side;

    switch (type) {
      case ButtonType.primary:
        bg = bgColor ?? scheme.primary;
        fg = txtClr ?? scheme.onPrimary;
        break;
      case ButtonType.tonal:
        bg = bgColor ?? scheme.secondaryContainer;
        fg = txtClr ?? scheme.onSecondaryContainer;
        break;
      case ButtonType.outline:
        bg = Colors.transparent;
        fg = txtClr ?? scheme.primary;
        side = BorderSide(color: scheme.primary, width: 1.5);
        break;
      case ButtonType.transparent:
        bg = Colors.transparent;
        fg = txtClr ?? scheme.primary;
        break;
    }

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: baseStyle.copyWith(
        backgroundColor: WidgetStateProperty.all(bg),
        foregroundColor: WidgetStateProperty.all(fg),
        side: side == null ? null : WidgetStateProperty.all(side),
        elevation: WidgetStateProperty.all(type == ButtonType.primary ? 0 : 0),
        maximumSize: WidgetStatePropertyAll(Size.infinite),
      ),
      child: isLoading
          ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(fg)))
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[Icon(icon, size: 18, color: fg), const SizedBox(width: 8)],
                CommonText.medium(label, size: textSize, fontWeight: FontWeight.w600, color: fg),
              ],
            ),
    );
  }
}
