import 'package:ccs_app/app/network/repository/client_repository.dart';
import 'package:ccs_app/app/network/request/schedule_job_request.dart';
import 'package:ccs_app/export.dart';

import '../../../model/client_job.dart';
import '../../../network/response/get_client_job_details_response.dart';
import '../dashboard/client_dashboard_controller.dart';

enum Options { yes, no }

class ClientJobDetailController extends GetxController {
  final ClientRepository _clientRepository = ClientRepository();

  final job = Rx<ClientJobDetails?>(null);

  num? jobId;
  var from = '';

  Rx<Options?> arrive = Rx<Options?>(null);
  Rx<Options?> uniform = Rx<Options?>(null);
  Rx<Options?> completedJob = Rx<Options?>(null);
  Rx<Options?> requestAgain = Rx<Options?>(null);
  Rx<double> rating = 0.0.obs;
  final messageController = TextEditingController();
  final jobCleaner = Rx<ClientJobCleaner?>(null);

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is num) {
      jobId = args;
    }
    if (args is Map<String, dynamic>) {
      if (args['from'] != null) {
        from = args['from'];
      }

      if (args['jobId'] != null) {
        jobId = args['jobId'];
      }
    }
  }

  @override
  void onReady() {
    fetchJobDetails();
    super.onReady();
  }

  Future<void> fetchJobDetails({bool isLoaderShown = true}) async {
    if (jobId == null) return;
    if (isLoaderShown) Loader.show();
    try {
      final result = await _clientRepository.getJobDetails(jobId!);
      result.handle(
        success: (response) {
          final raw = response.data;
          job.value = raw;
        },
      );
    } finally {
      if (isLoaderShown) Loader.hide();
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
    final scheme = (Get.context as BuildContext).colorScheme;
    final msgCtrl = TextEditingController();

    Notifier.openSheet(
      Get.context!,
      title: 'Cancel job?',
      type: SheetType.error,
      message: 'This will cancel this job. You can add a reason below.',
      body: Column(
        spacing: 8,
        children: [
          CommonText.bold('Cancel job?', size: 24, color: scheme.primary, fontWeight: FontWeight.w900).marginOnly(bottom: 8),
          CommonText.regular('This will cancel this job. You can add a reason below.',
              textAlign: TextAlign.center, size: 18, color: scheme.onSurface.withValues(alpha: 0.7)),
          CommonTextField(
            hint: 'Type your reason here...',
            controller: msgCtrl,
            maxLines: 4,
            minLines: 2,
            action: TextInputAction.done,
          ),
        ],
      ).marginSymmetric(vertical: 8),
      showPrimaryButton: true,
      showSecondaryButton: true,
      primaryButtonLabel: 'Cancel job',
      secondaryButtonLabel: 'Keep',
      onPrimaryPressed: () => _cancelJob(jobId, msgCtrl.text),
    );
  }

  Future<void> _cancelJob(num jobId, String msg) async {
    Loader.show();
    try {
      final result = await _clientRepository.cancelJob(jobId: jobId.toInt(), reason: msg);
      result.handle(
        success: (_) {
          Loader.hide();
          Notifier.success('Job cancelled');
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            Get.back();
            bool isControllerRegistered = Get.isRegistered<ClientDashboardController>();
            if (isControllerRegistered) {
              ClientDashboardController ctrl = Get.find();
              ctrl.jobCurrentPage = 1;
              ctrl.fetchJobs();
            }
          });
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

  Future<void> scheduleJob(ScheduleJobRequest request) async {
    final jobId = job.value?.id?.toInt();
    if (jobId == null) {
      Notifier.info('Invalid job');
      return;
    }
    Loader.show();
    try {
      final result = await _clientRepository.scheduleJob(jobId: jobId, request: request);
      result.handle(
        success: (_) {
          Loader.hide();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (Get.context == null) return;
            fetchJobDetails(isLoaderShown: false);
            Notifier.openSheet(Get.context as BuildContext,
                title: "Success",
                type: SheetType.success,
                message: "Job scheduled for ${CcsDateUtils.fullDate(DateTime.parse(request.startDate ?? ""))}.",
                isDismissable: false,
                isShowCloseIcon: false,
                showSecondaryButton: false, onPrimaryPressed: () {
              Get.back();
            });
          });
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
    jobCleaner.value = c;
    jobCleaner.refresh();
    Get.toNamed(Routes.ADD_REVIEW, arguments: job.value);
  }

  Future<void> submitReview() async {
    final jobId = job.value?.id?.toInt();
    if (jobId == null) {
      Notifier.info('Invalid job');
      return;
    }

    if (jobCleaner.value == null) {
      Notifier.info('Cleaner information is missing');
      return;
    }

    if (arrive.value == null) {
      Notifier.info('Please confirm if the cleaner arrived on time');
      return;
    }

    if (uniform.value == null) {
      Notifier.info('Please confirm if the cleaner wore a uniform');
      return;
    }

    if (completedJob.value == null) {
      Notifier.info('Please confirm if the job was completed on time');
      return;
    }

    if (requestAgain.value == null) {
      Notifier.info('Please confirm if you would hire the cleaner again');
      return;
    }

    if (rating.value <= 0) {
      Notifier.info('Please provide a rating');
      return;
    }

    Loader.show();
    try {
      final result = await _clientRepository.submitJobReview(
        jobId: jobId,
        cleanerId: jobCleaner.value?.id.toInt() ?? 0,
        arrivedOnTime: arrive.value == Options.yes,
        woreUniform: uniform.value == Options.yes,
        completedOnTime: completedJob.value == Options.yes,
        wouldRehire: requestAgain.value == Options.yes,
        satisfactionRating: rating.value.toInt(),
        message: messageController.text.trim().isNotEmpty ? messageController.text.trim() : null,
      );
      result.handle(
        success: (value) {
          Loader.hide();
          // Defer sheet to next frame so Loader.hide() from finally can close the loader first
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (Get.context == null) return;
            Notifier.openSheet(Get.context as BuildContext,
                title: "Success",type: SheetType.success, message: "${value.message}", isDismissable: false, isShowCloseIcon: false, showSecondaryButton: false, onPrimaryPressed: () {
              Get.back();
              fetchJobDetails();
            });
          });
        },
        contextTag: 'submit_review',
      );
    } finally {
      Loader.hide();
    }
  }
}
