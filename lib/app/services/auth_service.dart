import 'pref.dart';

class AuthService {
  AuthService();

  final Prefs _prefs = Prefs.instance;

  bool get hasToken => (_prefs.token ?? '').isNotEmpty;

  String? get token => _prefs.token;

  Future<void> saveToken(String token) => _prefs.setToken(token);

  Future<void> clearToken() => _prefs.setToken(null);
}
