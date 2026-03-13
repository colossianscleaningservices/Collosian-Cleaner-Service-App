import 'package:ccs_app/app/modules/client/dashboard/client_dashboard_controller.dart';
import 'package:ccs_app/export.dart';

//Missing Info :- Client Name, Recurrence
class ClientJobsView extends GetView<ClientDashboardController> {
  const ClientJobsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: Obx(
        () {
          return controller.jobs.isEmpty
              ? SizedBox.shrink()
              : FloatingActionButton.extended(
                  onPressed: () => controller.goToCreateJob(),
                  icon: const Icon(IconsaxPlusLinear.add),
                  label: CommonText.regular('Create job'),
                );
        },
      ),
      body: SwipeRefresh(
        onRefresh: () async {
          controller.jobCurrentPage = 1;
          await controller.fetchJobs(isLoaderShown: false);
        },
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            controller: controller.jobScrollController,
            child: Obx(() {
              return Container(
                padding: UiConstants.padding,
                constraints: BoxConstraints(),
                child: controller.jobs.isEmpty
                    ? NoDataView(
                        title: 'No jobs yet',
                        subtitle: 'Create a job or check back later.',
                        icon: IconsaxPlusLinear.briefcase,
                        actionLabel: 'Create job',
                        onAction: () => controller.goToCreateJob(),
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppGrid(
                            physics: NeverScrollableScrollPhysics(),
                            maxExtent: 174,
                            axisSpacing: 16,
                            phoneCount: 1,
                            tabletCount: 2,
                            landscapeCount: 3,
                            child: controller.jobs.map((job) {
                              final approvedCleaners =
                                  job.jobCleaners?.where((cleaner) => (cleaner.status == 'Approved' || cleaner.status == 'Completed')).toList();

                              return JobCard(
                                title: job.cleaningType?.name ?? "N/A",
                                dateTime: '${CcsDateUtils.shortDateNoYear(DateTime.parse(job.date ?? ""))} · ${job.startTime} – ${job.endTime}',
                                status: job.status ?? "N/A",
                                subtitle: (job.cleaners == null || job.cleaners?.isEmpty == true)
                                    ? ' - '
                                    : job.cleaners
                                            ?.map((item) {
                                              var isCleanerAssign = false;

                                              isCleanerAssign =
                                                  job.jobCleaners?.firstWhereOrNull((cl) => (cl.userId == item.id && cl.status?.toLowerCase() == 'approved')) !=
                                                      null;
                                              return isCleanerAssign ? item.name ?? " - " : "";
                                            })
                                            .toList()
                                            .join(',') ??
                                        ' - ',
                                propertyName: job.property?.propertyName ?? "N/A",
                                address: job.property?.address ?? "N/A",
                                recurrence: job.scheduler?.frequency?.capitalizeFirst ?? "N/A",
                                cleanerInfo: job.cleaners?.isNotEmpty == true
                                    ? '${approvedCleaners?.length} of ${job.numberOfCleaners} assigned'
                                    : '${job.numberOfCleaners} cleaner${job.numberOfCleaners != 1 ? 's' : ''}',
                                onTap: () => controller.openDetail(job),
                              );
                            }).toList(),
                          ),
                          controller.isJobMoreLoading.value ? PageLoader() : SizedBox.shrink()
                        ],
                      ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
