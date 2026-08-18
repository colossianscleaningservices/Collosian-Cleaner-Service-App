import 'package:ccs_app/export.dart';

import '../../../network/request/update_schedule_job_request.dart';
import '../../../network/request/schedule_job_request.dart';
import '../../../network/response/get_client_job_details_response.dart';
import '../../../network/response/jobs.dart';
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
  final isEditMode = false.obs;
  num? scheduleId;

  final startDate = Rx<DateTime>(DateTime.now());
  final startTime = Rx<TimeOfDay>(const TimeOfDay(hour: 9, minute: 0));
  final endTime = Rx<TimeOfDay>(const TimeOfDay(hour: 12, minute: 0));

  final startDateDisplayController = TextEditingController();
  final startTimeDisplayController = TextEditingController();
  final endTimeDisplayController = TextEditingController();

  final frequency = 'Weekly'.obs;
  final repeatOnDay = 'monday'.obs;
  final copyCleanersFromParent = false.obs;

  String get pageTitle => isEditMode.value ? 'Edit schedule' : 'Schedule job';

  String get submitLabel => isEditMode.value ? 'Save changes' : 'Schedule job';

  DateTime get today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  DateTime get minStartDate => isEditMode.value ? today : today.add(const Duration(days: 1));

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
    } else if (arg is Map<String, dynamic>) {
      final j = arg['job'];
      if (j is ClientJobDetails) job.value = j;
      isEditMode.value = arg['isEdit'] == true;
    }

    final details = job.value;
    final scheduler = details?.scheduler;
    scheduleId = scheduler?.id ?? details?.scheduleId;

    log(runtimeType.toString(), 'scheduler ${scheduler?.toJson()} \n scheduleId $scheduleId');

    if (isEditMode.value) {
      _prefillFromExistingSchedule(details, scheduler);
    } else {
      _prefillForNewSchedule(details);
    }

    _syncDisplayControllers();
  }

  void _prefillForNewSchedule(ClientJobDetails? details) {
    var initialStart = minStartDate;
    final jobDateRaw = details?.jobStartDate ?? details?.date;
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
    startTime.value = CcsDateTimeX.parseToTimeOfDay(details?.startTime) ?? const TimeOfDay(hour: 9, minute: 0);
    endTime.value = CcsDateTimeX.parseToTimeOfDay(details?.endTime) ?? const TimeOfDay(hour: 12, minute: 0);
  }

  void _prefillFromExistingSchedule(ClientJobDetails? details, Scheduler? scheduler) {
    final dateRaw = scheduler?.startDate ?? details?.jobStartDate ?? scheduler?.nextJobDate ?? details?.date;
    if (dateRaw != null && dateRaw.trim().isNotEmpty) {
      try {
        final parsed = DateTime.parse(dateRaw);
        startDate.value = DateTime(parsed.year, parsed.month, parsed.day);
      } catch (_) {
        startDate.value = minStartDate;
      }
    } else {
      startDate.value = minStartDate;
    }

    frequency.value = _frequencyLabelFromApi(scheduler?.frequency);
    repeatOnDay.value = _repeatOnDayFromScheduler(scheduler) ?? 'monday';

    startTime.value = CcsDateTimeX.parseToTimeOfDay(scheduler?.startTime ?? details?.startTime) ?? const TimeOfDay(hour: 9, minute: 0);
    endTime.value = CcsDateTimeX.parseToTimeOfDay(scheduler?.endTime ?? details?.endTime) ?? const TimeOfDay(hour: 12, minute: 0);

    copyCleanersFromParent.value = scheduler?.copyCleaners ?? false;
  }

  @override
  void onClose() {
    startDateDisplayController.dispose();
    startTimeDisplayController.dispose();
    endTimeDisplayController.dispose();
    super.onClose();
  }

  void _syncDisplayControllers() {
    startDateDisplayController.text = CcsDateUtils.forInput(startDate.value);
    startTimeDisplayController.text = _formatTimeWithAmPm(startTime.value);
    endTimeDisplayController.text = _formatTimeWithAmPm(endTime.value);
  }

  void setStartTime(TimeOfDay time) {
    startTime.value = time;
    startTimeDisplayController.text = _formatTimeWithAmPm(time);
  }

  void setEndTime(TimeOfDay time) {
    endTime.value = time;
    endTimeDisplayController.text = _formatTimeWithAmPm(time);
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

  bool _isEndAfterStart() {
    final startMinutes = startTime.value.hour * 60 + startTime.value.minute;
    final endMinutes = endTime.value.hour * 60 + endTime.value.minute;
    return endMinutes > startMinutes;
  }

  Future<void> submit() async {
    if (!_isEndAfterStart()) {
      Notifier.error('End time must be after start time.');
      return;
    }
    if (startDate.value.isBefore(minStartDate)) {
      Notifier.error(isEditMode.value ? 'Start date cannot be in the past.' : 'Start date must be tomorrow or a future date.');
      return;
    }
    if (needsRepeatOnDay && repeatOnDay.value.trim().isEmpty) {
      Notifier.error('Please select a repeat day.');
      return;
    }

    try {
      final detailCtrl = Get.find<ClientJobDetailController>();
      final startStr = _formatApiDate(startDate.value);
      final startTimeStr = CcsDateTimeX.formatTimeOfDay(startTime.value);
      final endTimeStr = CcsDateTimeX.formatTimeOfDay(endTime.value);
      final copyCleaners = copyCleanersFromParent.value;

      if (isEditMode.value) {
        if (scheduleId == null) {
          Notifier.error('Schedule not found');
          return;
        }
        final request = UpdateScheduleJobRequest(
          frequency: apiFrequency,
          startDate: startStr,
          startTime: startTimeStr,
          endTime: endTimeStr,
          repeatOnDay: needsRepeatOnDay ? repeatOnDay.value : null,
          copyCleaners: copyCleaners,
          isActive: job.value?.scheduler?.active ?? true,
        );
        log(runtimeType.toString(), 'UPDATE SCHEDULE REQUEST ${request.toJson()}');
        await detailCtrl.updateScheduleJob(scheduleId!, request);
      } else {
        final request = ScheduleJobRequest(
          frequency: apiFrequency,
          startDate: startStr,
          startTime: startTimeStr,
          endTime: endTimeStr,
          repeatOnDay: needsRepeatOnDay ? repeatOnDay.value : null,
          copyCleaners: copyCleaners,
          cleanerIds: copyCleaners ? parentCleanerIds() : null,
        );
        log(runtimeType.toString(), 'CREATE SCHEDULE REQUEST ${request.toJson()}');
        await detailCtrl.scheduleJob(request);
      }
      Get.back();
    } catch (_) {
      // Error already shown by detail controller
    }
  }

  static String _formatApiDate(DateTime date) => '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  static String _formatTimeWithAmPm(TimeOfDay time) {
    final period = time.hour >= 12 ? 'PM' : 'AM';
    final hour12 = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour12:$minute $period';
  }

  static String _frequencyLabelFromApi(String? apiValue) {
    switch (apiValue?.toLowerCase()) {
      case 'custom':
        return 'Custom (one-time)';
      case 'daily':
        return 'Daily';
      case 'weekly':
        return 'Weekly';
      case 'fortnightly':
        return 'Fortnightly';
      case 'monthly':
        return 'Monthly';
      default:
        return 'Weekly';
    }
  }

  static String? _repeatOnDayFromScheduler(Scheduler? scheduler) {
    final repeatOn = scheduler?.repeatOn;
    if (repeatOn == null) return null;
    final flags = <String?, bool?>{
      'monday': repeatOn.monday,
      'tuesday': repeatOn.tuesday,
      'wednesday': repeatOn.wednesday,
      'thursday': repeatOn.thursday,
      'friday': repeatOn.friday,
      'saturday': repeatOn.saturday,
      'sunday': repeatOn.sunday,
    };
    for (final entry in flags.entries) {
      if (entry.value == true && entry.key != null) return entry.key;
    }
    return null;
  }
}
