
import 'secure_logger.dart';

/// Lightweight logger (avoid print in production code; keep centralized).
void log(String tag, String message) {
  SecureLogger.log(tag, message);
}