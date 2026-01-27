import 'package:intl/intl.dart';

import 'package:ccs_app/export.dart';
import 'cleaner_dashboard_controller.dart';
import 'cleaner_earnings_view.dart';
import 'cleaner_notifications_view.dart';

/// Cleaner home: dashboard layout with jobs hero, earnings, action needed, quick actions.
/// Title/subtitle come from [Header] via [Constants.cleanerTopHeading].
class CleanerDashboardContent extends GetView<CleanerDashboardController> {
  const CleanerDashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final upcoming = controller.upcomingJobsForDashboard;
    final hasJobs = upcoming.isNotEmpty;
    final nextJob = hasJobs ? upcoming.first : null;

    return SafeArea(
      child: SingleChildScrollView(
        padding: UiConstants.padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting + date
            CommonText.semiBold('Ready for today\'s work?', size: 18, color: scheme.onSurface),
            const SizedBox(height: 2),
            CommonText.regular(DateFormat('EEEE, d MMM yyyy').format(DateTime.now()), size: 13, color: scheme.onSurfaceVariant),
            SizedBox(height: UiConstants.gap),

            // Jobs hero: next upcoming or empty state
            Card(
              elevation: 1,
              shadowColor: Colors.black.withValues(alpha: 0.06),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(IconsaxPlusLinear.briefcase, size: 20, color: scheme.primary),
                        const SizedBox(width: 8),
                        CommonText.semiBold('Upcoming jobs', size: 16, color: scheme.onSurface),
                        const Spacer(),
                        if (hasJobs)
                          TextButton(
                            onPressed: () => controller.setTab(2),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: CommonText.medium('View all', size: 13, color: scheme.primary),
                          ),
                      ],
                    ),
                    SizedBox(height: hasJobs ? 12 : 8),
                    if (hasJobs && nextJob != null) ...[
                      CommonText.regular('Next', size: 12, color: scheme.onSurfaceVariant),
                      const SizedBox(height: 4),
                      CommonText.semiBold(nextJob.$2.title, size: 15, color: scheme.onSurface),
                      const SizedBox(height: 2),
                      CommonText.regular(
                        '${nextJob.$2.timeRange} · ${DateFormat('EEE d MMM').format(nextJob.$1)}',
                        size: 13,
                        color: scheme.onSurfaceVariant,
                      ),
                    ] else ...[
                      CommonText.regular(
                        'No upcoming jobs. Update your availability to get more assignments.',
                        size: 14,
                        color: scheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 12),
                      AppButton(
                        label: 'Edit availability',
                        type: ButtonType.tonal,
                        icon: IconsaxPlusLinear.clock,
                        onPressed: () => controller.setTab(3),
                        btnVerticalPadding: 10,
                        btnHorizontalPadding: 14,
                        textSize: 13,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            SizedBox(height: UiConstants.gap),

            // Earnings (tappable → Total, History, Payout)
            _DashboardBlock(
              icon: IconsaxPlusLinear.wallet_3,
              title: 'Earnings',
              value: controller.earningsTotal,
              onTap: () => Get.to(() => const CleanerEarningsView()),
              scheme: scheme,
            ),
            SizedBox(height: UiConstants.gap),

            // Action needed
            if (controller.actionNeededCount > 0) ...[
              Card(
                child: InkWell(
                  onTap: () => Get.to(
                    () => Scaffold(
                      appBar: AppBar(title: const Text('Action needed')),
                      body: const CleanerNotificationsView(),
                    ),
                  ),
                  borderRadius: BorderRadius.circular(UiConstants.radiusLarge),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: scheme.primaryContainer.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(UiConstants.radiusDefault),
                          ),
                          child: Icon(IconsaxPlusLinear.notification, size: 22, color: scheme.primary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CommonText.semiBold('Action needed', size: 14, color: scheme.onSurface),
                              CommonText.regular(
                                '${controller.actionNeededCount} item${controller.actionNeededCount == 1 ? '' : 's'}',
                                size: 12,
                                color: scheme.onSurfaceVariant,
                              ),
                            ],
                          ),
                        ),
                        CommonText.medium('View', size: 13, color: scheme.primary),
                        const SizedBox(width: 4),
                        Icon(IconsaxPlusLinear.arrow_right_2, size: 16, color: scheme.primary),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: UiConstants.gap),
            ],

            // Profile completion (conditional)
            if (!controller.isProfileComplete) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 44,
                        width: 44,
                        decoration: BoxDecoration(
                          color: scheme.primaryContainer.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(UiConstants.radiusDefault),
                        ),
                        child: Icon(IconsaxPlusLinear.user_edit, color: scheme.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CommonText.semiBold('Complete your profile', size: 14, color: scheme.onSurface),
                            const SizedBox(height: 2),
                            CommonText.regular('Missing documents and bank details.', size: 12, color: scheme.onSurfaceVariant),
                            const SizedBox(height: 12),
                            AppButton(
                              label: 'Complete',
                              type: ButtonType.tonal,
                              onPressed: () {
                                controller.setTab(4);
                              },
                              btnVerticalPadding: 10,
                              btnHorizontalPadding: 12,
                              textSize: 13,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: UiConstants.gap),
            ],

            // Quick actions
            CommonText.semiBold('Quick actions', size: 14, color: scheme.onSurfaceVariant),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _QuickActionChip(
                    icon: IconsaxPlusLinear.clock,
                    label: 'Edit availability',
                    onTap: () => controller.setTab(3),
                    scheme: scheme,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionChip(
                    icon: IconsaxPlusLinear.user,
                    label: controller.isProfileComplete ? 'Profile' : 'Complete profile',
                    onTap: () => controller.setTab(4),
                    scheme: scheme,
                  ),
                ),
              ],
            ),
            const SizedBox(height: UiConstants.gap),
          ],
        ),
      ),
    );
  }
}

class _DashboardBlock extends StatelessWidget {
  const _DashboardBlock({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
    required this.scheme,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(UiConstants.radiusLarge),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(UiConstants.radiusDefault),
                ),
                child: Icon(icon, size: 22, color: scheme.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText.regular(title, size: 13, color: scheme.onSurfaceVariant),
                    const SizedBox(height: 2),
                    CommonText.semiBold(value, size: 18, color: scheme.onSurface),
                  ],
                ),
              ),
              Icon(IconsaxPlusLinear.arrow_right_2, size: 20, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  const _QuickActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.scheme,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: scheme.surfaceContainerHighest.withValues(alpha: 0.6),
      borderRadius: BorderRadius.circular(UiConstants.radiusDefault),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(UiConstants.radiusDefault),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: scheme.primary),
              const SizedBox(width: 8),
              Flexible(
                child: CommonText.medium(label, size: 13, color: scheme.onSurface),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
