import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:toastification/toastification.dart';

import 'app/network/utils/api_handler.dart';
import 'app/network/utils/dio_client.dart';
import 'app/services/auth_service.dart';
import 'app/services/env_service.dart';
import 'app/services/network_monitor_service.dart';
import 'app/services/pref.dart';
import 'app/services/session_service.dart';
import 'export.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EnvService.init();
  await Prefs().init();

  // Register global services (mirror WAVTech pattern)
  Get
    ..put(NetworkMonitorService(), permanent: true)
    ..put(ApiHandler(), tag: 'handler', permanent: true)
    ..put(DioClient().getClient(), tag: 'dio_client', permanent: true)
    ..put(AuthService(), permanent: true)
    ..put(SessionService(), permanent: true);

  final savedThemeMode = await AdaptiveTheme.getThemeMode();

  runApp(
    ToastificationWrapper(
      child: AdaptiveTheme(
        light: getTheme(lightColorScheme),
        dark: getTheme(darkColorScheme),
        initial: AdaptiveThemeMode.light,
        builder:  (theme, darkTheme) {
          return GetMaterialApp(
            debugShowCheckedModeBanner: false,
            initialRoute: AppPages.INITIAL,
            getPages: AppPages.routes,
            title: 'CCS',
            theme: getTheme(lightColorScheme),
            darkTheme: getTheme(darkColorScheme),
            themeMode: ThemeMode.light,
          );
        },
      ),
    ),
  );
}
