import 'package:ccs_app/app/network/repository/auth_repository.dart';
import 'package:ccs_app/app/services/pref.dart';

import '../../export.dart';
import 'onesignal_service.dart';

/// Session: source of truth for auth; logout clears prefs and calls API.
/// Use for dashboard auth checks and displaying current user/role.
class SessionService extends GetxService {
  final Prefs _prefs = Prefs.instance;

  /// In-flight logout so concurrent 401s only navigate to login once.
  bool _isLoggingOut = false;
  Future<void>? _logoutFuture;

  /// Stays true after a 401 logout until the user logs in again,
  /// so in-flight APIs cannot show extra toasts or navigate again.
  bool _forceLoggedOut = false;

  bool get isLoggedIn => (_prefs.token).isNotEmpty;

  bool get isLoggingOut => _isLoggingOut;

  /// True while a 401 logout is running, or after it until the next login.
  bool get hasHandledUnauthorized {
    if (isLoggedIn && !_isLoggingOut) {
      _forceLoggedOut = false;
      return false;
    }
    return _forceLoggedOut || _isLoggingOut;
  }

  static const _authFormTags = {
    'login',
    'signup',
    'forgot_password',
    'reset_password',
    'send_OTP',
  };

  /// Leftover 401s after session expiry should be ignored.
  /// Auth form errors (wrong password, etc.) must still show a toast.
  bool shouldIgnoreUnauthorized({String? contextTag}) {
    if (contextTag != null && _authFormTags.contains(contextTag)) return false;
    return hasHandledUnauthorized;
  }

  /// Claims the logout slot. Returns false if another caller already started it.
  bool beginLogout() {
    if (hasHandledUnauthorized) return false;
    _isLoggingOut = true;
    _forceLoggedOut = true;
    return true;
  }

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

  /// Clears the session and navigates to login.
  /// Concurrent callers share the same in-flight future so navigation happens once.
  /// [notifyServer] is false for 401 handling (token is already invalid).
  Future<void> logout({bool notifyServer = true}) {
    _isLoggingOut = true;
    _forceLoggedOut = true;
    return _logoutFuture ??= _performLogout(notifyServer: notifyServer);
  }

  Future<void> _performLogout({required bool notifyServer}) async {
    try {
      if (notifyServer) {
        Loader.show();
        try {
          await AuthRepository().logout();
        } catch (_) {
          // Best-effort: still clear local session and go to login
        }
        Loader.hide();
      }
      OneSignalService.logout();
      await _prefs.clearAll();
      if (Get.currentRoute != Routes.LOGIN) {
        Get.offAllNamed(Routes.LOGIN);
      }
    } finally {
      _logoutFuture = null;
      _isLoggingOut = false;
    }
  }
}
