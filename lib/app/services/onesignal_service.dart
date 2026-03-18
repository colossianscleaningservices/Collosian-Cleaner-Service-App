import 'dart:async';

import 'package:ccs_app/app/services/pref.dart';
import 'package:ccs_app/export.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

/// OneSignal push notifications (mirror WAVTech pattern, adapted for CCS routes).
class OneSignalService {
  OneSignalService._internal();

  static const String _tag = 'ONESIGNAL_SERVICE';
  static OneSignalService? _instance;
  static bool _isInitialized = false;
  static Timer? _navigationDebouncer;
  static DateTime? _lastNavigationTime;

  static OneSignalService get instance => _instance ??= OneSignalService._internal();

  static Future<void> initialize(String appId) async {
    if (_isInitialized) return;
    if (appId.isEmpty) {
      log(_tag, 'OneSignal app ID empty, skipping initialization');
      return;
    }

    try {
      OneSignal.initialize(appId);
      OneSignal.Notifications.addClickListener(_handleNotificationClick);
      OneSignal.Notifications.addForegroundWillDisplayListener((event) {
        log(
            _tag,
            'Notification displayed: ${event.notification.title}\n${event.notification.notificationId}\n${event.notification.body}\n${event.notification.additionalData}'
            '\n${event.notification.rawPayload}');
        event.notification.display();
      });
      await OneSignal.Notifications.requestPermission(true);
      _isInitialized = true;
      log(_tag, 'OneSignal initialized successfully');
    } catch (e) {
      log(_tag, 'Failed to initialize OneSignal: $e');
      rethrow;
    }
  }

  static bool _isUserLoggedIn() {
    final token = Prefs().token;
    return token.isNotEmpty;
  }

  static void _handleNotificationClick(OSNotificationClickEvent event) {
    try {
      log(_tag, 'Notification clicked: ${event.notification.notificationId}');
      log(
          _tag,
          'Notification displayed: ${event.notification.title}\n${event.notification.notificationId}\n${event.notification.body}\n${event.notification.additionalData}'
          '\n${event.notification.rawPayload}');

      if (!_isUserLoggedIn()) {
        log(_tag, 'User not logged in, redirecting to auth');
        _debounceNavigation(() => Get.offAllNamed(Routes.AUTH));
        return;
      }

      final additionalData = event.notification.additionalData;
      if (additionalData == null || additionalData.isEmpty) {
        log(_tag, 'No additional data, navigating to default');
        _navigateToDefaultScreen();
        return;
      }

      final type = additionalData['flag'] as String?;
      log(_tag, 'Notification type: $type');

      _debounceNavigation(() {
        _routeBasedOnNotificationType(type: type, data: additionalData);
      });
    } catch (e) {
      log(_tag, 'Error handling notification click: $e');
      _navigateToDefaultScreen();
    }
  }

  static void _routeBasedOnNotificationType({
    required String? type,
    Map<String, dynamic>? data,
  }) {
    try {
      // CCS-specific: e.g. job updates, general alerts. Extend as backend adds types.
      if ((type == Constants.jobCreated || type == Constants.jobRequestAccepted || type == Constants.cleanerAssigned) && data != null) {
        final jobId = data['related_id'];
        if (jobId != null) {
          final id = jobId is int ? jobId : (jobId is String ? int.tryParse(jobId) : null);
          if (id != null) {
            final roleIdStr = Prefs().getData(Prefs.roleId);
            final roleId = int.tryParse(roleIdStr);
            if (RoleConstants.isCleaner(roleId)) {
              log(_tag, 'Navigating to cleaner job detail: $id');
              Get.toNamed(Routes.CLEANER_JOB_DETAIL, arguments: {'from': 'notification', 'jobId': id});
              return;
            }
          }
        }
      }

      _navigateToDefaultScreen();
    } catch (e) {
      log(_tag, 'Error routing notification: $e');
      _navigateToDefaultScreen();
    }
  }

  static void _navigateToDefaultScreen() {
    _debounceNavigation(() {
      if (_isUserLoggedIn()) {
        Get.offAllNamed(Routes.CLIENT_DASHBOARD);
      } else {
        Get.offAllNamed(Routes.AUTH);
      }
    });
  }

  static void _debounceNavigation(VoidCallback navigationCallback) {
    final now = DateTime.now();
    _navigationDebouncer?.cancel();
    if (_lastNavigationTime != null && now.difference(_lastNavigationTime!).inMilliseconds < 1000) {
      return;
    }
    _navigationDebouncer = Timer(const Duration(milliseconds: 300), () {
      _lastNavigationTime = DateTime.now();
      navigationCallback();
    });
  }

  /// Call after login with backend user id (for targeted push).
  static void login(String externalId) {
    if (!_isInitialized) return;
    try {
      OneSignal.login(externalId);
      log(_tag, 'OneSignal login: $externalId');
    } catch (e) {
      log(_tag, 'OneSignal login failed: $e');
    }
  }

  /// OneSignal push subscription ID (for device registration API). May be null before permission or on web.
  static String? get pushSubscriptionId {
    if (!_isInitialized) return null;
    try {
      return OneSignal.User.pushSubscription.id;
    } catch (e) {
      log(_tag, 'Failed to get push subscription id: $e');
      return null;
    }
  }

  /// Call on logout to clear OneSignal user.
  static void logout() {
    if (!_isInitialized) return;
    try {
      OneSignal.logout();
      log(_tag, 'OneSignal logout');
    } catch (e) {
      log(_tag, 'OneSignal logout failed: $e');
    }
  }
}
