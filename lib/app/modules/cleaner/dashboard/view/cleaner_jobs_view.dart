import 'package:ccs_app/export.dart';

import '../cleaner_dashboard_controller.dart';

class CleanerJobsView extends GetView<CleanerDashboardController> {
  const CleanerJobsView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(
            () => CommonDropDownField<String>(
              label: 'Job Status',
              hint: 'Select status',
              items: controller.filter.map((e) => e.type).toList(),
              itemLabel: (v) => v,
              value: controller.filter.firstWhereOrNull((e) => e.isSelected)?.type ?? 'All Jobs',
              onChanged: (selected) {
                if (selected == null) return;
                for (final element in controller.filter) {
                  element.isSelected = element.type == selected;
                }
                controller.jobCurrentPage = 1;
                controller.fetchJobs(filter: selected != 'All Jobs' ? selected : '');
                controller.filter.refresh();
              },
            ),
          ).marginOnly(left: 18, right: 18),
          Obx(() {
            controller.jobs.value;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonText.bold('Jobs', size: 24, color: scheme.onSurface),
                      const SizedBox(height: 4),
                      Obx(() {
                        return CommonText.regular(
                          controller.jobs.isEmpty ? 'No assignments yet' : '${controller.jobs.length} ${controller.jobs.length == 1 ? 'job' : 'jobs'} total',
                          size: 14,
                          color: scheme.onSurfaceVariant,
                        );
                      }),
                    ],
                  ),
                ),
                if (controller.jobs.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(UiConstants.radiusDefault),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(IconsaxPlusLinear.calendar_1, size: 18, color: scheme.primary),
                        const SizedBox(width: 6),
                        Obx(() {
                          return CommonText.semiBold('${controller.jobs.length}', size: 14, color: scheme.primary);
                        }),
                      ],
                    ),
                  ),
              ],
            ).marginOnly(left: 18, right: 18, top: 18, bottom: 16);
          }),
          Expanded(
            child: Obx(() {
              final list = controller.jobs.value;
              if (list.isEmpty) {
                return NoDataView(
                  icon: IconsaxPlusLinear.briefcase,
                  title: 'No jobs assigned',
                  subtitle: 'Update your availability to get more assignments.',
                  actionLabel: 'Edit availability',
                  onAction: () => controller.setTab(2),
                );
              }

              final now = DateTime.now();
              final today = DateTime(now.year, now.month, now.day);
              final upcoming = list.where((j) => DateTime.parse(j.date ?? "").isAfter(today) || _isSameDay(DateTime.parse(j.date ?? ""), today)).toList();
              final past = list.where((j) => DateTime.parse(j.date ?? "").isBefore(today)).toList();

              final slivers = <Widget>[
                if (upcoming.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: _SectionLabel(label: 'Upcoming', count: upcoming.length, scheme: scheme).marginOnly(left: 18, right: 18, bottom: 8),
                  ),
                  AppSliverGrid(
                    maxExtent: 174,
                    physics: NeverScrollableScrollPhysics(),
                    axisSpacing: 12,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    phoneCount: 1,
                    tabletCount: 2,
                    landscapeCount: 3,
                    child: upcoming.map(
                      (job) {
                        var status = job.cleanerJobStatus ?? (job.status ?? "N/A");
                        String? timeRange;
                        if (job.startTime != null && job.endTime != null) {
                          timeRange = '${CcsDateTimeX.convertTime(job.startTime ?? '')} – ${CcsDateTimeX.convertTime(job.endTime ?? '')}';
                        }
                        if (job.status == Constants.jobFinished) {
                          status = job.status ?? status;
                        }

                        return JobCard(
                          title: job.cleaningType?.name ?? "N/A",
                          dateTime: '${CcsDateUtils.shortDateNoYear(DateTime.parse(job.date ?? ""))} · $timeRange',
                          status: status,
                          subtitle: (job.jobCleaners == null || job.jobCleaners?.isEmpty == true)
                              ? ' - '
                              : job.jobCleaners?.map((item) => "${item.user?.firstName} ${item.user?.lastName}").toList().join(', ') ?? ' - ',
                          propertyName: job.property?.propertyName ?? "N/A",
                          address: job.property?.address ?? "N/A",
                          recurrence: job.scheduler?.frequency?.capitalizeFirst ?? "N/A",
                          cleanerInfo: job.jobCleaners?.isNotEmpty == true
                              ? '${job.jobCleaners?.length} of ${job.numberOfCleaners} assigned'
                              : '${job.numberOfCleaners ?? 0} cleaner${(job.numberOfCleaners ?? 0) > 1 ? 's' : ''}',
                          onTap: () => controller.openDetail(job.id),
                        );
                      },
                    ).toList(),
                  ),
                  if (past.isNotEmpty) const SliverToBoxAdapter(child: SizedBox(height: 8)),
                ],
                if (past.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: _SectionLabel(label: 'Past', count: past.length, scheme: scheme).marginOnly(left: 18, right: 18, bottom: 8),
                  ),
                  AppSliverGrid(
                    maxExtent: 174,
                    physics: NeverScrollableScrollPhysics(),
                    axisSpacing: 12,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    phoneCount: 1,
                    tabletCount: 2,
                    landscapeCount: 3,
                    child: past.map(
                      (job) {
                        var status = job.cleanerJobStatus ?? (job.status ?? "N/A");

                        String? timeRange;
                        if (job.startTime != null && job.endTime != null) {
                          timeRange = '${CcsDateTimeX.convertTime(job.startTime ?? '')} – ${CcsDateTimeX.convertTime(job.endTime ?? '')}';
                        }

                        if (job.status == Constants.jobFinished) {
                          status = job.status ?? status;
                        }
                        return JobCard(
                          title: job.cleaningType?.name ?? "N/A",
                          dateTime: '${CcsDateUtils.shortDateNoYear(DateTime.parse(job.date ?? ""))} · $timeRange',
                          status: status,
                          subtitle: job.jobCleaners?.map((item) => "${item.user?.firstName} ${item.user?.lastName}").toList().join(', ') ?? "N/A",
                          propertyName: job.property?.propertyName ?? "N/A",
                          address: job.property?.address ?? "N/A",
                          recurrence: job.scheduler?.frequency?.capitalizeFirst ?? "N/A",
                          cleanerInfo: job.jobCleaners?.isNotEmpty == true
                              ? '${job.jobCleaners?.length} of ${job.numberOfCleaners} assigned'
                              : '${job.numberOfCleaners ?? 0} cleaner${(job.numberOfCleaners ?? 0) > 1 ? 's' : ''}',
                          onTap: () => controller.openDetail(job.id),
                        );
                      },
                    ).toList(),
                  ),
                ],
                if (controller.isJobMoreLoading.value)
                  SliverToBoxAdapter(
                    child: PageLoader().marginOnly(top: 8),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ];
              return CustomScrollView(
                controller: controller.jobScrollController,
                slivers: slivers,
              );
            }),
          ),
        ],
      ),
    );
  }

  static bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.count, required this.scheme});

  final String label;
  final int count;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CommonText.semiBold(label, size: 15, color: scheme.onSurface),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(UiConstants.radiusSmall),
          ),
          child: CommonText.medium('$count', size: 12, color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
