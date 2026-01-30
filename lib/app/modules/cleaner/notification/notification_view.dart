import 'package:ccs_app/app/widget/layout/app_scaffold.dart';
import 'package:ccs_app/export.dart';

import 'notification_controller.dart';

class NotificationView extends GetView<NotificationController> {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;

    // Dummy notification data (replace with controller.notifications when API is ready)
    final notifications = _getDummyNotifications();

    return AppScaffold(
      appBar: Header(title: 'Notifications'),
      body: SafeArea(
        child: notifications.isEmpty
            ? _EmptyNotifications(scheme: scheme)
            : ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                itemCount: notifications.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return _NotificationCard(
                    notification: notification,
                    scheme: scheme,
                    onTap: () {
                      // TODO: Mark as read and navigate to detail
                      Notifier.info('Notification tapped');
                    },
                  );
                },
              ),
      ),
    );
  }

  List<_NotificationData> _getDummyNotifications() {
    return [
      _NotificationData(
        type: _NotificationType.jobAssigned,
        title: 'New job assigned',
        message: 'You have been assigned a cleaning job at 123 Oak Street for Feb 2, 2026.',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        isRead: false,
      ),
      _NotificationData(
        type: _NotificationType.jobUpdate,
        title: 'Job rescheduled',
        message: 'Your cleaning job at 456 Maple Ave has been moved to Feb 5, 2026.',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        isRead: false,
      ),
      _NotificationData(
        type: _NotificationType.payment,
        title: 'Payment received',
        message: 'You received £85.00 for job #1234. Check your earnings.',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
      ),
      _NotificationData(
        type: _NotificationType.reminder,
        title: 'Upcoming job reminder',
        message: 'You have a job tomorrow at 789 Pine Road at 10:00 AM.',
        timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
        isRead: true,
      ),
      _NotificationData(
        type: _NotificationType.message,
        title: 'New message from client',
        message: 'Sarah Johnson sent you a message about the cleaning supplies.',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        isRead: true,
      ),
      _NotificationData(
        type: _NotificationType.jobUpdate,
        title: 'Job completed',
        message: 'Great work! The client marked job #1230 as completed.',
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
        isRead: true,
      ),
    ];
  }
}

enum _NotificationType { jobAssigned, jobUpdate, payment, message, reminder }

class _NotificationData {
  final _NotificationType type;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;

  _NotificationData({
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.isRead,
  });
}

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications({required this.scheme});

  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              shape: BoxShape.circle,
              border: Border.all(
                color: scheme.outline.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
            child: Icon(
              IconsaxPlusLinear.notification,
              size: 48,
              color: scheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 20),
          CommonText.semiBold('No notifications', size: 18, color: scheme.onSurface),
          const SizedBox(height: 8),
          CommonText.regular(
            'You\'re all caught up! We\'ll notify you\nwhen there\'s something new.',
            size: 14,
            color: scheme.onSurfaceVariant,
            textAlign: TextAlign.center,
          ),
        ],
      ).paddingSymmetric(horizontal: 32),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    required this.scheme,
    required this.onTap,
  });

  final _NotificationData notification;
  final ColorScheme scheme;
  final VoidCallback onTap;

  IconData _getIcon() {
    switch (notification.type) {
      case _NotificationType.jobAssigned:
        return IconsaxPlusLinear.task_square;
      case _NotificationType.jobUpdate:
        return IconsaxPlusLinear.refresh;
      case _NotificationType.payment:
        return IconsaxPlusLinear.wallet_money;
      case _NotificationType.message:
        return IconsaxPlusLinear.message_text;
      case _NotificationType.reminder:
        return IconsaxPlusLinear.clock;
    }
  }

  Color _getIconBgColor() {
    switch (notification.type) {
      case _NotificationType.jobAssigned:
        return scheme.primary.withValues(alpha: 0.15);
      case _NotificationType.jobUpdate:
        return scheme.secondary.withValues(alpha: 0.15);
      case _NotificationType.payment:
        return scheme.tertiary.withValues(alpha: 0.15);
      case _NotificationType.message:
        return scheme.primaryContainer.withValues(alpha: 0.6);
      case _NotificationType.reminder:
        return scheme.secondaryContainer.withValues(alpha: 0.6);
    }
  }

  Color _getIconColor() {
    switch (notification.type) {
      case _NotificationType.jobAssigned:
        return scheme.primary;
      case _NotificationType.jobUpdate:
        return scheme.secondary;
      case _NotificationType.payment:
        return scheme.tertiary;
      case _NotificationType.message:
        return scheme.primary;
      case _NotificationType.reminder:
        return scheme.secondary;
    }
  }

  String _getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(notification.timestamp);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return '${(difference.inDays / 7).floor()}w ago';
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(16),
      borderWidth: 1,
      borderColor: notification.isRead ? scheme.outline.withValues(alpha: 0.08) : scheme.error,
      enableShadows: true,
      color: scheme.onPrimary,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon badge

          AppCard(
            enableShadows: false,
            radius: UiConstants.radiusDefault,
            color: _getIconBgColor(),
            child: Icon(
              _getIcon(),
              size: 22,
              color: _getIconColor(),
            ).paddingAll(12),
          ).marginOnly(right: 14),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (!notification.isRead) ...[
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: scheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: CommonText.semiBold(
                        notification.title,
                        size: 16,
                        color: scheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                CommonText.regular(
                  notification.message,
                  size: 14,
                  color: scheme.onSurface.withValues(alpha: 0.85),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(IconsaxPlusLinear.clock, size: 14, color: scheme.onSurfaceVariant),
                        const SizedBox(width: 6),
                        CommonText.regular(
                          _getTimeAgo(),
                          size: 12,
                          color: scheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                    notification.isRead
                        ? SizedBox.shrink()
                        : AppCard(
                            radius: 8,
                            color: context.colorScheme.error,
                            child: CommonText.regular(
                              'UNREAD',
                              color: context.colorScheme.onPrimary,
                            ).paddingAll(8),
                          )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
