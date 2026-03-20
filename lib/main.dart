import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:toastification/toastification.dart';

import 'app/network/utils/api_handler.dart';
import 'app/network/utils/dio_client.dart';
import 'app/network/utils/system_ui_config.dart';
import 'app/services/api_error_handler.dart';
import 'app/services/crashlytics_service.dart';
import 'app/services/env_service.dart';
import 'app/services/network_monitor_service.dart';
import 'app/services/onesignal_service.dart';
import 'app/services/pref.dart';
import 'app/services/session_service.dart';
import 'export.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  setupErrorHandling();

  await EnvService.init();
  await Prefs().init();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  try {
    await CrashlyticsService.instance.initialize();
  } catch (e) {
    debugPrint('main: Failed to initialize Crashlytics: $e');
  }

  try {
    await OneSignalService.initialize(EnvService.onesignalAppId);
  } on Exception catch (e) {
    debugPrint('main: OneSignal initialization failed: $e');
  }

  getTimeZone().then((onValue) {
    Get
      ..put(NetworkMonitorService(), permanent: true)
      ..put(ApiHandler(), tag: 'handler', permanent: true)
      ..put(DioClient().getClient(), tag: 'dio_client', permanent: true)..put(SessionService(), permanent: true)..put(ApiErrorHandler(), permanent: true);
  });

  final savedThemeMode = await AdaptiveTheme.getThemeMode();
  SystemUIConfig.setSystemBehaviour(savedThemeMode);

  runApp(
    ToastificationWrapper(
      child: AdaptiveTheme(
        light: getTheme(lightColorScheme),
        dark: getTheme(darkColorScheme),
        initial: savedThemeMode ?? AdaptiveThemeMode.light,
        builder: (theme, darkTheme) {
          return GetMaterialApp(
            defaultTransition: Transition.native,
            debugShowCheckedModeBanner: false,
            initialRoute: AppPages.INITIAL,
            getPages: AppPages.routes,
            title: 'CCS',
            theme: theme,
            darkTheme: darkTheme,
            themeMode: ThemeMode.light,
          );
        },
      ),
    ),
  );
}
