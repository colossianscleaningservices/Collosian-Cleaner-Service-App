
import 'package:ccs_app/export.dart';

import '../../../model/client_job.dart';
import '../job/client_job_detail_controller.dart';

/// Frequency for recurring schedule.
const List<String> frequencyOptions = ['One-off', 'Daily', 'Weekly', 'Monthly'];

/// Repeat every options when frequency is Weekly.
const List<String> repeatEveryWeekOptions = ['Every week', 'Every 2 weeks', 'Every 3 weeks', 'Every 4 weeks'];

/// Weekday labels for Repeat on (Mon=1 .. Sun=7).
const List<String> weekdayLabels = ['MO', 'TU', 'WE', 'TH', 'FR', 'SA', 'SU'];

class ScheduleJobController extends GetxController {
  ClientJob get job => _job;
  late ClientJob _job;

  final startDate = Rx<DateTime>(DateTime.now());
  final startTime = Rx<TimeOfDay>(const TimeOfDay(hour: 9, minute: 0));
  final endDate = Rx<DateTime?>(null); // optional: null = indefinite
  final endTime = Rx<TimeOfDay>(const TimeOfDay(hour: 12, minute: 0));

  final startDateDisplayController = TextEditingController();
  final startTimeDisplayController = TextEditingController();
  final endDateDisplayController = TextEditingController();
  final endTimeDisplayController = TextEditingController();

  final frequency = 'Weekly'.obs;
  final repeatEveryWeekIndex = 0.obs; // 0 = Every week, 1 = Every 2 weeks, ...
  final repeatOnWeekdays = <int>[1].obs; // 1=Mon .. 7=Sun; default Monday
  final copyCleanersFromParent = false.obs;

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is ClientJob) {
      _job = arg;
    } else {
      _job = ClientJob(
        id: '',
        clientName: '',
        jobType: '',
        date: DateTime.now(),
        startTime: '09:00',
        endTime: '12:00',
        status: 'Created',
        propertyOneLine: '',
      );
    }
    startDate.value = DateTime(_job.date.year, _job.date.month, _job.date.day);
    startTime.value = _parseTime(_job.startTime);
    endDate.value = null; // optional: leave empty for indefinite
    endTime.value = _parseTime(_job.endTime);
    _syncDisplayControllers();
  }

  @override
  void onClose() {
    startDateDisplayController.dispose();
    startTimeDisplayController.dispose();
    endDateDisplayController.dispose();
    endTimeDisplayController.dispose();
    super.onClose();
  }

  void _syncDisplayControllers() {
    startDateDisplayController.text = CcsDateUtils.forInput(startDate.value);
    startTimeDisplayController.text = _formatTime(startTime.value);
    final end = endDate.value;
    endDateDisplayController.text = end != null ? CcsDateUtils.forInput(end) : '';
    endTimeDisplayController.text = _formatTime(endTime.value);
  }

  void clearEndDate() {
    endDate.value = null;
    endDateDisplayController.text = '';
  }

  void toggleRepeatOnWeekday(int weekday) {
    final list = List<int>.from(repeatOnWeekdays);
    if (list.contains(weekday)) {
      list.remove(weekday);
    } else {
      list.add(weekday);
      list.sort();
    }
    repeatOnWeekdays.assignAll(list);
  }

  static TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    if (parts.length >= 2) {
      final h = int.tryParse(parts[0]) ?? 9;
      final m = int.tryParse(parts[1]) ?? 0;
      return TimeOfDay(hour: h.clamp(0, 23), minute: m.clamp(0, 59));
    }
    return const TimeOfDay(hour: 9, minute: 0);
  }

  static String _formatTime(TimeOfDay t) {
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  Future<void> pickStartDate(BuildContext context) async {
    final d = await showDatePicker(
      context: context,
      initialDate: startDate.value,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030, 12, 31),
    );
    if (d != null && context.mounted) {
      startDate.value = DateTime(d.year, d.month, d.day);
      final end = endDate.value;
      if (end != null && end.isBefore(startDate.value)) endDate.value = startDate.value;
      _syncDisplayControllers();
    }
  }

  Future<void> pickEndDate(BuildContext context) async {
    final end = endDate.value;
    final d = await showDatePicker(
      context: context,
      initialDate: end != null && !end.isBefore(startDate.value) ? end : startDate.value,
      firstDate: startDate.value,
      lastDate: DateTime(2030, 12, 31),
    );
    if (d != null && context.mounted) {
      endDate.value = DateTime(d.year, d.month, d.day);
      _syncDisplayControllers();
    }
  }

  Future<void> pickStartTime(BuildContext context) async {
    final t = await showTimePicker(context: context, initialTime: startTime.value);
    if (t != null && context.mounted) {
      startTime.value = t;
      _syncDisplayControllers();
    }
  }

  Future<void> pickEndTime(BuildContext context) async {
    final t = await showTimePicker(context: context, initialTime: endTime.value);
    if (t != null && context.mounted) {
      endTime.value = t;
      _syncDisplayControllers();
    }
  }

  Future<void> submit() async {
    try {
      final detailCtrl = Get.find<ClientJobDetailController>();
      final end = endDate.value ?? startDate.value;
      await detailCtrl.scheduleJob(
        startDate.value,
        startTime.value,
        end,
        endTime.value,
      );
      Get.back();
    } catch (_) {
      // Error already shown by detail controller
    }
  }
}
