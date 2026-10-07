import 'package:get/get.dart';
import 'cleaner_issued_items_controller.dart';

class CleanerIssuedItemsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CleanerIssuedItemsController>(() => CleanerIssuedItemsController());
  }
}
