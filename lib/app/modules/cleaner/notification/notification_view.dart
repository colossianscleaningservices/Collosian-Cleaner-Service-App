import 'package:ccs_app/app/model/notification_data.dart';
import 'package:ccs_app/app/widget/layout/app_scaffold.dart';
import 'package:ccs_app/export.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../network/response/notification_response.dart';
import '../../../services/pref.dart';
import 'notification_controller.dart';

class NotificationView extends GetView<NotificationController> {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Obx(() {
      var isAllNotificationRead = true;
      if (controller.notifications.firstWhereOrNull((item) => item.isRead == false) != null) {
        isAllNotificationRead = false;
      }

      return AppScaffold(
        appBar: Header(
          title: 'Notifications',
          actions: [
            isAllNotificationRead
                ? SizedBox.shrink()
                : AppButton(
                    label: 'Read All',
                    onPressed: () => controller.readAllNotifications(),
                    btnHorizontalPadding: 4,
                    type: ButtonType.transparent,
                    btnVerticalPadding: 0,
                  ),
            controller.notifications.isEmpty
                ? SizedBox.shrink()
                : AppButton(
                    label: 'Delete All',
                    onPressed: () {
                      Notifier.openSheet(context,
                          primaryButtonLabel: 'Delete',
                          message: 'Are you sure want to delete all notification?',
                          type: SheetType.error,
                          onPrimaryPressed: () => controller.deleteAllNotifications());
                    },
                    txtClr: scheme.error,
                    btnHorizontalPadding: 4,
                    type: ButtonType.transparent,
                    btnVerticalPadding: 0,
                  ),
          ],
        ),
        body: SwipeRefresh(
          onRefresh: () => controller.refreshNotification(),
          child: SafeArea(
            child: controller.notifications.isEmpty
                ? NoDataView(
                    title: 'No notifications',
                    subtitle: "You're all caught up! We'll notify you when there's something new.",
                    icon: IconsaxPlusLinear.notification,
                  )
                : Column(
                    children: [
                      Expanded(
                        child: SlidableAutoCloseBehavior(
                          child: ListView.separated(
                            controller: controller.scrollController,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                            itemCount: controller.notifications.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final notification = controller.notifications[index];
                              return _NotificationCard(
                                notification: notification,
                                index: index,
                                scheme: scheme,
                                ctrl: controller,
                                onTap: () {
                                  if (notification.isRead == false && notification.id != null) {
                                    controller.markAsRead(notification.id!.toInt(), index);
                                  }
                                  if (notification.flag == Constants.jobCreated) {
                                    final roleIdStr = Prefs().getData(Prefs.roleId);
                                    log(runtimeType.toString(), "ROLE ID => $roleIdStr");
                                    final roleId = int.tryParse(roleIdStr);
                                    if (RoleConstants.isCleaner(roleId)) {
                                      Get.toNamed(Routes.CLEANER_JOB_DETAIL, arguments: {'from': 'notification', 'jobId': notification.relatedId});
                                    }
                                  }
                                },
                              );
                            },
                          ),
                        ),
                      ),
                      SizedBox.shrink()
                    ],
                  ),
          ),
        ),
      );
    });
  }

  List<NotificationData> _getDummyNotifications() {
    return [
      NotificationData(
        type: NotificationType.jobAssigned,
        title: 'New job assigned',
        message: 'You have been assigned a cleaning job at 123 Oak Street for Feb 2, 2026.',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        isRead: false,
      ),
      NotificationData(
        type: NotificationType.jobUpdate,
        title: 'Job rescheduled',
        message: 'Your cleaning job at 456 Maple Ave has been moved to Feb 5, 2026.',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        isRead: false,
      ),
      NotificationData(
        type: NotificationType.payment,
        title: 'Payment received',
        message: 'You received £85.00 for job #1234. Check your earnings.',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
      ),
      NotificationData(
        type: NotificationType.reminder,
        title: 'Upcoming job reminder',
        message: 'You have a job tomorrow at 789 Pine Road at 10:00 AM.',
        timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
        isRead: true,
      ),
      NotificationData(
        type: NotificationType.message,
        title: 'New message from client',
        message: 'Sarah Johnson sent you a message about the cleaning supplies.',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        isRead: true,
      ),
      NotificationData(
        type: NotificationType.jobUpdate,
        title: 'Job completed',
        message: 'Great work! The client marked job #1230 as completed.',
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
        isRead: true,
      ),
    ];
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    required this.index,
    required this.scheme,
    required this.onTap,
    required this.ctrl,
  });

  // final NotificationData notification;
  final Notifications notification;
  final int index;
  final ColorScheme scheme;
  final VoidCallback onTap;
  final NotificationController ctrl;

  IconData _getIcon() {
    switch (/*notification.type*/ NotificationType.message) {
      case NotificationType.jobAssigned:
        return IconsaxPlusLinear.task_square;
      case NotificationType.jobUpdate:
        return IconsaxPlusLinear.refresh;
      case NotificationType.payment:
        return IconsaxPlusLinear.wallet_money;
      case NotificationType.message:
        return IconsaxPlusLinear.message_text;
      case NotificationType.reminder:
        return IconsaxPlusLinear.clock;
    }
  }

  Color _getIconBgColor() {
    switch (/*notification.type*/ NotificationType.message) {
      case NotificationType.jobAssigned:
        return scheme.primary.withValues(alpha: 0.15);
      case NotificationType.jobUpdate:
        return scheme.secondary.withValues(alpha: 0.15);
      case NotificationType.payment:
        return scheme.tertiary.withValues(alpha: 0.15);
      case NotificationType.message:
        return scheme.primaryContainer.withValues(alpha: 0.6);
      case NotificationType.reminder:
        return scheme.secondaryContainer.withValues(alpha: 0.6);
    }
  }

  Color _getIconColor() {
    switch (/*notification.type*/ NotificationType.message) {
      case NotificationType.jobAssigned:
        return scheme.primary;
      case NotificationType.jobUpdate:
        return scheme.secondary;
      case NotificationType.payment:
        return scheme.tertiary;
      case NotificationType.message:
        return scheme.primary;
      case NotificationType.reminder:
        return scheme.secondary;
    }
  }

  String _getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(DateTime.parse(notification.createdAt ?? ""));

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return '${(difference.inDays / 7).floor()}w ago';
  }

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(notification.id ?? index),
      groupTag: 'notifications',
      endActionPane: ActionPane(
        motion: ScrollMotion(),
        children: [
          SlidableAction(
            borderRadius: BorderRadius.circular(8),
            onPressed: (_) => {ctrl.deleteNotifications(notification.id?.toInt(), index)},
            backgroundColor: context.colorScheme.errorContainer.withValues(alpha: 0.7),
            foregroundColor: context.colorScheme.error,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: AppCard(
        onTap: onTap,
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.all(16),
        borderWidth: 1,
        borderColor: notification.isRead == true ? scheme.outline.withValues(alpha: 0.08) : scheme.error,
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
                      if (!(notification.isRead ?? false)) ...[
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
                          notification.title ?? "N/A",
                          size: 16,
                          color: scheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  CommonText.regular(
                    notification.message ?? "",
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
                      notification.isRead == true
                          ? SizedBox.shrink()
                          : AppCard(
                              radius: 8,
                              color: context.colorScheme.error,
                              child: CommonText.regular(
                                'UNREAD',
                                size: 12,
                                color: context.colorScheme.onPrimary,
                              ).paddingSymmetric(horizontal: 8, vertical: 6),
                            )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
