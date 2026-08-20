import 'package:flutter/services.dart';

/// Centralized utility for triggering premium haptic feedback cues.
class AppHaptics {
  AppHaptics._();

  /// Very light tap feedback, suitable for standard button presses.
  static Future<void> lightTap() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (_) {
      // Gracefully handle platform exceptions (e.g. on web or unsupported devices)
    }
  }

  /// Medium tap feedback, suitable for switches, slider snaps, or dropdown selections.
  static Future<void> mediumTap() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (_) {}
  }

  /// Success event feedback (multiple rapid pulses or heavy pulse depending on platform capabilities).
  static Future<void> success() async {
    try {
      // Trigger double feedback for success on platforms that support it
      await HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 60));
      await HapticFeedback.lightImpact();
    } catch (_) {}
  }

  /// Error or Warning feedback (noticeable vibrating sensation).
  static Future<void> error() async {
    try {
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 80));
      await HapticFeedback.heavyImpact();
    } catch (_) {}
  }
}
