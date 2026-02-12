import 'package:ccs_app/export.dart';

/// A reusable bottom action bar widget that provides consistent styling
/// and behavior across the application for bottom navigation areas.
class BottomActionBar extends StatelessWidget {
  const BottomActionBar({
    required this.children,
    super.key,
    this.padding = const EdgeInsets.fromLTRB(16, 12, 16, 24),
    this.backgroundColor,
    this.showSafeArea = true,
  });

  final List<Widget> children;
  final EdgeInsets padding;
  final Color? backgroundColor;
  final bool showSafeArea;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: padding,
      color: backgroundColor ?? Colors.transparent,
      child: Row(mainAxisSize: MainAxisSize.min, children: children),
    );

    if (showSafeArea) {
      return SafeArea(top: false, bottom: false, child: content);
    }

    return content;
  }
}

/// A specialized bottom action bar for single button actions
class SingleActionBottomBar extends StatelessWidget {
  const SingleActionBottomBar({
    required this.label,
    required this.onPressed,
    super.key,
    this.buttonType = ButtonType.primary,
    this.backgroundColor,
  });

  final String label;
  final VoidCallback onPressed;
  final ButtonType buttonType;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) => BottomActionBar(
        backgroundColor: backgroundColor,
        children: [Expanded(child: SizedBox(width: double.infinity, child: AppButton(label: label, onPressed: onPressed, type: buttonType)))],
      );
}

/// A specialized bottom action bar for dual button actions
class DualActionBottomBar extends StatelessWidget {
  const DualActionBottomBar({
    required this.primaryLabel,
    required this.primaryOnPressed,
    required this.secondaryLabel,
    required this.secondaryOnPressed,
    super.key,
    this.primaryButtonType = ButtonType.primary,
    this.secondaryButtonType = ButtonType.tonal,
    this.backgroundColor,
    this.spacing = 16.0,
    this.showSecondary = true,
    this.isLoading = false,
  });

  final String primaryLabel;
  final VoidCallback primaryOnPressed;
  final String secondaryLabel;
  final VoidCallback secondaryOnPressed;
  final ButtonType primaryButtonType;
  final ButtonType secondaryButtonType;
  final Color? backgroundColor;
  final double spacing;
  final bool showSecondary;
  final bool isLoading;

  @override
  Widget build(BuildContext context) => BottomActionBar(
        backgroundColor: backgroundColor,
        children: [
          if (showSecondary)
            Expanded(
              child: AppButton(
                label: secondaryLabel,
                onPressed: secondaryOnPressed,
                type: secondaryButtonType,
              ).marginOnly(right: spacing),
            ),
          Expanded(
            child: AppButton(
              isLoading: isLoading,
              label: primaryLabel,
              onPressed: primaryOnPressed,
              type: primaryButtonType,
            ),
          ),
        ],
      );
}
