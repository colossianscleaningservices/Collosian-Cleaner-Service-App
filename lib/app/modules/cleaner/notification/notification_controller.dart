import 'package:ccs_app/app/network/repository/common_repository.dart';

import '../../../../export.dart';
import '../../../network/response/notification_response.dart';

class NotificationController extends GetxController {
  final CommonRepository _commonRepository = CommonRepository();

  // RxList<NotificationData> notifications = <NotificationData>[].obs;
  RxList<Notifications> notifications = <Notifications>[].obs;
  ScrollController scrollController = ScrollController();
  var totalPage = 1;
  var currentPage = 1;
  bool _isLoading = false;

  @override
  void onInit() {
    scrollController.addListener(() {
      if (_isScrollBottom) {
        if (currentPage <= totalPage && !_isLoading) {
          getNotifications();
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

  @override
  void onClose() {
    super.onClose();
  }

  bool get _isScrollBottom {
    if (!scrollController.hasClients) return false;
    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  Future<void> getNotifications() async {
    if (_isLoading) return;
    _isLoading = true;
    Loader.show();
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
      Loader.hide();
      _isLoading = false;
    }
  }

  Future<void> markAsRead(int notificationId, int index) async {
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
