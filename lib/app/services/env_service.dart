import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/alerts.dart';

class EnvService {

  EnvService._internal();
  static EnvService? _instance;

  static EnvService get instance => _instance ??= EnvService._internal();

  static String get apiBaseUrl => getString('API_BASE_URL');

  static String get onesignalAppId => getString('ONESIGNAL_APP_ID');

  static Future<void> init() async {
    await dotenv.load();

    validateRequired();
    printAll();
  }

  static String getString(String key, {String defaultValue = ''}) => dotenv.env[key] ?? defaultValue;

  static bool hasKey(String key) => dotenv.env.containsKey(key);

  static Map<String, String> getAll() => dotenv.env;

  static void validateRequired() {
    final requiredKeys = ['API_BASE_URL', 'ONESIGNAL_APP_ID',];

    final missingKeys = <String>[];
    for (final key in requiredKeys) {
      if (!hasKey(key) || getString(key).isEmpty) {
        missingKeys.add(key);
      }
    }

    if (missingKeys.isNotEmpty) {
      throw Exception('Missing required environment variables: ${missingKeys.join(', ')}');
    }
  }

  static void printAll() {
    log('ENV_SERVICE', '=== Environment Variables ===');
    final allVars = getAll();
    allVars.forEach((key, value) {
      // Mask sensitive values
      if (key.toLowerCase().contains('password') || key.toLowerCase().contains('secret') || key.toLowerCase().contains('key')) {
        log('ENV_SERVICE', '$key: ${value.isNotEmpty ? '***MASKED***' : 'NOT_SET'}');
      } else {
        log('ENV_SERVICE', '$key: $value');
      }
    });
    log('ENV_SERVICE', '============================');
  }
}
