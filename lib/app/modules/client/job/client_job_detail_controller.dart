import 'package:ccs_app/app/network/repository/client_repository.dart';
import 'package:ccs_app/export.dart';

import '../../../model/client_job.dart';
import '../../../network/response/get_job_details_response.dart';
import '../dashboard/client_dashboard_controller.dart';
import 'add_review.dart';

class ClientJobDetailController extends GetxController {
  final ClientRepository _clientRepository = ClientRepository();

  final job = Rx<JobDetails?>(null);

  num? jobId;

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
    if (arg is num) {
      jobId = arg;
    }
  }

  @override
  void onReady() {
    fetchJobDetails();
    super.onReady();
  }

  Future<void> fetchJobDetails() async {
    if (jobId == null) return;
    Loader.show();
    try {
      final result = await _clientRepository.getJobDetails(jobId!);
      result.handle(
        success: (response) {
          final raw = response.data;
          job.value = raw;
        },
      );
    } finally {
      Loader.hide();
    }
  }

  void onEdit() {
    Get.toNamed(Routes.CLIENT_CREATE_JOB, arguments: job.value)?.then((value) {
      if (value != null) {
        fetchJobDetails();
        bool isControllerRegistered = Get.isRegistered<ClientDashboardController>();
        if (isControllerRegistered) {
          ClientDashboardController ctrl = Get.find();
          ctrl.jobCurrentPage = 1;
          ctrl.fetchJobs(isLoaderShown: false);
        }
      }
    });
  }

  void confirmDeleteJob(BuildContext context) {
    Notifier.openSheet(
      context,
      type: SheetType.error,
      title: 'Delete job?',
      message: 'This will remove this "${job.value?.jobType?.capitalizeFirst ?? "N/A"}" job. This action cannot be undone.',
      primaryButtonLabel: 'Delete',
      secondaryButtonLabel: 'Cancel',
      showPrimaryButton: true,
      showSecondaryButton: true,
      onPrimaryPressed: deleteJob,
      onSecondaryPressed: () {},
    );
  }

  Future<void> deleteJob() async {
    if (jobId == null) return;
    Loader.show();
    try {
      final result = await _clientRepository.deleteJob(jobId!);
      result.handle(
        success: (value) async {
          Loader.hide();
          // Defer sheet to next frame so Loader.hide() from finally can close the loader first
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (Get.context == null) return;
            Notifier.success(value.message ?? "Job deleted Successfully!");
            Get.back(result: {'job_id': jobId, 'action': 'delete'});
          });
        },
        contextTag: 'delete_job',
      );
    } finally {
      Loader.hide();
    }
  }

  void onCancelJob() {
    final jobId = job.value?.id;
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

  Future<void> _cancelJob(num jobId) async {
    Loader.show();
    try {
      final result = await _clientRepository.cancelJob(jobId: jobId.toInt());
      result.handle(
        success: (_) {
          Notifier.success('Job cancelled');
          Get.back();
        },
        contextTag: 'cancel_job',
      );
    } finally {
      Loader.hide();
    }
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
    final jobId = job.value?.id?.toInt();
    if (jobId == null) {
      Notifier.info('Invalid job');
      return;
    }
    Loader.show();
    try {
      final startStr = '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
      final endStr = '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';
      final result = await _clientRepository.scheduleJob(
        jobId: jobId,
        frequency: 'weekly',
        startDate: startStr,
        endDate: endStr,
        copyCleaners: false,
      );
      result.handle(
        success: (_) {
          final startTimeStr = _formatTime(startTime);
          final endTimeStr = _formatTime(endTime);

          /*job.value = job.value?.copyWith(
            status: 'Scheduled',
            date: startDate,
            startTime: startTimeStr,
            endTime: endTimeStr,
            jobEndDate: endDate,
          );*/

          job.value?.status = 'Scheduled';
          job.value?.startTime = startTimeStr;
          job.value?.endTime = endTimeStr;

          Notifier.success('Job scheduled for ${CcsDateUtils.fullDate(startDate)}.');
        },
        contextTag: 'schedule_job',
      );
    } finally {
      Loader.hide();
    }
  }

  void onShareCleanerProfile(ClientJobCleaner c) {
    Notifier.info('Share ${c.name} (coming soon)');
  }

  void onReviewCleanerProfile(ClientJobCleaner c) {
    Get.toNamed(Routes.ADD_REVIEW, arguments: job.value);
  }

  Future<void> submitReview() async {
    final jobId = job.value?.id?.toInt();
    if (jobId == null) {
      Notifier.info('Invalid job');
      return;
    }
    Loader.show();
    try {
      final r = rating.value.round().clamp(1, 5);
      final result = await _clientRepository.submitJobReview(
        jobId: jobId,
        rating: r,
        feedback: messageController.text.trim().isNotEmpty ? messageController.text.trim() : null,
        message: messageController.text.trim().isNotEmpty ? messageController.text.trim() : null,
      );
      result.handle(
        success: (_) {
          Notifier.success('Thank you for your feedback');
          Get.back();
        },
        contextTag: 'submit_review',
      );
    } finally {
      Loader.hide();
    }
  }
}
