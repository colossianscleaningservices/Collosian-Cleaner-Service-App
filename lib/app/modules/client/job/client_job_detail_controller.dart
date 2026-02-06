import 'package:ccs_app/export.dart';

import '../../../model/client_job.dart';

class ClientJobDetailController extends GetxController {
  final job = Rx<ClientJob>(ClientJob(
    id: '',
    clientName: '',
    jobType: '',
    date: DateTime.now(),
    startTime: '09:00',
    endTime: '12:00',
    status: 'Created',
    propertyOneLine: '',
  ));

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is ClientJob) {
      job.value = arg;
    }
    fetchJobDetails(job.value.id);
  }

  Future<void> fetchJobDetails(String id) async {
    try {
      // TODO: Call the job details API here
    } catch (e) {
      e.printError();
    }
  }

  void onEdit() {
    Notifier.info('Edit job (coming soon)');
  }

  void confirmDeleteJob(BuildContext context) {
    Notifier.openSheet(
      context,
      type: SheetType.info,
      title: 'Delete job?',
      message: 'This will remove this "${job.value.jobType}" job. This action cannot be undone.',
      primaryButtonLabel: 'Delete',
      secondaryButtonLabel: 'Cancel',
      showPrimaryButton: true,
      showSecondaryButton: true,
      onPrimaryPressed: deleteJob,
      onSecondaryPressed: () {},
    );
  }

  void deleteJob() {
    // TODO: call API to delete job
    Notifier.info('Job deleted');
    Get.back();
  }

  void onCancelJob() {
    // TODO: confirm + API
    Notifier.info('Cancel job (coming soon)');
  }

  /// Navigates to the schedule-job page for a normal (one-off) job.
  void onScheduleJob() {
    Get.toNamed(Routes.CLIENT_SCHEDULE_JOB, arguments: job.value);
  }

  static String _formatTime(TimeOfDay t) {
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  Future<void> scheduleJob(
    DateTime startDate,
    TimeOfDay startTime,
    DateTime endDate,
    TimeOfDay endTime,
  ) async {
    try {
      // TODO: call API to schedule job (e.g. PUT /jobs/:id/schedule with start_date, start_time, end_date, end_time)
      await Future.delayed(const Duration(milliseconds: 400));
      final startStr = _formatTime(startTime);
      final endStr = _formatTime(endTime);
      final endDateOnly = DateTime(endDate.year, endDate.month, endDate.day);
      job.value = job.value.copyWith(
        status: 'Scheduled',
        date: startDate,
        startTime: startStr,
        endTime: endStr,
        jobEndDate: endDateOnly,
      );
      Notifier.success('Job scheduled for ${CcsDateUtils.fullDate(startDate)}.');
    } catch (e) {
      Notifier.apiError(e, contextTag: 'schedule_job');
    }
  }

  void onShareCleanerProfile(ClientJobCleaner c) {
    Notifier.info('Share ${c.name} (coming soon)');
  }
}
