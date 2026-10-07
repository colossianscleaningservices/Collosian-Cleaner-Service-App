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
        log(_tag, 'No additional data, navigating to notifications');
        _debounceNavigation(() => Get.toNamed(Routes.NOTIFICATION));
        return;
      }

      final type = additionalData['flag'] as String?;
      log(_tag, 'Notification type: $type');

      _debounceNavigation(() {
        _routeBasedOnNotificationType(type: type, data: additionalData);
      });
    } catch (e) {
      log(_tag, 'Error handling notification click: $e');
      _debounceNavigation(() => Get.toNamed(Routes.NOTIFICATION));
    }
  }

  static void _routeBasedOnNotificationType({
    required String? type,
    Map<String, dynamic>? data,
  }) {
    try {
      final rawJobId = data?['related_id'] ?? data?['job_id'] ?? data?['jobId'] ?? data?['relatedId'];
      final jobId = rawJobId is int ? rawJobId : (rawJobId is String ? int.tryParse(rawJobId) : (rawJobId is num ? rawJobId.toInt() : null));

      final roleIdStr = Prefs().getData(Prefs.roleId);
      final roleId = int.tryParse(roleIdStr);

      log(_tag, 'Routing notification type: $type, jobId: $jobId, roleId: $roleId');

      if (type == Constants.jobCreated ||
          type == Constants.jobRequestAccepted ||
          type == Constants.cleanerAssigned ||
          type == Constants.cleanerCheckOut ||
          type == Constants.cleanerCheckIn ||
          type == Constants.invoiceIssue ||
          type == Constants.sharedShiftJob ||
          type == Constants.missedCheckout ||
          type == Constants.extensionRequestApproved) {
        if (jobId != null) {
          if (RoleConstants.isCleaner(roleId)) {
            log(_tag, 'Navigating to cleaner job detail: $jobId');
            Get.toNamed(Routes.CLEANER_JOB_DETAIL, arguments: {'from': 'notification', 'jobId': jobId});
          } else {
            log(_tag, 'Navigating to client job detail: $jobId');
            Get.toNamed(Routes.CLIENT_JOB_DETAIL, arguments: {'from': 'notification', 'jobId': jobId});
          }
        } else {
          Get.toNamed(Routes.NOTIFICATION);
        }
      } else if (type == Constants.jobReview) {
        if (RoleConstants.isCleaner(roleId)) {
          Get.toNamed(Routes.CLEANER_REVIEW);
        } else {
          Get.toNamed(Routes.NOTIFICATION);
        }
      } else if (type == 'chat') {
        Get.toNamed(Routes.JOB_CHAT, arguments: {
          'type': ChatConstants.typeNotification,
          'jobId': jobId,
        });
      } else {
        Get.toNamed(Routes.NOTIFICATION);
      }
    } catch (e) {
      log(_tag, 'Error routing notification: $e');
      Get.toNamed(Routes.NOTIFICATION);
    }
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
