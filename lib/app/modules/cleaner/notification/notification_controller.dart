import 'package:ccs_app/app/network/repository/common_repository.dart';

import '../../../../export.dart';

class NotificationController extends GetxController {
  final CommonRepository _commonRepository = CommonRepository();
  RxList<NotificationData> notifications = <NotificationData>[].obs;
  ScrollController scrollController = ScrollController();
  var totalPage = 1;
  var currentPage = 1;
  var moreLoading = false.obs;

  @override
  void onInit() {
    scrollController.addListener(() {
      if (_isScrollBottom) {
        if (currentPage <= totalPage) {
          if (moreLoading.value) return;
          moreLoading.value = true;
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
    if (moreLoading.value == false) Loader.show();
    try {
      final result = await _commonRepository.getNotifications(page: currentPage);
      result.when(
        success: (value) {
          if (currentPage == 1) notifications.clear();
        },
        error: (e) async {
          await Notifier.apiError(e, contextTag: 'get_notifications');
        },
      );
    } catch (e) {
      Notifier.error('Failed to fetch notifications');
    } finally {
      if (moreLoading.value == false) Loader.hide();
      moreLoading.value = false;
    }
  }
}

enum NotificationType { jobAssigned, jobUpdate, payment, message, reminder }

class NotificationData {
  final NotificationType type;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;

  NotificationData({
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.isRead,
  });
}
