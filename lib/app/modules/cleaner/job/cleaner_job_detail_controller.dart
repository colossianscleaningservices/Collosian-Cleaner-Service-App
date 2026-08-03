import 'package:ccs_app/app/modules/cleaner/dashboard/cleaner_dashboard_controller.dart';
import 'package:ccs_app/app/network/repository/cleaner_repository.dart';
import 'package:ccs_app/export.dart';

import '../../../model/chat_message.dart';
import '../../../network/response/get_staff_job_details_response.dart';
import '../../../network/response/jobs.dart';
import '../../../services/pref.dart';
import 'job_check_photo_controller.dart';

/// Controller for cleaner job detail. Same full job data as client; actions are cleaner-oriented (directions, contact, accept/decline, start/stop with photos).
class CleanerJobDetailController extends GetxController {
  final CleanerRepository _cleanerRepository = CleanerRepository();

  final job = Rx<StaffJobDetails?>(null);
  final isFetching = false.obs;
  final fetchError = RxnString();

  /// True when cleaner can tap "Start job" (e.g. Scheduled, Accepted).
  /// //Approved
  bool get canStartJob {
    final s = job.value?.status?.toLowerCase();
    var cleanerJobStatus = job.value?.cleanerJobStatus;
    return s == 'scheduled' ||
        s == 'accepted' ||
        s == 'approved' && cleanerJobStatus?.toLowerCase() != 'in process' && cleanerJobStatus?.toLowerCase() != 'completed';
  }

  /// True when cleaner can tap "Stop job" (job in progress).
  bool get canStopJob {
    /*final s = job.value?.status?.toLowerCase();*/
    /*return s == 'in progress' || s == 'in_progress';*/
    var s = job.value?.cleanerJobStatus?.toLowerCase();
    return s == 'in process' || s == 'in_process';
  }

  /// True when job is completed and cleaner can tap "Review".
  bool get canShowReview {
    /*final s = job.value?.status?.toLowerCase();*/
    var s = ((job.value?.jobCleaners?.firstWhereOrNull((item) => item.userId.toString() == Prefs().userId)?.status))?.toLowerCase();
    return s == 'completed';
  }

  /// Bottom bar state: 1 = Start, 2 = Stop, 3 = Review. 0 = hide bar (e.g. Pending).
  int get bottomBarState {
    if (canStartJob) return 1;
    if (canStopJob) return 2;
    /*if (canShowReview) return 3;*/
    return 0;
  }

  String get bottomBarLabel {
    switch (bottomBarState) {
      case 1:
        return 'Start';
      case 2:
        return 'Stop';
      case 3:
        return 'Review';
      default:
        return '';
    }
  }

  VoidCallback? get bottomBarOnPressed {
    switch (bottomBarState) {
      case 1:
        return onStartJob;
      case 2:
        return onStopJob;
      default:
        return null;
    }
  }

  ButtonType get bottomBarButtonType {
    switch (bottomBarState) {
      case 1:
        return ButtonType.primary;
      case 2:
        return ButtonType.tonal;
      case 3:
        return ButtonType.primary;
      default:
        return ButtonType.primary;
    }
  }

