import 'package:flutter/material.dart';
import '../../constants/ui_constants.dart';

/// A wrapper layout component that constraints the max width of its child.
/// Prevents UI lines and cards from stretching too wide on tablet and desktop screens.
class AppConstrainedBox extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final Color? backgroundColor;

  const AppConstrainedBox({
    super.key,
    required this.child,
    this.maxWidth,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveMaxWidth = maxWidth ?? UiConstants.maxTabletWidth;

    return Container(
      color: backgroundColor ?? Colors.transparent,
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: effectiveMaxWidth,
        ),
        child: child,
      ),
    );
  }
}
