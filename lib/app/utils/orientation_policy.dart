import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Locks phones to portrait; tablets and foldables may rotate freely.
class OrientationPolicy {
  OrientationPolicy._();

  /// Material compact/large breakpoint (shortest logical side in dp).
  static const double tabletShortestSideDp = 600;

  static bool isFoldable(List<DisplayFeature> displayFeatures) {
    return displayFeatures.any(
      (f) =>
          f.type == DisplayFeatureType.fold ||
          f.type == DisplayFeatureType.hinge,
    );
  }

  static bool isTablet(Size logicalSize) {
    return logicalSize.shortestSide >= tabletShortestSideDp;
  }

  static bool shouldAllowRotation({
    required Size logicalSize,
    required List<DisplayFeature> displayFeatures,
  }) {
    if (kIsWeb) return true;
    if (isFoldable(displayFeatures)) return true;
    return isTablet(logicalSize);
  }

  static Future<void> apply({required bool allowRotation}) async {
    if (kIsWeb) return;

    await SystemChrome.setPreferredOrientations(
      allowRotation
          ? const [
              DeviceOrientation.portraitUp,
              DeviceOrientation.portraitDown,
              DeviceOrientation.landscapeLeft,
              DeviceOrientation.landscapeRight,
            ]
          : const [DeviceOrientation.portraitUp],
    );
  }

  static Future<void> applyFromView() async {
    if (kIsWeb) return;

    final view = PlatformDispatcher.instance.views.first;
    final logicalSize = view.physicalSize / view.devicePixelRatio;

    await apply(
      allowRotation: shouldAllowRotation(
        logicalSize: logicalSize,
        displayFeatures: view.displayFeatures,
      ),
    );
  }

  static Future<void> applyFromMediaQuery({
    required Size logicalSize,
    required List<DisplayFeature> displayFeatures,
  }) {
    return apply(
      allowRotation: shouldAllowRotation(
        logicalSize: logicalSize,
        displayFeatures: displayFeatures,
      ),
    );
  }
}
