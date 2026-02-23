import 'package:ccs_app/app/network/repository/cleaner_repository.dart';
import 'package:ccs_app/app/network/response/cleaner_job_response.dart';
import 'package:ccs_app/export.dart';

import '../../../model/chat_message.dart';
import '../../../model/client_job.dart';
import '../../../network/response/get_staff_job_details_response.dart';
import '../../../services/pref.dart';
import 'job_check_photo_controller.dart';

/// Controller for cleaner job detail. Same full job data as client; actions are cleaner-oriented (directions, contact, accept/decline, start/stop with photos).
class CleanerJobDetailController extends GetxController {
  final CleanerRepository _cleanerRepository = CleanerRepository();

  final job = Rx<JobDetails?>(null);

  /// True when cleaner can tap "Start job" (e.g. Scheduled, Accepted).
  bool get canStartJob {
    final s = job.value?.status?.toLowerCase();
    return s == 'scheduled' || s == 'accepted';
  }

  /// True when cleaner can tap "Stop job" (job in progress).
  bool get canStopJob {
    final s = job.value?.status?.toLowerCase();
    return s == 'in progress' || s == 'in_progress';
  }

  /// True when job is completed and cleaner can tap "Review".
  bool get canShowReview {
    final s = job.value?.status?.toLowerCase();
    return s == 'completed';
  }

  /// Bottom bar state: 1 = Start, 2 = Stop, 3 = Review. 0 = hide bar (e.g. Pending).
  int get bottomBarState {
    if (canStartJob) return 1;
    if (canStopJob) return 2;
    if (canShowReview) return 3;
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
      case 3:
        return onReview;
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

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Jobs) {
      jobId = args.id;
    }
  }

  @override
  void onReady() {
    fetchJobDetails();
    super.onReady();
  }

  /// Navigate to check-in photo screen; on success update job status to in progress.
  void onStartJob() {
    Get.toNamed(Routes.CLEANER_JOB_CHECKIN, arguments: {'job': job, 'mode': JobCheckPhotoMode.checkIn})?.then((result) {
      if (result == true) job.value?.status = 'In progress';
    });
  }

  /// Navigate to check-out photo screen; on success update job status to completed.
  void onStopJob() {
    Get.toNamed(Routes.CLEANER_JOB_CHECKOUT, arguments: {'job': job, 'mode': JobCheckPhotoMode.checkOut})?.then((result) {
      if (result == true) job.value?.status = 'Completed';
    });
  }

  void onDirections() {
    Notifier.info('Open in maps (coming soon)');
  }

  void onContactClient() {
    final chatJob = ChatJob(
      id: job.value?.id.toString() ?? "",
      jobType: job.value?.jobType,
      propertyOneLine: job.value?.property?.propertyName,
      date: DateTime.parse(job.value?.date ?? "").toIso8601String(),
      clientName: job.value?.user?.name ?? "",
    );
    final participants = <String, ChatParticipant>{};
    // Client
    if (job.value?.user?.id != null) {
      participants[job.value?.user?.id.toString() ?? ""] = ChatParticipant(
        id: job.value?.user?.id.toString() ?? "",
        name: job.value?.user?.name ?? "",
        role: RoleConstants.roleKeyClient,
      );
    }
    // Current user (cleaner)
    final userId = Prefs().userId;
    final userName = Prefs().userFullName;
    participants[userId] = ChatParticipant(id: userId, name: userName, role: RoleConstants.roleKeyCleaner);
    // Other cleaners on the same job
    /*for (final cleaner in job.cleaners) {
      if (cleaner.id != userId) {
        participants[cleaner.id] = ChatParticipant(
          id: cleaner.id,
          name: cleaner.name,
          role: RoleConstants.roleKeyCleaner,
        );
      }
    }*/
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
    final messageController = TextEditingController();
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
      message: 'You can add a reason (optional).',
      showPrimaryButton: true,
      body: Column(
        spacing: 8,
        children: [
          CommonText.bold('Decline job?', size: 24, color: scheme.primary, fontWeight: FontWeight.w900),
          CommonTextField(
            hint: 'You can add a reason (optional).',
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
      final result = await _cleanerRepository.declineJob(jobId: jobId, reason: msg);
      result.handle(
        success: (value) {
          Notifier.success(value.message ?? 'Job declined');
          WidgetsBinding.instance.addPostFrameCallback((_) {
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
      final result = await _cleanerRepository.acceptJob(jobId: jobId);
      result.handle(
        success: (value) {
          Notifier.success(value.message ?? 'Job Accepted');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            fetchJobDetails();
          });
        },
        contextTag: 'accept_job',
      );
    } finally {
      Loader.hide();
    }
  }

  void onShareCleanerProfile(ClientJobCleaner c) {
    Notifier.info('Share ${c.name} (coming soon)');
  }

  /// Navigate to review/feedback screen (completed jobs).
  void onReview() {
    Notifier.info('Review (coming soon)');
  }

  Future<void> fetchJobDetails() async {
    if (jobId == null) return;
    Loader.show();
    try {
      final result = await _cleanerRepository.getCleanerJobDetails(jobId!.toInt());
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
}
