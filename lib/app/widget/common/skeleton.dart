import 'package:flutter/material.dart';
import '../../constants/ui_constants.dart';

/// A wrapper widget that applies a shimmering overlay to its children.
/// Used to build high-performance skeleton loading screens.
class AppShimmer extends StatefulWidget {
  final Widget child;
  final bool enabled;

  const AppShimmer({
    super.key,
    required this.child,
    this.enabled = true,
  });

  @override
  State<AppShimmer> createState() => _AppShimmerState();
}

class _AppShimmerState extends State<AppShimmer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Adaptive colors for light/dark themes
    final baseColor = isDark ? const Color(0xFF1E2638) : const Color(0xFFEBEBF4);
    final highlightColor = isDark ? const Color(0xFF2A344D) : const Color(0xFFF4F4F4);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: const [
                0.1,
                0.3,
                0.4,
              ],
              begin: const Alignment(-1.0, -0.3),
              end: const Alignment(1.0, 0.3),
              transform: _SlidingGradientTransform(slidePercent: _controller.value),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
      child: widget.child,
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;

  const _SlidingGradientTransform({
    required this.slidePercent,
  });

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    // Sliding translation over double the width to cover the range smoothly
    return Matrix4.translationValues(bounds.width * (slidePercent * 2 - 1), 0.0, 0.0);
  }
}

/// A basic block used to build skeleton structures.
/// Combine multiple [Skeleton] shapes inside [AppShimmer] to create loading screens.
class Skeleton extends StatelessWidget {
  final double? width;
  final double? height;
  final double radius;
  final ShapeBorder shape;

  const Skeleton({
    super.key,
    this.width,
    this.height,
    this.radius = UiConstants.radiusDefault,
    this.shape = const RoundedRectangleBorder(),
  });

  /// Factory for a circle skeleton (e.g. avatars)
  factory Skeleton.circle({
    Key? key,
    double size = 40,
  }) {
    return Skeleton(
      key: key,
      width: size,
      height: size,
      shape: const CircleBorder(),
    );
  }

  /// Factory for a text line skeleton
  factory Skeleton.text({
    Key? key,
    double width = double.infinity,
    double height = 12,
  }) {
    return Skeleton(
      key: key,
      width: width,
      height: height,
      radius: UiConstants.radiusSmall,
    );
  }

  /// Factory for a large card skeleton
  factory Skeleton.card({
    Key? key,
    double? width,
    double height = 150,
  }) {
    return Skeleton(
      key: key,
      width: width,
      height: height,
      radius: UiConstants.radiusLarge,
    );
  }

  /// Helper layout building a dummy ListTile skeleton
  static Widget listTile({Key? key}) {
    return Padding(
      key: key,
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        spacing: 16,
        children: [
          Skeleton.circle(size: 48),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              spacing: 8,
              children: [
                Skeleton.text(width: 120, height: 14),
                Skeleton.text(width: double.infinity, height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: ShapeDecoration(
        color: Colors.white, // Colors are overridden by ShaderMask in AppShimmer
        shape: shape is RoundedRectangleBorder
            ? RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(radius),
              )
            : shape,
      ),
    );
  }
}
