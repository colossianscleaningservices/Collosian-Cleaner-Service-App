import 'package:get/get.dart';

import 'newsletters_controller.dart';

class NewslettersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NewslettersController>(
      () => NewslettersController(),
    );
  }
}
