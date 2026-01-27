import 'package:ccs_app/export.dart';

/// A wrapper widget that automatically dismisses the keyboard when tapped
/// outside of input fields. This reduces repetitive GestureDetector code.
class KeyboardDismissibleWrapper extends StatelessWidget {
  const KeyboardDismissibleWrapper({
    required this.child,
    super.key,
    this.behavior = HitTestBehavior.opaque,
  });

  final Widget child;
  final HitTestBehavior behavior;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => context.hideKeyboard(),
    behavior: behavior,
    child: child,
  );
}

/// A specialized wrapper for scrollable content with keyboard dismissal
class ScrollableKeyboardDismissible extends StatelessWidget {
  const ScrollableKeyboardDismissible({
    required this.child,
    super.key,
    this.controller,
    this.physics,
    this.padding,
  });

  final Widget child;
  final ScrollController? controller;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) => KeyboardDismissibleWrapper(
    child: SafeArea(
      child: SingleChildScrollView(
        controller: controller,
        physics: physics ?? const AlwaysScrollableScrollPhysics(),
        padding: padding,
        child: child,
      ),
    ),
  );
}
