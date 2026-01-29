import '../../export.dart';
import 'onesignal_service.dart';
import 'pref.dart';

/// Simple session holder (junior-friendly).
/// - Source of truth for auth token presence
/// - Clears all prefs on logout
class SessionService extends GetxService {
  final Prefs _prefs = Prefs.instance;

  bool get isLoggedIn => (_prefs.token ?? '').isNotEmpty;

  Future<void> logout() async {
    OneSignalService.logout();
    await _prefs.clearAll();
    Get.offAllNamed(Routes.LOGIN);
  }
}
