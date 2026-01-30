import 'package:get/get.dart';

import 'cleaner_payout_computation_controller.dart';

class CleanerPayoutComputationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CleanerPayoutComputationController>(
      () => CleanerPayoutComputationController(),
    );
  }
}
