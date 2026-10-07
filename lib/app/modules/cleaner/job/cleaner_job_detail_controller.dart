import 'dart:async';

import 'package:ccs_app/app/modules/cleaner/dashboard/cleaner_dashboard_controller.dart';
import 'package:ccs_app/app/network/repository/cleaner_repository.dart';
import 'package:ccs_app/export.dart';
import 'package:intl/intl.dart';

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
  final now = DateTime.now().obs;
  Timer? _timer;

  String? get _jobStatus => job.value?.status;

  String? get _cleanerJobStatus => job.value?.cleanerJobStatus;

  bool get _jobClosed => JobStatusX.isCancelled(_jobStatus) || JobStatusX.isJobFinished(_jobStatus);

  /// Invitation sent; cleaner has not responded.
  bool get canAcceptOrDecline {
    return !_jobClosed && (JobStatusX.isPending(_cleanerJobStatus) || _cleanerJobStatus == null);
  }

  /// Admin has assigned this cleaner; Check IN is available.
  bool get canStartJob => !_jobClosed && JobStatusX.isApproved(_cleanerJobStatus);

  /// Cleaner has checked in; Check OUT is available.
  bool get canStopJob => !JobStatusX.isCancelled(_jobStatus) && JobStatusX.isInProcess(_cleanerJobStatus);

  /// Cleaner has checked out.
  bool get isCleanerWorkComplete => JobStatusX.isCleanerCompleted(_cleanerJobStatus);

  /// True when job is completed and cleaner can tap "Review".
  bool get canShowReview {
    var s = ((job.value?.jobCleaners?.firstWhereOrNull((item) => item.userId.toString() == Prefs().userId)?.status));
    return JobStatusX.isCleanerCompleted(s);
  }

  /// Bottom bar state: 1 = Check IN, 2 = Check OUT, 3 = Review. 0 = hide bar.
  int get bottomBarState {
    if (canStartJob) return 1;
    if (canStopJob) return 2;
    /*if (canShowReview) return 3;*/
    return 0;
  }

  String get bottomBarLabel {
    switch (bottomBarState) {
      case 1:
        return 'Check IN';
      case 2:
        return 'Check OUT';
      case 3:
        return 'Review';
      default:
        return '';
    }
  }

  VoidCallback? get bottomBarOnPressed {
    switch (bottomBarState) {
      case 1:
        return isCheckInTimeValid ? onStartJob : null;
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
    _startTimer();
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
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  void _startTimer() {
    _timer?.cancel();
    now.value = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      now.value = DateTime.now();
    });
  }

  TimeOfDay? _parseTimeOfDayString(String? timeStr) {
    if (timeStr == null || timeStr.trim().isEmpty) return null;
    final trimmed = timeStr.trim();

    final tod = CcsDateTimeX.parseToTimeOfDay(trimmed);
    if (tod != null) return tod;

    try {
      final dt = DateFormat('hh:mm a').parse(trimmed);
      return TimeOfDay(hour: dt.hour, minute: dt.minute);
    } catch (_) {}

    try {
      final dt = DateFormat('h:mm a').parse(trimmed);
      return TimeOfDay(hour: dt.hour, minute: dt.minute);
    } catch (_) {}

    try {
      final dt = DateFormat('HH:mm').parse(trimmed);
      return TimeOfDay(hour: dt.hour, minute: dt.minute);
    } catch (_) {}

    return null;
  }

  DateTime? get jobStartDateTime {
    final j = job.value;
    if (j == null) return null;

    final dateStr = (j.jobStartDate != null && j.jobStartDate.toString().trim().isNotEmpty)
        ? j.jobStartDate.toString().trim()
        : (j.date?.trim() ?? '');

    DateTime? baseDate;
    if (dateStr.isNotEmpty) {
      baseDate = DateTime.tryParse(dateStr)?.toLocal();
      if (baseDate == null) {
        try {
          baseDate = DateFormat('dd-MM-yyyy').parse(dateStr);
        } catch (_) {}
      }
    }

    final startTimeStr = j.startTime?.trim();
    final tod = _parseTimeOfDayString(startTimeStr);

    if (baseDate != null && tod != null) {
      return DateTime(baseDate.year, baseDate.month, baseDate.day, tod.hour, tod.minute);
    } else if (baseDate != null) {
      return baseDate;
    } else if (startTimeStr != null && startTimeStr.isNotEmpty) {
      return DateTime.tryParse(startTimeStr)?.toLocal();
    }

    return null;
  }

  /// Returns true if current time is within 15 minutes before or 30 minutes after job start time.
  bool get isCheckInTimeValid {
    final start = jobStartDateTime;
    if (start == null) return true;

    final current = now.value;
    final windowStart = start.subtract(const Duration(minutes: 15));
    final windowEnd = start.add(const Duration(minutes: 30));

    return !current.isBefore(windowStart) && !current.isAfter(windowEnd);
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
