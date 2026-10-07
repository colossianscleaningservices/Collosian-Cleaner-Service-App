import 'package:ccs_app/app/network/response/profile_response.dart';
import 'package:ccs_app/export.dart';
import '../dashboard/cleaner_dashboard_controller.dart';

class CleanerIssuedItemsController extends GetxController {
  CleanerDashboardController get _dashboardController => Get.find<CleanerDashboardController>();

  RxList<IssuedItem> get issuedItems => _dashboardController.issuedItems;
  RxInt get issuedItemsOutstandingCount => _dashboardController.issuedItemsOutstandingCount;

  Future<void> refreshIssuedItems() async {
    await _dashboardController.getProfile();
  }
}
