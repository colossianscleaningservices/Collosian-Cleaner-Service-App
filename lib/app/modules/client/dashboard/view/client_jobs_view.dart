import 'package:ccs_app/app/modules/client/dashboard/client_dashboard_controller.dart';
import 'package:ccs_app/export.dart';

class ClientJobsView extends GetView<ClientDashboardController> {
  const ClientJobsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: UiConstants.padding,
          child: controller.jobs.isEmpty
              ? NoDataView(
                  title: 'No jobs yet',
                  subtitle: 'Create a job or check back later.',
                  icon: IconsaxPlusLinear.briefcase,
                  actionLabel: 'Create job',
                  onAction: () => Get.toNamed(Routes.CLIENT_CREATE_JOB),
                )
              : AppGrid(
                  maxExtent: 142,
                  axisSpacing: 16,
                  phoneCount: 1,
                  tabletCount: 2,
                  landscapeCount: 3,
                  child: controller.jobs.map((job) {
                    return JobCard(
                      title: job.jobType,
                      dateTime: '${CcsDateUtils.shortDateNoYear(job.date)} · ${job.startTime} – ${job.endTime}',
                      status: job.status,
                      subtitle: job.clientName,
                      property: job.propertyOneLine,
                      recurrence: job.recurrence,
                      onTap: () => controller.openDetail(job),
                    );
                  }).toList(),
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(Routes.CLIENT_CREATE_JOB),
        icon: const Icon(IconsaxPlusLinear.add),
        label: const Text('Create job'),
      ),
    );
  }
}
