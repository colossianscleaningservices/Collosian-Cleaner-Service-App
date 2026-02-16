import 'package:ccs_app/app/network/repository/cleaner_repository.dart';
import 'package:ccs_app/export.dart';

import '../../../model/chat_message.dart';
import '../../../model/client_job.dart';
import '../../../services/pref.dart';
import 'job_check_photo_controller.dart';

/// Controller for cleaner job detail. Same full job data as client; actions are cleaner-oriented (directions, contact, accept/decline, start/stop with photos).
class CleanerJobDetailController extends GetxController {
  final CleanerRepository _cleanerRepository = CleanerRepository();

  final Rx<ClientJob> _job = Rx<ClientJob>(ClientJob(
    id: '',
    clientName: '—',
    jobType: '—',
    date: DateTime.now(),
    startTime: '—',
    endTime: '—',
    status: 'Unknown',
    propertyOneLine: '—',
  ));

  ClientJob get job => _job.value;

  /// True when cleaner can tap "Start job" (e.g. Scheduled, Accepted).
  bool get canStartJob {
    final s = _job.value.status.toLowerCase();
    return s == 'scheduled' || s == 'accepted';
  }

  /// True when cleaner can tap "Stop job" (job in progress).
  bool get canStopJob {
    final s = _job.value.status.toLowerCase();
    return s == 'in progress' || s == 'in_progress';
  }

  /// True when job is completed and cleaner can tap "Review".
  bool get canShowReview {
    final s = _job.value.status.toLowerCase();
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

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    final id = Get.parameters['id'];
    ClientJob initial;
    if (args is ClientJob) {
      initial = args;
    } else if (id != null) {
      final found = ClientJob.byId(id);
      if (found != null) {
        initial = found;
      } else {
        initial = ClientJob(
          id: id,
          clientName: '—',
          jobType: '—',
          date: DateTime.now(),
          startTime: '—',
          endTime: '—',
          status: 'Unknown',
          propertyOneLine: '—',
        );
      }
    } else {
      initial = ClientJob(
        id: '',
        clientName: '—',
        jobType: '—',
        date: DateTime.now(),
        startTime: '—',
        endTime: '—',
        status: 'Unknown',
        propertyOneLine: '—',
      );
    }
    _job.value = initial;
  }

  /// Navigate to check-in photo screen; on success update job status to in progress.
  void onStartJob() {
    Get.toNamed(Routes.CLEANER_JOB_CHECKIN, arguments: {'job': job, 'mode': JobCheckPhotoMode.checkIn})?.then((result) {
      if (result == true) _job.value = job.copyWith(status: 'In progress');
    });
  }

  /// Navigate to check-out photo screen; on success update job status to completed.
  void onStopJob() {
    Get.toNamed(Routes.CLEANER_JOB_CHECKOUT, arguments: {'job': job, 'mode': JobCheckPhotoMode.checkOut})?.then((result) {
      if (result == true) _job.value = job.copyWith(status: 'Completed');
    });
  }

  void onDirections() {
    Notifier.info('Open in maps (coming soon)');
  }

  void onContactClient() {
    final chatJob = ChatJob(
      id: job.id,
      jobType: job.jobType,
      propertyOneLine: job.propertyOneLine,
      date: job.date.toIso8601String(),
      clientName: job.clientName,
    );
    final participants = <String, ChatParticipant>{};
    // Client
    if (job.clientId != null && job.clientId!.isNotEmpty) {
      participants[job.clientId!] = ChatParticipant(
        id: job.clientId!,
        name: job.clientName,
        role: RoleConstants.roleKeyClient,
      );
    }
    // Current user (cleaner)
    final userId = Prefs().userId;
    final userName = Prefs().userFullName;
    participants[userId] = ChatParticipant(id: userId, name: userName, role: RoleConstants.roleKeyCleaner);
    // Other cleaners on the same job
    for (final cleaner in job.cleaners) {
      if (cleaner.id != userId) {
        participants[cleaner.id] = ChatParticipant(
          id: cleaner.id,
          name: cleaner.name,
          role: RoleConstants.roleKeyCleaner,
        );
      }
    }
    Get.toNamed(Routes.JOB_CHAT, arguments: {
      'type': ChatConstants.typeJob,
      'jobId': job.id,
      'job': chatJob,
      'participants': participants,
    });
  }

  void onAccept() {
    Notifier.info('Accept job (coming soon)');
  }

  void onDecline() {
    final jobId = int.tryParse(job.id);
    if (jobId == null) {
      Notifier.info('Invalid job');
      return;
    }
    Notifier.openSheet(
      Get.context!,
      title: 'Decline job?',
      message: 'You can add a reason (optional).',
      showPrimaryButton: true,
      showSecondaryButton: true,
      primaryButtonLabel: 'Decline',
      secondaryButtonLabel: 'Keep',
      onPrimaryPressed: () => _declineJob(jobId),
    );
  }

  Future<void> _declineJob(int jobId) async {
    final result = await _cleanerRepository.declineJob(jobId: jobId);
    result.handle(
      success: (_) {
        Notifier.success('Job declined');
        Get.back();
      },
      contextTag: 'decline_job',
    );
  }

  void onShareCleanerProfile(ClientJobCleaner c) {
    Notifier.info('Share ${c.name} (coming soon)');
  }

  /// Navigate to review/feedback screen (completed jobs).
  void onReview() {
    Notifier.info('Review (coming soon)');
  }
}
