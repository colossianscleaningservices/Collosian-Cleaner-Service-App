import 'package:flutter/material.dart';
import '../theme/theme.dart';
import '../widget/widgets.dart';
import '../model/menu_model.dart';
import '../widget/common/common_button.dart';
import 'package:get/get.dart' hide MapExtension, Trans;
import 'package:iconsax_plus/iconsax_plus.dart';

extension CcsStringX on String {
  bool get isNullOrEmpty => trim().isEmpty;

  int toInt() => int.tryParse(this) ?? 0;
  double toDouble() => double.tryParse(this) ?? 0.0;

  Color parseHexColor({Color fallback = Colors.grey}) {
    if (isNullOrEmpty) return fallback;
    final cleaned = replaceAll('#', '').trim();
    final value = int.tryParse('0xFF$cleaned');
    return Color(value ?? fallback.toARGB32());
  }

  String toTitleCase() {
    final trimmed = trim();
    if (trimmed.isEmpty) return this;
    return trimmed
        .split(RegExp(r'\s+'))
        .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
        .join(' ');
  }
}

extension CcsContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  bool get isModeDark => theme.brightness == Brightness.dark;

  /// WAVTech-style: map to app-defined schemes.
  ColorScheme get colorScheme => isModeDark ? darkColorScheme : lightColorScheme;

  MediaQueryData get mediaQuery => MediaQuery.of(this);
  double get height => mediaQuery.size.height;
  double get width => mediaQuery.size.width;

  EdgeInsets get mediaQueryPadding => mediaQuery.padding;
  double get topPadding => mediaQuery.padding.top;
  double get bottomPadding => mediaQuery.padding.bottom;
  double get topInset => mediaQuery.viewInsets.top;
  double get bottomInset => mediaQuery.viewInsets.bottom;

  void hideKeyboard() {
    final currentFocus = FocusScope.of(this);
    if (!currentFocus.hasPrimaryFocus && currentFocus.hasFocus) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  List<BoxShadow> effectiveShadows({
    Color? shadowColor,
    Offset? offset,
    double? blurRadius,
  }) =>
      [
        BoxShadow(
          color: theme.brightness == Brightness.dark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.white.withValues(alpha: 0.8),
          offset: offset ?? const Offset(-2, -2),
          blurRadius: blurRadius ?? 8,
        ),
        BoxShadow(
          color: shadowColor ??
              (theme.brightness == Brightness.dark
                  ? Colors.black.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.1)),
          offset: offset ?? const Offset(2, 2),
          blurRadius: blurRadius ?? 8,
        ),
      ];
}

bool isResponseBlank(dynamic value) {
  if (value is String) return value.trim().isEmpty;
  if (value is Iterable) return value.isEmpty;
  if (value is Map) return value.isEmpty;
  return false;
}



class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}


