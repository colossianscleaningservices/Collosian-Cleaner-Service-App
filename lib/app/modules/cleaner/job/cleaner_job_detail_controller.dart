import 'package:ccs_app/export.dart';

import '../../../model/chat_message.dart';
import '../../../model/client_job.dart';
import '../../../services/pref.dart';

/// Controller for cleaner job detail. Same full job data as client; actions are cleaner-oriented (directions, contact, accept/decline).
class CleanerJobDetailController extends GetxController {
  late final ClientJob job;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    final id = Get.parameters['id'];
    if (args is ClientJob) {
      job = args;
    } else if (id != null) {
      final found = ClientJob.byId(id);
      if (found != null) {
        job = found;
      } else {
        job = ClientJob(
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
      job = ClientJob(
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
    Notifier.info('Decline job (coming soon)');
  }

  void onShareCleanerProfile(ClientJobCleaner c) {
    Notifier.info('Share ${c.name} (coming soon)');
  }
}