  num? jobId;
  var from = '';

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Jobs) {
      jobId = args.id;
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

  /// Navigate to check-in photo screen; on success update job status to in progress.
  void onStartJob() {
    Get.toNamed(Routes.CLEANER_JOB_CHECKIN, arguments: {'job': job.value, 'mode': JobCheckPhotoMode.checkIn})?.then((result) {
      if (result == true) {
        /*job.value?.status = 'In progress';*/
        fetchJobDetails();
        updateHomeJob();
      }
    });
  }

  /// Navigate to check-out photo screen; on success update job status to completed.
  void onStopJob() {
    Get.toNamed(Routes.CLEANER_JOB_CHECKOUT, arguments: {'job': job.value, 'mode': JobCheckPhotoMode.checkOut})?.then((result) {
      if (result == true) {
        /*job.value?.status = 'Completed';*/
        fetchJobDetails();
        updateHomeJob();
      }
    });
  }

  void onDirections() {
    Notifier.info('Open in maps (coming soon)');
  }

  void onContactClient() {
    final currentJob = job.value;

    final chatJob = ChatJob(
      id: currentJob?.id.toString() ?? "",
      jobType: currentJob?.jobType,
      propertyOneLine: currentJob?.property?.propertyName,
      date: DateTime.parse(currentJob?.date ?? "").toIso8601String(),
      clientName: currentJob?.user?.name ?? "",
    );
    final participants = <String, ChatParticipant>{};
    // Client
    if (currentJob?.user?.id != null) {
      participants[currentJob?.user?.id.toString() ?? ""] = ChatParticipant(
        id: currentJob?.user?.id.toString() ?? "",
        name: currentJob?.user?.name ?? "",
        role: RoleConstants.roleKeyClient,
      );
    }
    /*// Current user (cleaner)
    final userId = Prefs().userId;
    final userName = Prefs().userFullName;
    participants[userId] = ChatParticipant(id: userId, name: userName, role: RoleConstants.roleKeyCleaner);*/
    // Other cleaners on the same job

    for (final cleaner in currentJob?.cleaners ?? []) {
      participants[cleaner.id.toString()] = ChatParticipant(
        id: cleaner.id.toString(),
        name: cleaner.name,
        role: RoleConstants.roleKeyCleaner,
      );
    }
    Get.toNamed(Routes.JOB_CHAT, arguments: {
      'type': ChatConstants.typeJob,
      'jobId': job.value?.id.toString(),
      'job': chatJob,
      'participants': participants,
    });
  }

  void onAccept() {
    final jobId = job.value?.id;
    if (jobId == null) {
      Notifier.info('Invalid job');
      return;
    }
    Notifier.openSheet(
      Get.context!,
      title: 'Accept job?',
      message: 'Are you sure want to accept this job?',
      showPrimaryButton: true,
      showSecondaryButton: true,
      primaryButtonLabel: 'Accept',
      secondaryButtonLabel: 'Cancel',
      onPrimaryPressed: () => _acceptJob(jobId.toInt()),
    );
  }

  void onDecline() {
    final jobId = job.value?.id;
    if (jobId == null) {
      Notifier.info('Invalid job');
      return;
    }
    final scheme = (Get.context as BuildContext).colorScheme;
    final messageController = TextEditingController();
    Notifier.openSheet(
      Get.context!,
      title: 'Decline job?',
      message: 'You can add a reason.',
      showPrimaryButton: true,
      body: Column(
        spacing: 8,
        children: [
          CommonText.bold('Decline job?', size: 24, color: scheme.primary, fontWeight: FontWeight.w900),
          CommonTextField(
            hint: 'You can add a reason.',
            controller: messageController,
            maxLines: 4,
            minLines: 2,
            action: TextInputAction.done,
          ),
        ],
      ).marginSymmetric(vertical: 8),
      type: SheetType.error,
      showSecondaryButton: true,
      primaryButtonLabel: 'Decline',
      secondaryButtonLabel: 'Keep',
      onPrimaryPressed: () => _declineJob(jobId.toInt(), messageController.text),
    );
  }

  Future<void> _declineJob(int jobId, String msg) async {
    Loader.show();
    try {
      final result = await _cleanerRepository.acceptOrDeclineJob(jobId: jobId, status: 'Rejected', reason: msg);
      result.handle(
        success: (value) {
          Loader.hide();
          Notifier.success(value.message ?? 'Job declined');

          WidgetsBinding.instance.addPostFrameCallback((_) {
            updateHomeJob();
            Get.back();
          });
        },
        contextTag: 'decline_job',
      );
    } finally {
      Loader.hide();
    }
  }

  Future<void> _acceptJob(int jobId) async {
    Loader.show();
    try {
      final result = await _cleanerRepository.acceptOrDeclineJob(jobId: jobId, status: 'Accepted');
      result.handle(
        success: (value) {
          Loader.hide();
          Notifier.success(value.message ?? 'Job Accepted');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            fetchJobDetails();
            updateHomeJob();
          });
        },
        contextTag: 'accept_job',
      );
    } finally {
      Loader.hide();
    }
  }

  Future<void> fetchJobDetails({bool isLoaderShown = false}) async {
    if (jobId == null) return;
    isFetching.value = true;
    fetchError.value = null;
    if (isLoaderShown) Loader.show();
    try {
      final result = await _cleanerRepository.getCleanerJobDetails(jobId!.toInt());
      result.handle(
        showAlert: false,
        success: (response) {
          final raw = response.data;
          job.value = raw;
          fetchError.value = null;
          if (raw == null) {
            fetchError.value = 'Job not found';
          }
        },
        onError: (e) {
          fetchError.value = e.message;
        },
      );
    } finally {
      isFetching.value = false;
      if (isLoaderShown) Loader.hide();
    }
  }

  void updateHomeJob() {
    bool isControllerRegistered = Get.isRegistered<CleanerDashboardController>();
    if (isControllerRegistered) {
      CleanerDashboardController ctrl = Get.find();
      ctrl.jobCurrentPage = 1;
      ctrl.fetchJobs(isLoaderShown: false);
    }
  }
}
