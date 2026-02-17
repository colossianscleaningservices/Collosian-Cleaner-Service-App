import 'package:ccs_app/app/model/notification_data.dart';
import 'package:ccs_app/app/network/repository/common_repository.dart';

import '../../../../export.dart';

class NotificationController extends GetxController {
  final CommonRepository _commonRepository = CommonRepository();
  RxList<NotificationData> notifications = <NotificationData>[].obs;
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


  /// Called by pull-to-refresh. Disposes existing video controllers and reloads the list.
  Future<void> refreshNotification() async {
    currentPage = 1;
    getNotifications();
  }

}
