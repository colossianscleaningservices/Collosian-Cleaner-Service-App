import 'package:ccs_app/export.dart';

import '../../../network/request/schedule_job_request.dart';
import '../../../network/response/get_client_job_details_response.dart';
import '../job/client_job_detail_controller.dart';

/// Frequency labels shown in the schedule job form.
const List<String> frequencyOptions = [
  'Custom (one-time)',
  'Daily',
  'Weekly',
  'Fortnightly',
  'Monthly',
];

/// API values for [repeat_on_day].
const List<String> repeatOnDayValues = [
  'monday',
  'tuesday',
  'wednesday',
  'thursday',
  'friday',
  'saturday',
  'sunday',
];

const List<String> repeatOnDayLabels = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

class ScheduleJobController extends GetxController {
  final job = Rx<ClientJobDetails?>(null);

  final startDate = Rx<DateTime>(DateTime.now());
  final startDateDisplayController = TextEditingController();
  final jobTimeDisplayController = TextEditingController();

  final frequency = 'Weekly'.obs;
  final repeatOnDay = 'monday'.obs;
  final copyCleanersFromParent = false.obs;

  DateTime get minStartDate {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
  }

  bool get hasRequiredJobTimes {
    final start = job.value?.startTime;
    final end = job.value?.endTime;
    return start != null && start.trim().isNotEmpty && end != null && end.trim().isNotEmpty;
  }

  String? get jobTimeDisplay {
    if (!hasRequiredJobTimes) return null;
    return '${CcsDateTimeX.convertTime(job.value!.startTime!)} – ${CcsDateTimeX.convertTime(job.value!.endTime!)}';
  }

  bool get needsRepeatOnDay => frequency.value == 'Weekly' || frequency.value == 'Fortnightly';

  String get apiFrequency {
    switch (frequency.value) {
      case 'Custom (one-time)':
        return 'custom';
      case 'Daily':
        return 'daily';
      case 'Weekly':
        return 'weekly';
      case 'Fortnightly':
        return 'fortnightly';
      case 'Monthly':
        return 'monthly';
      default:
        return frequency.value.toLowerCase();
    }
  }

  List<num>? parentCleanerIds() {
    final jobDetails = job.value;
    if (jobDetails == null) return null;

    final fromCleaners = jobDetails.cleaners?.map((c) => c.id).whereType<num>().toList();
    if (fromCleaners != null && fromCleaners.isNotEmpty) return fromCleaners;

    final fromJobCleaners = jobDetails.jobCleaners?.map((jc) => jc.userId).whereType<num>().toList();
    if (fromJobCleaners != null && fromJobCleaners.isNotEmpty) return fromJobCleaners;

    return null;
  }

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is ClientJobDetails) {
      job.value = arg;
    }

    var initialStart = minStartDate;
    final jobDateRaw = job.value?.date;
    if (jobDateRaw != null && jobDateRaw.trim().isNotEmpty) {
      try {
        final jobDate = DateTime.parse(jobDateRaw);
        final jobDateOnly = DateTime(jobDate.year, jobDate.month, jobDate.day);
        if (!jobDateOnly.isBefore(minStartDate)) {
          initialStart = jobDateOnly;
        }
      } catch (_) {}
    }
    startDate.value = initialStart;
    jobTimeDisplayController.text = jobTimeDisplay ?? '';
    _syncDisplayControllers();
  }

  @override
  void onClose() {
    startDateDisplayController.dispose();
    jobTimeDisplayController.dispose();
    super.onClose();
  }

  void _syncDisplayControllers() {
    startDateDisplayController.text = CcsDateUtils.forInput(startDate.value);
  }

  Future<void> pickStartDate(BuildContext context) async {
    final minDate = minStartDate;
    final initial = startDate.value.isBefore(minDate) ? minDate : startDate.value;
    final d = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: minDate,
      lastDate: DateTime(2030, 12, 31),
    );
    if (d != null && context.mounted) {
      startDate.value = DateTime(d.year, d.month, d.day);
      _syncDisplayControllers();
    }
  }

  Future<void> submit() async {
    if (!hasRequiredJobTimes) {
      Notifier.error('This job must have start and end times before scheduling.');
      return;
    }
    if (startDate.value.isBefore(minStartDate)) {
      Notifier.error('Start date must be tomorrow or a future date.');
      return;
    }
    if (needsRepeatOnDay && repeatOnDay.value.trim().isEmpty) {
      Notifier.error('Please select a repeat day.');
      return;
    }

    try {
      final detailCtrl = Get.find<ClientJobDetailController>();
      final startStr =
          '${startDate.value.year}-${startDate.value.month.toString().padLeft(2, '0')}-${startDate.value.day.toString().padLeft(2, '0')}';
      final copyCleaners = copyCleanersFromParent.value;
      final request = ScheduleJobRequest(
        frequency: apiFrequency,
        startDate: startStr,
        startTime: job.value?.startTime,
        endTime: job.value?.endTime,
        repeatOnDay: needsRepeatOnDay ? repeatOnDay.value : null,
        copyCleaners: copyCleaners,
        cleanerIds: copyCleaners ? parentCleanerIds() : null,
      );
      log(runtimeType.toString(), 'REQUEST ${request.toJson()}');
      await detailCtrl.scheduleJob(request);
      Get.back();
    } catch (_) {
      // Error already shown by detail controller
    }
  }
}
