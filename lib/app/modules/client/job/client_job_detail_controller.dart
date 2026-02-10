import 'package:ccs_app/app/network/repository/client_repository.dart';
import 'package:ccs_app/export.dart';

import '../../../model/client_job.dart';
import 'add_review.dart';

class ClientJobDetailController extends GetxController {
  final ClientRepository _clientRepository = ClientRepository();

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

  Rx<Options?> arrive = Rx<Options?>(null);
  Rx<Options?> uniform = Rx<Options?>(null);
  Rx<Options?> completedJob = Rx<Options?>(null);
  Rx<Options?> requestAgain = Rx<Options?>(null);
  Rx<double> rating = 0.0.obs;
  final messageController = TextEditingController();

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
    final jobId = int.tryParse(job.value.id);
    if (jobId == null) {
      Notifier.info('Invalid job');
      return;
    }
    Notifier.openSheet(
      Get.context!,
      title: 'Cancel job?',
      message: 'This will cancel this job. You can add a reason below.',
      showPrimaryButton: true,
      showSecondaryButton: true,
      primaryButtonLabel: 'Cancel job',
      secondaryButtonLabel: 'Keep',
      onPrimaryPressed: () => _cancelJob(jobId),
    );
  }

  Future<void> _cancelJob(int jobId) async {
    final result = await _clientRepository.cancelJob(jobId: jobId);
    result.when(
      success: (_) {
        Notifier.success('Job cancelled');
        Get.back();
      },
      error: (e) async => await Notifier.apiError(e, contextTag: 'cancel_job'),
    );
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
    final jobId = int.tryParse(job.value.id);
    if (jobId == null) {
      Notifier.info('Invalid job');
      return;
    }
    final startStr = '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
    final endStr = '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';
    final result = await _clientRepository.scheduleJob(
      jobId: jobId,
      frequency: 'weekly',
      startDate: startStr,
      endDate: endStr,
      copyCleaners: false,
    );
    result.when(
      success: (_) {
        final startTimeStr = _formatTime(startTime);
        final endTimeStr = _formatTime(endTime);
        job.value = job.value.copyWith(
          status: 'Scheduled',
          date: startDate,
          startTime: startTimeStr,
          endTime: endTimeStr,
          jobEndDate: endDate,
        );
        Notifier.success('Job scheduled for ${CcsDateUtils.fullDate(startDate)}.');
      },
      error: (e) async => await Notifier.apiError(e, contextTag: 'schedule_job'),
    );
  }

  void onShareCleanerProfile(ClientJobCleaner c) {
    Notifier.info('Share ${c.name} (coming soon)');
  }
  void onReviewCleanerProfile(ClientJobCleaner c) {
    Get.toNamed(Routes.ADD_REVIEW, arguments: job.value);
  }

  Future<void> submitReview() async {
    final jobId = int.tryParse(job.value.id);
    if (jobId == null) {
      Notifier.info('Invalid job');
      return;
    }
    final r = rating.value.round().clamp(1, 5);
    final result = await _clientRepository.submitJobReview(
      jobId: jobId,
      rating: r,
      feedback: messageController.text.trim().isNotEmpty ? messageController.text.trim() : null,
      message: messageController.text.trim().isNotEmpty ? messageController.text.trim() : null,
    );
    result.when(
      success: (_) {
        Notifier.success('Thank you for your feedback');
        Get.back();
      },
      error: (e) async => await Notifier.apiError(e, contextTag: 'submit_review'),
    );
  }
}
