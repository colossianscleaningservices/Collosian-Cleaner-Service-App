import 'package:flutter/material.dart';
import '../../utils/haptics.dart';

/// A custom-animated checkmark widget.
/// Draws a circle and then draws a checkmark.
/// Automatically plays on mount and triggers success haptic feedback.
class AnimatedCheckmark extends StatefulWidget {
  final double size;
  final Color? color;
  final double strokeWidth;
  final Duration duration;
  final VoidCallback? onComplete;
  final bool triggerHaptics;

  const AnimatedCheckmark({
    super.key,
    this.size = 80,
    this.color,
    this.strokeWidth = 6.0,
    this.duration = const Duration(milliseconds: 800),
    this.onComplete,
    this.triggerHaptics = true,
  });

  @override
  State<AnimatedCheckmark> createState() => _AnimatedCheckmarkState();
}

class _AnimatedCheckmarkState extends State<AnimatedCheckmark>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (widget.triggerHaptics) {
          AppHaptics.success();
        }
        widget.onComplete?.call();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = widget.color ?? Theme.of(context).colorScheme.primary;

    return CustomPaint(
      size: Size(widget.size, widget.size),
      painter: _CheckmarkPainter(
        progress: _animation,
        color: themeColor,
        strokeWidth: widget.strokeWidth,
      ),
    );
  }
}

class _CheckmarkPainter extends CustomPainter {
  final Animation<double> progress;
  final Color color;
  final double strokeWidth;

  _CheckmarkPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  }) : super(repaint: progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    final double halfWidth = size.width / 2;
    final double halfHeight = size.height / 2;
    final double radius = (size.width - strokeWidth) / 2;

    // 1. Draw the circle outline (takes progress from 0.0 to 0.5)
    final double circleProgress = (progress.value / 0.5).clamp(0.0, 1.0);
    if (circleProgress > 0.0) {
      canvas.drawArc(
        Rect.fromCircle(center: Offset(halfWidth, halfHeight), radius: radius),
        -1.5708, // Start at -90 degrees (top)
        6.28319 * circleProgress, // 360 degrees
        false,
        paint,
      );
    }

    // 2. Draw the checkmark lines (takes progress from 0.5 to 1.0)
    final double checkProgress = ((progress.value - 0.5) / 0.5).clamp(0.0, 1.0);
    if (checkProgress > 0.0) {
      final Path path = Path();
      
      // Calculate coordinates relative to center
      final double startX = size.width * 0.28;
      final double startY = size.height * 0.5;
      
      final double midX = size.width * 0.44;
      final double midY = size.height * 0.66;
      
      final double endX = size.width * 0.72;
      final double endY = size.height * 0.36;

      path.moveTo(startX, startY);

      // Define standard drawn segments
      if (checkProgress < 0.5) {
        // First segment (down-right to center angle)
        final double segmentProgress = checkProgress / 0.5;
        final double x = startX + (midX - startX) * segmentProgress;
        final double y = startY + (midY - startY) * segmentProgress;
        path.lineTo(x, y);
      } else {
        // Full first segment + partial second segment
        final double segmentProgress = (checkProgress - 0.5) / 0.5;
        path.lineTo(midX, midY);
        final double x = midX + (endX - midX) * segmentProgress;
        final double y = midY + (endY - midY) * segmentProgress;
        path.lineTo(x, y);
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CheckmarkPainter oldDelegate) => false;
}
