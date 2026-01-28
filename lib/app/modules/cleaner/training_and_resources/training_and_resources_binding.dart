import 'package:get/get.dart';

import 'training_and_resources_controller.dart';

class TrainingAndResourcesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TrainingAndResourcesController>(
      () => TrainingAndResourcesController(),
    );
  }
}
