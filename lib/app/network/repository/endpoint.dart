class Endpoint {
  Endpoint._();

  static const String root = '/api/';

  // Auth endpoints (API-based: email + password)
  static const String login = '${root}login';
  static const String userRegister = '${root}register';
  static const String logout = '${root}logout';
  static const String forgotPassword = '${root}forgot-password';
  static const String resetPassword = '${root}reset-password';
}
