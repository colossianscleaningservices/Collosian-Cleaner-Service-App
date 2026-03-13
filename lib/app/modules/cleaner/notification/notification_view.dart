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
          actions: [],
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

                                  if (notification.flag == Constants.jobCreated ||
                                      notification.flag == Constants.jobRequestAccepted ||
                                      notification.flag == Constants.cleanerAssigned ||
                                      notification.flag == Constants.cleanerCheckOut ||
                                      notification.flag == Constants.cleanerCheckIn) {
                                    if (notification.relatedId == null) {
                                      Notifier.error('Invalid job');
                                      return;
                                    }

                                    final roleIdStr = Prefs().getData(Prefs.roleId);
                                    final roleId = int.tryParse(roleIdStr);
                                    if (RoleConstants.isCleaner(roleId)) {
                                      Get.toNamed(Routes.CLEANER_JOB_DETAIL, arguments: {'from': 'notification', 'jobId': notification.relatedId});
                                    } else {
                                      Get.toNamed(Routes.CLIENT_JOB_DETAIL, arguments: {'from': 'notification', 'jobId': notification.relatedId});
                                    }
                                  }
                                },
                              );
                            },
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          if (!isAllNotificationRead)
                            Expanded(
                              child: AppButton(
                                label: 'Read All',
                                onPressed: () => controller.readAllNotifications(),
                                type: ButtonType.tonal,
                                icon: IconsaxPlusLinear.tick_circle,
                                btnVerticalPadding: 10,
                                btnHorizontalPadding: 12,
                                textSize: 14,
                              ),
                            ),
                          if (!isAllNotificationRead && controller.notifications.isNotEmpty) const SizedBox(width: 12),
                          if (controller.notifications.isNotEmpty)
                            Expanded(
                              child: AppButton(
                                label: 'Delete All',
                                onPressed: () {
                                  Notifier.openSheet(context,
                                      primaryButtonLabel: 'Delete',
                                      message: 'Are you sure want to delete all notification?',
                                      type: SheetType.error,
                                      onPrimaryPressed: () => controller.deleteAllNotifications());
                                },
                                type: ButtonType.outline,
                                icon: IconsaxPlusLinear.trash,
                                txtClr: scheme.error,
                                borderClr: scheme.error,
                                btnVerticalPadding: 10,
                                btnHorizontalPadding: 12,
                                textSize: 14,
                              ),
                            ),
                        ],
                      ).marginSymmetric(horizontal: 16).marginOnly(top: 8),
                    ],
                  ),
          ),
        ),
      );
    });
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
    switch (notification.flag) {
      case Constants.cleanerAssigned:
        return IconsaxPlusLinear.task_square;
      case Constants.cleanerCheckIn || Constants.cleanerCheckOut:
        return IconsaxPlusLinear.refresh;

      default:
        return IconsaxPlusLinear.message_text;

      /* case NotificationType.payment:
        return IconsaxPlusLinear.wallet_money;
      case NotificationType.message:
        return IconsaxPlusLinear.message_text;
      case NotificationType.reminder:
        return IconsaxPlusLinear.clock;*/
    }
  }

  Color _getIconBgColor() {
    switch (notification.flag) {
      case Constants.cleanerAssigned:
        return scheme.primary.withValues(alpha: 0.15);
      case Constants.cleanerCheckIn || Constants.cleanerCheckOut:
        return scheme.secondary.withValues(alpha: 0.15);

      default:
        return scheme.primaryContainer.withValues(alpha: 0.6);

      /*case NotificationType.payment:
        return scheme.tertiary.withValues(alpha: 0.15);
      case NotificationType.message:
        return scheme.primaryContainer.withValues(alpha: 0.6);
      case NotificationType.reminder:
        return scheme.secondaryContainer.withValues(alpha: 0.6);*/
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
    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.errorContainer.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Slidable(
        key: ValueKey(notification.id ?? index),
        groupTag: 'notifications',
        endActionPane: ActionPane(
          motion: ScrollMotion(),
          children: [
            SlidableAction(
              borderRadius: BorderRadius.only(bottomRight: Radius.circular(8), topRight: Radius.circular(8)),
              onPressed: (_) => {ctrl.deleteNotifications(notification.id?.toInt(), index)},
              backgroundColor: Colors.transparent,
              foregroundColor: context.colorScheme.error,
              icon: Icons.delete,
              label: 'Delete',
            ),
          ],
        ),
        child: AppCard(
          onTap: onTap,
          enableScale: false,
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
      ),
    );
  }
}
