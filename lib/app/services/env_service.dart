import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvService {
  EnvService._();

  static Future<void> init() async {
    // Optional: user may not have .env yet.
    await dotenv.load(fileName: '.env', isOptional: true);
  }

  static String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? '';
}

