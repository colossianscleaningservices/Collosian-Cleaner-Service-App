import 'package:ccs_app/export.dart';

import '../../../model/client_job.dart';

class ClientJobDetailController extends GetxController {
  late final ClientJob job;

  @override
  void onInit() {
    super.onInit();

    // 1️⃣ Get lightweight job from previous page
    job = Get.arguments as ClientJob;

    // 2️⃣ Fetch full job details using ID
    fetchJobDetails(job.id);
  }

  Future<void> fetchJobDetails(String id) async {
    try {
      //  TODO: Call the job details API here
    } catch (e) {
      e.printError();
    }
  }

  void onEdit() {
    // TODO: navigate to edit screen
    Notifier.info('Edit job (coming soon)');
  }

  void confirmDeleteJob(BuildContext context) {
    Notifier.openSheet(
      context,
      type: SheetType.info,
      title: 'Delete job?',
      message: 'This will remove this "${job.jobType}" job. This action cannot be undone.',
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
    // TODO: confirm + API
    Notifier.info('Cancel job (coming soon)');
  }

  void onShareCleanerProfile(ClientJobCleaner c) {
    Notifier.info('Share ${c.name} (coming soon)');
  }
}
