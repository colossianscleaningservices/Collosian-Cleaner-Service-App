import 'package:flutter/material.dart';

/// Standard layout breakpoints for the application
class AppBreakpoints {
  AppBreakpoints._();

  static const double mobile = 640;
  static const double tablet = 1024;
}

/// A builder widget that returns different layouts depending on the screen width.
class ResponsiveLayout extends StatelessWidget {
  final WidgetBuilder mobileBuilder;
  final WidgetBuilder? tabletBuilder;
  final WidgetBuilder? desktopBuilder;

  const ResponsiveLayout({
    super.key,
    required this.mobileBuilder,
    this.tabletBuilder,
    this.desktopBuilder,
  });

  /// Helper to check device category based on context size
  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < AppBreakpoints.mobile;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= AppBreakpoints.mobile && width < AppBreakpoints.tablet;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= AppBreakpoints.tablet;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width >= AppBreakpoints.tablet && desktopBuilder != null) {
      return desktopBuilder!(context);
    }

    if (width >= AppBreakpoints.mobile && tabletBuilder != null) {
      return tabletBuilder!(context);
    }

    return mobileBuilder(context);
  }
}

/// A utility that resolves to a specific value based on screen width.
class ResponsiveValue<T> {
  final BuildContext context;
  final T mobile;
  final T? tablet;
  final T? desktop;

  const ResponsiveValue(
    this.context, {
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  T get value {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= AppBreakpoints.tablet && desktop != null) {
      return desktop!;
    }
    if (width >= AppBreakpoints.mobile && tablet != null) {
      return tablet!;
    }
    return mobile;
  }
}
