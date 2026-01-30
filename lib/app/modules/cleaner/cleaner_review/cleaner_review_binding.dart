import 'package:get/get.dart';

import 'cleaner_review_controller.dart';

class CleanerReviewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CleanerReviewController>(
      () => CleanerReviewController(),
    );
  }
}
