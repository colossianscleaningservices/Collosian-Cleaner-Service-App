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
  static _PendingNotification? _pendingNav;
  static bool _flushScheduled = false;
  static int _flushAttempt = 0;

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

      final pending = _pendingFromClick(event);
      if (!_canNavigateNow()) {
        log(_tag, 'App still starting, holding notification until splash finishes');
        _pendingNav = pending;
        _flushAttempt = 0;
        _scheduleFlush();
        return;
      }

      _debounceNavigation(() => _applyPending(pending));
    } catch (e) {
      log(_tag, 'Error handling notification click: $e');
      final fallback = const _PendingNotification(openList: true);
      if (!_canNavigateNow()) {
        _pendingNav = fallback;
        _flushAttempt = 0;
        _scheduleFlush();
        return;
      }
      _debounceNavigation(() => _applyPending(fallback));
    }
  }

  static _PendingNotification _pendingFromClick(OSNotificationClickEvent event) {
    if (!_isUserLoggedIn()) {
      log(_tag, 'User not logged in, redirecting to auth');
      return const _PendingNotification(authRedirect: true);
    }

    final additionalData = event.notification.additionalData;
    if (additionalData == null || additionalData.isEmpty) {
      log(_tag, 'No additional data, navigating to notifications');
      return const _PendingNotification(openList: true);
    }

    final data = Map<String, dynamic>.from(additionalData);
    final type = data['flag'] as String?;
    log(_tag, 'Notification type: $type');
    return _PendingNotification(type: type, data: data);
  }

  /// Splash calls this after it replaces itself with home or login.
  /// A cold-start notification tap is applied on top of that route.
  static void onNavigationReady() {
    _flushAttempt = 0;
    _scheduleFlush();
  }

  static bool _canNavigateNow() {
    try {
      if (Get.key.currentState == null) return false;
      final route = Get.currentRoute;
      return route.isNotEmpty && route != Routes.SPLASH;
    } catch (_) {
      return false;
    }
  }

  static void _scheduleFlush() {
    if (_pendingNav == null || _flushScheduled) return;
    _flushScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _flushScheduled = false;
      _tryFlush();
    });
  }

  static void _tryFlush() {
    final pending = _pendingNav;
    if (pending == null) return;
    if (!_canNavigateNow()) {
      _flushAttempt++;
      if (_flushAttempt > 120) {
        log(_tag, 'Still waiting for splash to finish before opening notification');
        return;
      }
      Future<void>.delayed(const Duration(milliseconds: 100), _scheduleFlush);
      return;
    }

    _flushAttempt = 0;
    _pendingNav = null;
    _debounceNavigation(() => _applyPending(pending));
  }

  static void _applyPending(_PendingNotification pending) {
    if (pending.authRedirect) {
      final route = Get.currentRoute;
      if (route != Routes.AUTH && route != Routes.LOGIN) {
        Get.offAllNamed(Routes.AUTH);
      }
      return;
    }
    if (pending.openList) {
      Get.toNamed(Routes.NOTIFICATION);
      return;
    }
    _routeBasedOnNotificationType(type: pending.type, data: pending.data);
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

class _PendingNotification {
  const _PendingNotification({
    this.type,
    this.data,
    this.authRedirect = false,
    this.openList = false,
  });

  final String? type;
  final Map<String, dynamic>? data;
  final bool authRedirect;
  final bool openList;
}
