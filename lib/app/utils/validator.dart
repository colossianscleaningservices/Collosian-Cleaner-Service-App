class Validator {
  Validator._();

  static String? requiredField(String? value, {String fieldName = 'This field'}) {
    if ((value ?? '').trim().isEmpty) return '$fieldName is required';
    return null;
  }

  static String? email(String? value, {String fieldName = 'Email'}) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return '$fieldName is required';
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(v)) return 'Enter a valid email';
    return null;
  }

  static String? minLength(String? value, int min, {String fieldName = 'This field'}) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return '$fieldName is required';
    if (v.length < min) return '$fieldName must be at least $min characters';
    return null;
  }

  /// UK NI number (example: AB123456C). SRS: required for cleaner.
  static String? nin(String? value, {String fieldName = 'National Insurance Number'}) {
    final v = (value ?? '').trim().toUpperCase();
    if (v.isEmpty) return '$fieldName is required';
    final ninRegex = RegExp(r'^[A-Z]{2}\d{6}[A-Z]{1}$');
    if (!ninRegex.hasMatch(v)) return 'Enter a valid NI number (e.g., AB123456C)';
    return null;
  }
}

