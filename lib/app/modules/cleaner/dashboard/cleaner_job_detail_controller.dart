import 'package:ccs_app/export.dart';
import '../../../model/client_job.dart';

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
    Notifier.info('Contact client (coming soon)');
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
