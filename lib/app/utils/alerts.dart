import 'package:flutter/material.dart';

import 'secure_logger.dart';

/// Lightweight logger (avoid print in production code; keep centralized).
void log(String tag, String message) {
  SecureLogger.log(tag, message);
}

/// Lightweight toast/snackbar replacement (no third-party dependency).
void toast(BuildContext context, String message, {bool isError = false}) {
  final scheme = Theme.of(context).colorScheme;
  final bg = isError ? scheme.errorContainer : scheme.primaryContainer;
  final fg = isError ? scheme.onErrorContainer : scheme.onPrimaryContainer;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message, style: TextStyle(color: fg)),
      backgroundColor: bg,
      behavior: SnackBarBehavior.floating,
    ),
  );
}

