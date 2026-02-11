import 'package:adaptive_theme/adaptive_theme.dart';

import '../../../export.dart';

class SystemUIConfig {
  static void setSystemBehaviour(AdaptiveThemeMode? mode) {
    final isLight = mode == AdaptiveThemeMode.light;
    final iconMode = isLight ? Brightness.dark : Brightness.light;

    final style = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: iconMode,
      statusBarBrightness: iconMode,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: iconMode,
    );

    SystemChrome.setSystemUIOverlayStyle(style);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }
}
