import 'package:get/get.dart';

import 'cleaner_references_controller.dart';

class CleanerRefrencesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CleanerReferencesController>(
      () => CleanerReferencesController(),
    );
  }
}
