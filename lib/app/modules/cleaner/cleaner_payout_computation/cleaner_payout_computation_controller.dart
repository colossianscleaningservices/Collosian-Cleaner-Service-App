import 'package:get/get.dart';

class CleanerPayoutComputationController extends GetxController {
  //TODO: Implement CleanerPayoutComputationController

  final count = 0.obs;

  /// Schedule validity: from / to (date-only) for this weekly pattern.
  final scheduleValidFrom = Rx<DateTime?>(null);
  void setStartDate(DateTime? d) => scheduleValidFrom.value = d;
  void setEndDate(DateTime? d) => scheduleValidTo.value = d;
  final scheduleValidTo = Rx<DateTime?>(null);

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void increment() => count.value++;

  void setScheduleValidFrom(DateTime d) {
    scheduleValidFrom.value = DateTime(d.year, d.month, d.day);
  }

  void setScheduleValidTo(DateTime d) {
    scheduleValidTo.value = DateTime(d.year, d.month, d.day);
  }
}
