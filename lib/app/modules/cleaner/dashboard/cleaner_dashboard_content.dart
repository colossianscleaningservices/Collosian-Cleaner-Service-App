import 'package:ccs_app/export.dart';
import 'package:intl/intl.dart';

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
    final jobCount = upcoming.length;

    return SafeArea(
      child: SingleChildScrollView(
        padding: UiConstants.padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Enhanced greeting section
            _GreetingSection(scheme: scheme),
            SizedBox(height: UiConstants.gap + 4),

            // Enhanced jobs hero card
            AppCard(
              radius: UiConstants.radiusLarge,
              enableShadows: true,
              shadowOpacity: 0.08,
              blurRadius: 12,
              offset: const Offset(0, 2),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              scheme.primaryContainer.withValues(alpha: 0.4),
                              scheme.primaryContainer.withValues(alpha: 0.2),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(UiConstants.radiusDefault),
                        ),
                        child: Icon(IconsaxPlusLinear.briefcase, size: 24, color: scheme.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CommonText.semiBold('Upcoming jobs', size: 17, color: scheme.onSurface),
                            if (hasJobs)
                              CommonText.regular(
                                '$jobCount ${jobCount == 1 ? 'job' : 'jobs'} scheduled',
                                size: 12,
                                color: scheme.onSurfaceVariant,
                              ),
                          ],
                        ),
                      ),
                      if (hasJobs)
                        TextButton(
                          onPressed: () => controller.setTab(2),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: scheme.primaryContainer.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(UiConstants.defaultRadius),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CommonText.medium('View all', size: 13, color: scheme.primary),
                                const SizedBox(width: 4),
                                Icon(IconsaxPlusLinear.arrow_right_2, size: 14, color: scheme.primary),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: hasJobs ? 16 : 12),
                  if (hasJobs && nextJob != null) ...[
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: scheme.secondaryContainer.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(UiConstants.radiusDefault),
                        border: Border.all(
                          color: scheme.outline.withValues(alpha: 0.1),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: scheme.primary.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: CommonText.medium('Next', size: 11, color: scheme.primary),
                              ),
                              const Spacer(),
                              Icon(
                                IconsaxPlusLinear.calendar_1,
                                size: 16,
                                color: scheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              CommonText.regular(
                                DateFormat('EEE d MMM').format(nextJob.$1),
                                size: 12,
                                color: scheme.onSurfaceVariant,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          CommonText.semiBold(nextJob.$2.title, size: 16, color: scheme.onSurface),
                          if (nextJob.$2.timeRange.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(IconsaxPlusLinear.clock, size: 14, color: scheme.onSurfaceVariant),
                                const SizedBox(width: 6),
                                CommonText.regular(
                                  nextJob.$2.timeRange,
                                  size: 13,
                                  color: scheme.onSurfaceVariant,
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.only(top: 8, left: 20, right: 20),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHighest.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(UiConstants.radiusDefault),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            IconsaxPlusLinear.briefcase,
                            size: 48,
                            color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 12),
                          CommonText.medium(
                            'No upcoming jobs',
                            size: 15,
                            color: scheme.onSurface,
                          ),
                          const SizedBox(height: 6),
                          CommonText.regular(
                            'Update your availability to get more assignments',
                            size: 13,
                            color: scheme.onSurfaceVariant,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          AppButton(
                            label: 'Edit availability',
                            type: ButtonType.tonal,
                            icon: IconsaxPlusLinear.clock,
                            onPressed: () => controller.setTab(3),
                            btnVerticalPadding: 12,
                            btnHorizontalPadding: 16,
                            textSize: 14,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: UiConstants.gap + 4),

            // Enhanced earnings block
            _DashboardBlock(
              icon: IconsaxPlusLinear.wallet_3,
              title: 'Total Earnings',
              value: controller.earningsTotal,
              subtitle: 'View details and history',
              onTap: () => Get.to(() => const CleanerEarningsView()),
              scheme: scheme,
            ),
            SizedBox(height: UiConstants.gap),

            // Enhanced action needed card
            if (controller.actionNeededCount > 0) ...[
              AppCard(
                radius: UiConstants.radiusLarge,
                enableShadows: true,
                shadowOpacity: 0.06,
                onTap: () => Get.to(
                  () => Scaffold(
                    appBar: AppBar(title: const Text('Action needed')),
                    body: const CleanerNotificationsView(),
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            scheme.errorContainer.withValues(alpha: 0.6),
                            scheme.errorContainer.withValues(alpha: 0.4),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(UiConstants.radiusDefault),
                      ),
                      child: Icon(IconsaxPlusLinear.notification, size: 24, color: scheme.error),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CommonText.semiBold('Action needed', size: 15, color: scheme.onSurface),
                          const SizedBox(height: 4),
                          CommonText.regular(
                            '${controller.actionNeededCount} ${controller.actionNeededCount == 1 ? 'item requires' : 'items require'} your attention',
                            size: 12,
                            color: scheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(UiConstants.radiusDefault),
                      ),
                      child: Icon(IconsaxPlusLinear.arrow_right_2, size: 18, color: scheme.primary),
                    ),
                  ],
                ),
              ),
              SizedBox(height: UiConstants.gap),
            ],

            // Enhanced profile completion card
            if (!controller.isProfileComplete) ...[
              AppCard(
                radius: UiConstants.radiusLarge,
                enableShadows: true,
                shadowOpacity: 0.06,
                padding: const EdgeInsets.all(18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            scheme.primaryContainer.withValues(alpha: 0.4),
                            scheme.primaryContainer.withValues(alpha: 0.2),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(UiConstants.radiusDefault),
                      ),
                      child: Icon(IconsaxPlusLinear.user_edit, size: 24, color: scheme.primary),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CommonText.semiBold('Complete your profile', size: 15, color: scheme.onSurface),
                          const SizedBox(height: 4),
                          CommonText.regular(
                            'Add missing documents and bank details to start earning',
                            size: 12,
                            color: scheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 14),
                          AppButton(
                            label: 'Complete profile',
                            type: ButtonType.tonal,
                            icon: IconsaxPlusLinear.arrow_right_2,
                            onPressed: () => controller.setTab(4),
                            btnVerticalPadding: 11,
                            btnHorizontalPadding: 14,
                            textSize: 13,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: UiConstants.gap),
            ],

            // Enhanced quick actions section
            Row(
              children: [
                CommonText.semiBold('Quick actions', size: 15, color: scheme.onSurface),
                const Spacer(),
                if (hasJobs)
                  CommonText.regular(
                    '$jobCount ${jobCount == 1 ? 'job' : 'jobs'}',
                    size: 12,
                    color: scheme.onSurfaceVariant,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _QuickActionChip(
                    icon: IconsaxPlusLinear.clock,
                    label: 'Availability',
                    subtitle: 'Set your schedule',
                    onTap: () => controller.setTab(3),
                    scheme: scheme,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionChip(
                    icon: IconsaxPlusLinear.user,
                    label: controller.isProfileComplete ? 'Profile' : 'Complete',
                    subtitle: controller.isProfileComplete ? 'View profile' : 'Finish setup',
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

/// Enhanced greeting section with better visual hierarchy
class _GreetingSection extends StatelessWidget {
  const _GreetingSection({required this.scheme});

  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonText.bold('$greeting!', size: 24, color: scheme.onSurface),
                  const SizedBox(height: 4),
                  CommonText.regular(
                    DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()),
                    size: 14,
                    color: scheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    scheme.primaryContainer.withValues(alpha: 0.4),
                    scheme.primaryContainer.withValues(alpha: 0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(UiConstants.radiusDefault),
              ),
              child: Icon(
                IconsaxPlusLinear.calendar_1,
                size: 20,
                color: scheme.primary,
              ),
            ),
          ],
        ),
      ],
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
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String value;
  final String? subtitle;
  final VoidCallback onTap;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      radius: UiConstants.radiusLarge,
      enableShadows: true,
      shadowOpacity: 0.06,
      onTap: onTap,
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  scheme.primaryContainer.withValues(alpha: 0.4),
                  scheme.primaryContainer.withValues(alpha: 0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(UiConstants.radiusDefault),
            ),
            child: Icon(icon, size: 24, color: scheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText.regular(title, size: 13, color: scheme.onSurfaceVariant),
                const SizedBox(height: 6),
                CommonText.bold(value, size: 22, color: scheme.onSurface),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  CommonText.regular(subtitle!, size: 12, color: scheme.onSurfaceVariant),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(UiConstants.radiusDefault),
            ),
            child: Icon(IconsaxPlusLinear.arrow_right_2, size: 20, color: scheme.primary),
          ),
        ],
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
    this.subtitle,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      radius: UiConstants.radiusDefault,
      enableShadows: false,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      color: scheme.onPrimary,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(UiConstants.radiusDefault),
            ),
            child: Icon(icon, size: 20, color: scheme.primary),
          ),
          const SizedBox(height: 10),
          CommonText.semiBold(label, size: 14, color: scheme.onSurface, textAlign: TextAlign.center),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            CommonText.regular(
              subtitle!,
              size: 11,
              color: scheme.onSurfaceVariant,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
