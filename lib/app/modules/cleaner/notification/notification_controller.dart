import 'package:ccs_app/app/modules/cleaner/dashboard/cleaner_dashboard_controller.dart';
import 'package:ccs_app/app/network/repository/common_repository.dart';

import '../../../../export.dart';
import '../../../network/response/notification_response.dart';
import '../../client/dashboard/client_dashboard_controller.dart';

class NotificationController extends GetxController {
  final CommonRepository _commonRepository = CommonRepository();

  // RxList<NotificationData> notifications = <NotificationData>[].obs;
  RxList<Notifications> notifications = <Notifications>[].obs;
  ScrollController scrollController = ScrollController();
  var totalPage = 1;
  var currentPage = 1;
  RxBool isLoadMore = false.obs;

  @override
  void onInit() {
    scrollController.addListener(() {
      if (_isScrollBottom) {
        if (currentPage <= totalPage && !isLoadMore.value) {
          getNotifications(isLoadMore: true);
        }
      }
    });

    super.onInit();
  }

  @override
  void onReady() {
    getNotifications();
    super.onReady();
  }

  bool get _isScrollBottom {
    if (!scrollController.hasClients) return false;
    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  Future<void> getNotifications({bool isLoadMore = false}) async {
    if (isLoadMore) {
      if (this.isLoadMore.value) return;
      this.isLoadMore.value = true;
    } else {
      Loader.show();
    }

    try {
      final result = await _commonRepository.getNotifications(page: currentPage);
      result.handle(
        success: (value) {
          if (currentPage == 1) notifications.clear();

          notifications.addAll(value.data?.notifications as Iterable<Notifications>);

          totalPage = (value.data?.pagination?.totalPages ?? 1).toInt();

          if (currentPage <= totalPage) {
            currentPage++;
          }
        },
        contextTag: 'get_notifications',
      );
    } catch (e) {
      Notifier.error('Failed to fetch notifications');
    } finally {
      if (isLoadMore) {
        this.isLoadMore.value = false;
      } else {
        Loader.hide();
      }
    }
  }

  Future<void> markAsRead(int notificationId, int index) async {
    //UI update Locally
    notifications[index].isRead = true;
    notifications.refresh();
    try {
      final result = await _commonRepository.readNotifications(notificationId);
      result.handle(
        success: (value) {
          notifications[index].isRead = true;
          notifications.refresh();
        },
        contextTag: 'read_notifications',
      );
    } catch (e) {
      Notifier.error('Failed to mark as read');
    } finally {}
  }

  Future<void> readAllNotifications() async {
    Loader.show();
    try {
      final result = await _commonRepository.readAllNotifications();
      result.handle(
        success: (value) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            for (var item in notifications) {
              item.isRead = true;
            }
            notifications.refresh();

            bool isClientControllerRegistered = Get.isRegistered<ClientDashboardController>();
            if (isClientControllerRegistered) {
              ClientDashboardController ctrl = Get.find();
              ctrl.hasUnreadNotifications.value = false;
            }

            bool isCleanerControllerRegistered = Get.isRegistered<CleanerDashboardController>();
            if (isCleanerControllerRegistered) {
              CleanerDashboardController ctrl = Get.find();
              ctrl.hasUnreadNotifications.value = false;
            }
          });
        },
        contextTag: 'read_notifications',
      );
    } catch (e) {
      Notifier.error('Failed to mark all as read');
    } finally {
      Loader.hide();
    }
  }

  /// Called by pull-to-refresh. Disposes existing video controllers and reloads the list.
  Future<void> refreshNotification() async {
    currentPage = 1;
    getNotifications();
  }

  Future<void> deleteNotifications(int? notificationId, int index) async {
    if (notificationId == null) return;
    Loader.show();
    try {
      final result = await _commonRepository.deleteNotifications(notificationId);
      result.handle(
        success: (value) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            notifications.removeAt(index);
            notifications.refresh();
          });
        },
        contextTag: 'delete_notifications',
      );
    } catch (e) {
      Notifier.error('Failed to delete notification');
    } finally {
      Loader.hide();
    }
  }

  Future<void> deleteAllNotifications() async {
    Loader.show();
    try {
      final result = await _commonRepository.deleteAllNotifications();
      result.handle(
        success: (value) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            notifications.clear();
            notifications.refresh();
          });
        },
        contextTag: 'delete_all_notifications',
      );
    } catch (e) {
      Notifier.error('Failed to delete all notification');
    } finally {
      Loader.hide();
    }
  }
}
