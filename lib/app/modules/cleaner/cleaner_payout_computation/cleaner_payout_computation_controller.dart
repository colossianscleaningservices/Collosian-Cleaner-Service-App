import 'package:ccs_app/app/network/response/get_payout_computation_response.dart';
import 'package:ccs_app/app/utils/date_utils.dart';
import 'package:get/get.dart';

import '../../../network/repository/cleaner_repository.dart';
import '../../../network/utils/network_result_extensions.dart';
import '../../../utils/custom_loader.dart';

class CleanerPayoutComputationController extends GetxController {

  final CleanerRepository _cleanerRepository = CleanerRepository();

  /// Schedule validity: from / to (date-only) for this weekly pattern.
  final scheduleValidFrom = Rx<DateTime?>(null);
  void setStartDate(DateTime? d) => scheduleValidFrom.value = d;
  void setEndDate(DateTime? d) => scheduleValidTo.value = d;
  final scheduleValidTo = Rx<DateTime?>(null);
  final totalResidentialEarning = Rx<String?>('0.0');
  final totalCommercialEarning = Rx<String?>('0.0');
  final totalPayout = Rx<String?>('0.0');
  final RxList<WorkEntries> entries = <WorkEntries>[].obs;
  final residentialRate = Rx<num?>(0);
  final commercialRate = Rx<num?>(0);

  @override
  void onReady() {
    getPayoutComputation();
    super.onReady();
  }

  void setScheduleValidFrom(DateTime d) {
    scheduleValidFrom.value = DateTime(d.year, d.month, d.day);
  }

  void setScheduleValidTo(DateTime d) {
    scheduleValidTo.value = DateTime(d.year, d.month, d.day);
  }

  Future<void> getPayoutComputation() async {
    Loader.show();
    try {

      final from = scheduleValidFrom.value;
      final to = scheduleValidTo.value;

      final hasDates = from != null && to != null;

      final result = await _cleanerRepository.getPayoutComputation(
        dateFrom: hasDates ? from.toDisplayDate('yyyy-MM-dd') : null,
        dateTo: hasDates ? to.toDisplayDate('yyyy-MM-dd') : null,
      );
      result.handle(
        success: (response) {
          Loader.hide();
          final data = response.data;

          totalResidentialEarning.value = data?.residentialEarnings?.toString() ??'0.0';
          totalCommercialEarning.value = data?.commercialEarnings?.toString() ??'0.0';
          totalPayout.value = data?.totalPayout?.toString() ??'0.0';
          residentialRate.value = data?.residentialRate;
          commercialRate.value = data?.commercialRate;
          entries.assignAll(data?.workEntries as Iterable<WorkEntries>);
          entries.refresh();
        },
      );
    } finally {
      Loader.hide();
    }
  }


}
