import 'package:intl/intl.dart';

import 'package:ccs_app/export.dart';
import 'package:ccs_app/app/model/client_job.dart';
import 'cleaner_dashboard_controller.dart';
import 'cleaner_jobs_controller.dart';

class CleanerJobsView extends GetView<CleanerJobsController> {
  const CleanerJobsView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;

    return SafeArea(
      child: Padding(
        padding: UiConstants.padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /*CommonText.semiBold('Jobs', size: 22),
            const SizedBox(height: 12),*/
            Expanded(
              child: Obx(() {
                final list = controller.jobs;
                if (list.isEmpty) {
                  return NoDataView(
                    title: 'No jobs assigned',
                    subtitle: 'Update your availability to get more assignments.',
                    actionLabel: 'Edit availability',
                    onAction: () {
                      final ctrl = Get.find<CleanerDashboardController>();
                      ctrl.setTab(3); // Availability tab index
                    },
                  );
                }
                return ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final job = list[i];
                    return _JobListTile(
                      job: job,
                      onTap: () => controller.openDetail(job),
                      scheme: scheme,
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
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

    return Card(
      clipBehavior: Clip.antiAlias,
      color: context.colorScheme.onPrimary,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: CommonText.semiBold(job.clientName, size: 15, color: scheme.onSurface),
                  ),
                  _StatusChip(label: job.status, scheme: scheme),
                ],
              ),
              const SizedBox(height: 6),
              CommonText.regular(job.jobType, size: 14, color: scheme.onSurfaceVariant),
              const SizedBox(height: 4),
              CommonText.regular('$dateStr · $timeStr', size: 13, color: scheme.onSurfaceVariant),
              const SizedBox(height: 4),
              CommonText.regular(job.propertyOneLine, size: 13, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.scheme});

  final String label;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(UiConstants.radiusSmall),
      ),
      child: CommonText.medium(label, size: 12, color: scheme.primary),
    );
  }
}
