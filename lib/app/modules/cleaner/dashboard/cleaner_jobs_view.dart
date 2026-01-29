import 'package:ccs_app/app/model/client_job.dart';
import 'package:ccs_app/export.dart';
import 'package:intl/intl.dart';

import 'cleaner_dashboard_controller.dart';
import 'cleaner_jobs_controller.dart';

class CleanerJobsView extends GetView<CleanerJobsController> {
  const CleanerJobsView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _JobsHeader(scheme: scheme).marginOnly(left: 18, right: 18, top: 18, bottom: 16),
          Expanded(
            child: Obx(() {
              final list = controller.jobs;
              if (list.isEmpty) {
                return NoDataView(
                  icon: IconsaxPlusLinear.briefcase,
                  title: 'No jobs assigned',
                  subtitle: 'Update your availability to get more assignments.',
                  actionLabel: 'Edit availability',
                  onAction: () {
                    final ctrl = Get.find<CleanerDashboardController>();
                    ctrl.setTab(3);
                  },
                );
              }

              final now = DateTime.now();
              final today = DateTime(now.year, now.month, now.day);
              final upcoming = list.where((j) => j.date.isAfter(today) || _isSameDay(j.date, today)).toList();
              final past = list.where((j) => j.date.isBefore(today)).toList();

              return ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  if (upcoming.isNotEmpty) ...[
                    _SectionLabel(label: 'Upcoming', count: upcoming.length, scheme: scheme).marginOnly(left: 18, right: 18, bottom: 8),
                    ...upcoming.asMap().entries.map(
                          (e) => _JobListTile(
                            job: e.value,
                            onTap: () => controller.openDetail(e.value),
                            scheme: scheme,
                          ).marginOnly(bottom: 12),
                        ),
                    if (past.isNotEmpty) const SizedBox(height: 8),
                  ],
                  if (past.isNotEmpty) ...[
                    _SectionLabel(label: 'Past', count: past.length, scheme: scheme).marginOnly(left: 18, right: 18, bottom: 8),
                    ...past.asMap().entries.map(
                          (e) => _JobListTile(
                            job: e.value,
                            onTap: () => controller.openDetail(e.value),
                            scheme: scheme,
                          ).marginOnly(bottom: 12),
                        ),
                  ],
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  static bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
}

class _JobsHeader extends StatelessWidget {
  const _JobsHeader({required this.scheme});

  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return GetX<CleanerJobsController>(
      builder: (ctrl) {
        final count = ctrl.jobs.length;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonText.bold('Jobs', size: 24, color: scheme.onSurface),
                  const SizedBox(height: 4),
                  CommonText.regular(
                    count == 0 ? 'No assignments yet' : '$count ${count == 1 ? 'job' : 'jobs'} total',
                    size: 14,
                    color: scheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
            if (count > 0)
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
                    CommonText.semiBold('$count', size: 14, color: scheme.primary),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
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

class _JobListTile extends StatelessWidget {
  const _JobListTile({
    required this.job,
    required this.onTap,
    required this.scheme,
  });

  final ClientJob job;
  final VoidCallback onTap;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('EEE d MMM').format(job.date);
    final timeStr = '${job.startTime} – ${job.endTime}';

    return AppCard(
      onTap: onTap,
      radius: UiConstants.radiusLarge,
      enableShadows: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppCard(
                enableShadows: false,
                color: scheme.secondaryContainer,
                padding: const EdgeInsets.all(12),
                child: Icon(IconsaxPlusLinear.briefcase, size: 24, color: scheme.secondary),
              ).marginOnly(right: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText.semiBold(job.clientName, size: 16, color: scheme.onSurface).marginOnly(bottom: 4),
                    CommonText.regular(job.jobType, size: 14, color: scheme.onSurfaceVariant),
                  ],
                ),
              ),
              _StatusChip(label: job.status, scheme: scheme),
            ],
          ).marginOnly(bottom: 12),
          Row(
            children: [
              Icon(IconsaxPlusLinear.calendar_1, size: 16, color: scheme.onSurfaceVariant).marginOnly(right: 8),
              CommonText.regular(dateStr, size: 12, color: scheme.onSurfaceVariant).marginOnly(right: 16),
              Icon(IconsaxPlusLinear.clock, size: 16, color: scheme.onSurfaceVariant).marginOnly(right: 8),
              CommonText.regular(timeStr, size: 12, color: scheme.onSurfaceVariant),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(IconsaxPlusLinear.location, size: 16, color: scheme.onSurfaceVariant).marginOnly(right: 8),
              Expanded(
                child: CommonText.regular(
                  job.propertyOneLine,
                  size: 12,
                  color: scheme.onSurfaceVariant,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (job.recurrence != null && job.recurrence!.isNotEmpty) ...[
            AppCard(
              radius: UiConstants.radiusSmall,
              enableShadows: false,
              color: scheme.tertiaryContainer.withValues(alpha: 0.5),
              child: CommonText.medium(
                job.recurrence ?? "",
                size: 11,
                color: scheme.onTertiaryContainer,
              ).paddingSymmetric(horizontal: 8, vertical: 4),
            ).marginOnly(top: 8),
          ],
        ],
      ).paddingAll(16),
    ).marginOnly(left: 18, right: 18);
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.scheme});

  final String label;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final lower = label.toLowerCase();
    Color bg;
    Color fg;
    if (lower.contains('cancel')) {
      bg = scheme.errorContainer.withValues(alpha: 0.6);
      fg = scheme.error;
    } else if (lower.contains('complet') || lower.contains('done')) {
      bg = scheme.tertiaryContainer.withValues(alpha: 0.6);
      fg = scheme.onTertiaryContainer;
    } else {
      bg = scheme.primaryContainer.withValues(alpha: 0.5);
      fg = scheme.primary;
    }

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(UiConstants.radiusSmall),
      ),
      child: CommonText.semiBold(label, size: 12, color: fg).paddingSymmetric(horizontal: 12, vertical: 6),
    );
  }
}
