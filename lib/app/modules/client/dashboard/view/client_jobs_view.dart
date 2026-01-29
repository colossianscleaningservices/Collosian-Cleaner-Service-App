import 'package:ccs_app/app/model/client_job.dart';
import 'package:ccs_app/app/modules/client/dashboard/client_dashboard_controller.dart';
import 'package:ccs_app/export.dart';
import 'package:intl/intl.dart';

class ClientJobsView extends GetView<ClientDashboardController> {
  const ClientJobsView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Obx(() {
          final list = controller.jobs;
          if (list.isEmpty) {
            return SingleChildScrollView(
              padding: UiConstants.padding,
              child: NoDataView(
                title: 'No jobs yet',
                subtitle: 'Create a job or check back later.',
                icon: IconsaxPlusLinear.briefcase,
                actionLabel: 'Create job',
                onAction: () => Get.toNamed(Routes.CLIENT_CREATE_JOB),
              ),
            );
          }
          return SingleChildScrollView(
            padding: UiConstants.padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ...list.map(
                  (job) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _JobCard(
                      job: job,
                      onTap: () => controller.openDetail(job),
                      scheme: scheme,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        }),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(Routes.CLIENT_CREATE_JOB),
        icon: const Icon(IconsaxPlusLinear.add),
        label: const Text('Create job'),
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  const _JobCard({
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
      child: Row(
        children: [
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(UiConstants.radiusDefault),
            ),
            child: Icon(IconsaxPlusLinear.briefcase, color: scheme.primary, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: CommonText.semiBold(job.jobType, size: 18, color: scheme.onSurface),
                    ),
                    _StatusChip(label: job.status, scheme: scheme),
                  ],
                ),
                const SizedBox(height: 4),
                CommonText.regular(job.clientName, size: 13, color: scheme.onSurfaceVariant),
                const SizedBox(height: 4),
                CommonText.regular('$dateStr · $timeStr', size: 13, color: scheme.onSurfaceVariant),
                const SizedBox(height: 2),
                CommonText.regular(
                  job.propertyOneLine,
                  size: 13,
                  color: scheme.onSurfaceVariant,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(IconsaxPlusLinear.arrow_right_3, size: 20, color: scheme.onSurfaceVariant),
        ],
      ).paddingAll(UiConstants.defaultPadding),
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
        color: scheme.primaryContainer.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(UiConstants.radiusSmall),
      ),
      child: CommonText.medium(label, size: 12, color: scheme.primary),
    );
  }
}
