import 'package:ccs_app/app/widget/layout/app_scaffold.dart';

import '../../../../export.dart';
import 'upcoming_job_controller.dart';

class UpcomingJobView extends GetView<UpcomingJobController> {
  const UpcomingJobView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: Header(
        title: controller.isToday ? 'Today Jobs' : 'Upcoming Jobs',
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
                              final approvedCleaners = job.jobCleaners?.where((cleaner) => (cleaner.status?.toLowerCase() != 'rejected')).toList();
                              final timeRange = CcsDateUtils.formatJobTimeRange(job.startTime, job.endTime);
                              final dateLabel = CcsDateUtils.shortDateNoYear(DateTime.parse(job.date ?? ""));
                              return JobCard(
                                title: job.cleaningType?.name ?? "N/A",
                                dateTime: timeRange == null ? dateLabel : '$dateLabel · $timeRange',
                                status: job.status ?? "N/A",
                                subtitle: (job.cleaners == null || job.cleaners?.isEmpty == true)
                                    ? ' - '
                                    : job.cleaners
                                            ?.map((item) {
                                              var isCleanerAssign = false;

                                              isCleanerAssign = job.jobCleaners
                                                      ?.firstWhereOrNull((cl) => (cl.userId == item.id && (cl.status?.toLowerCase() != 'rejected'))) !=
                                                  null;
                                              return isCleanerAssign ? item.name ?? " - " : "";
                                            })
                                            .toList()
                                            .join(', ') ??
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
