import 'package:ccs_app/app/network/repository/auth_repository.dart';
import 'package:ccs_app/app/services/pref.dart';

import '../../export.dart';
import 'onesignal_service.dart';

/// Session: source of truth for auth; logout clears prefs and calls API.
/// Use for dashboard auth checks and displaying current user/role.
class SessionService extends GetxService {
  final Prefs _prefs = Prefs.instance;

  bool get isLoggedIn => (_prefs.token).isNotEmpty;

  /// Current user id (from login/register response). Empty if not logged in.
  String get userId => _prefs.getData(Prefs.id);

  /// Current role id (1 = client, 2 = cleaner). Empty if not logged in.
  String get roleId => _prefs.getData(Prefs.roleId);

  /// Display name for profile/header: "First Last" or email if name empty.
  String get userDisplayName {
    final first = _prefs.getData(Prefs.firstName);
    final last = _prefs.getData(Prefs.lastName);
    final name = '$first $last'.trim();
    if (name.isNotEmpty) return name;
    final email = _prefs.getData(Prefs.email);
    return email.isNotEmpty ? email : 'User';
  }

  String get userDisplayImage {
    final image = _prefs.getData(Prefs.image);
    return image.isNotEmpty ? image : '';
  }

  Future<void> logout() async {
    Loader.show();
    try {
      await AuthRepository().logout();
    } catch (_) {
      // Best-effort: still clear local session and go to login
    }
    OneSignalService.logout();
    await _prefs.clearAll();
    Loader.hide();
    Get.offAllNamed(Routes.LOGIN);
  }
}
