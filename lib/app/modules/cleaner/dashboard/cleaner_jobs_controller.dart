import 'package:ccs_app/export.dart';
import '../../../model/client_job.dart';

/// Controller for the cleaner's jobs list. Uses ClientJob as the shared job model.
/// Replace demoJobs with API-backed "my assigned jobs" when ready.
class CleanerJobsController extends GetxController {
  final jobs = <ClientJob>[].obs;

  @override
  void onReady() {
    super.onReady();
    jobs.assignAll(ClientJob.demoJobs);
  }

  void openDetail(ClientJob job) {
    final path = Routes.CLEANER_JOB_DETAIL.replaceFirst(':id', job.id);
    Get.toNamed(path, arguments: job);
  }
}
