import 'package:ccs_app/app/utils/date_utils.dart';
import 'package:ccs_app/export.dart';

import '../../../../widget/quick_action.dart';
import '../cleaner_dashboard_controller.dart';
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

    return SingleChildScrollView(
      padding: UiConstants.padding,
      child: Column(
        spacing: 18,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enhanced greeting section
          _GreetingSection(scheme: scheme),

          // Enhanced jobs hero card
          AppCard(
            color: scheme.primary,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AppCard(
                      color: scheme.primaryContainer.withValues(alpha: 0.2),
                      padding: const EdgeInsets.all(12),
                      child: Icon(IconsaxPlusLinear.briefcase, size: 24, color: scheme.onPrimary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CommonText.semiBold('Upcoming jobs', size: 16, color: scheme.onPrimary),
                          if (hasJobs)
                            CommonText.regular(
                              '$jobCount ${jobCount == 1 ? 'job' : 'jobs'} scheduled',
                              size: 12,
                              color: scheme.onPrimary.withValues(alpha: 0.6),
                            ),
                        ],
                      ),
                    ),
                    if (hasJobs)
                      AppCard(
                        color: scheme.primaryContainer.withValues(alpha: 0.2),
                        onTap: () => controller.setTab(2),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CommonText.medium('View all', size: 13, color: scheme.onPrimary),
                            const SizedBox(width: 4),
                            Icon(IconsaxPlusLinear.arrow_right_2, size: 14, color: scheme.onPrimary),
                          ],
                        ),
                      ),
                  ],
                ),
                SizedBox(height: hasJobs ? 16 : 12),
                if (hasJobs && nextJob != null) ...[
                  AppCard(
                    color: scheme.primaryContainer.withValues(alpha: 0.2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            AppCard(
                              color: scheme.primaryContainer.withValues(alpha: 0.2),
                              child: CommonText.medium('Next', size: 11, color: scheme.onPrimary).paddingSymmetric(horizontal: 12, vertical: 6),
                            ),
                            const Spacer(),
                            Icon(
                              IconsaxPlusLinear.calendar_1,
                              size: 16,
                              color: scheme.onPrimary,
                            ),
                            const SizedBox(width: 4),
                            CommonText.regular(
                              CcsDateUtils.shortDateNoYear(nextJob.$1),
                              size: 12,
                              color: scheme.onPrimary,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        CommonText.semiBold(nextJob.$2.title, size: 16, color: scheme.onPrimary),
                        if (nextJob.$2.timeRange.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(IconsaxPlusLinear.clock, size: 14, color: scheme.onPrimary.withValues(alpha: 0.6)),
                              const SizedBox(width: 6),
                              CommonText.regular(
                                nextJob.$2.timeRange,
                                size: 13,
                                color: scheme.onPrimary.withValues(alpha: 0.6),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ).paddingSymmetric(horizontal: 16, vertical: 14),
                  ),
                ] else ...[
                  AppCard(
                    color: scheme.primaryContainer.withValues(alpha: 0.2),
                    child: Column(
                      children: [
                        Icon(
                          IconsaxPlusLinear.briefcase,
                          size: 48,
                          color: scheme.onPrimary,
                        ),
                        const SizedBox(height: 12),
                        CommonText.medium(
                          'No upcoming jobs',
                          size: 16,
                          color: scheme.onPrimary.withValues(alpha: 0.6),
                        ),
                        const SizedBox(height: 6),
                        CommonText.regular(
                          'Update your availability to get more assignments',
                          size: 13,
                          color: scheme.onPrimary,
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
                    ).paddingOnly(top: 8, left: 20, right: 20),
                  ),
                ],
              ],
            ).paddingAll(16),
          ),

          AppCard(
            onTap: () => Get.to(() => const CleanerEarningsView()),
            child: Row(
              children: [
                AppCard(
                  enableShadows: false,
                  color: scheme.secondaryContainer,
                  padding: const EdgeInsets.all(12),
                  child: Icon(IconsaxPlusLinear.wallet_3, size: 24, color: scheme.secondary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [
                      CommonText.regular('Total Earnings', size: 13, color: scheme.onSurfaceVariant),
                      CommonText.bold(controller.earningsTotal, size: 22, color: scheme.onSurface),
                      CommonText.regular("View details and history", size: 12, color: scheme.onSurfaceVariant),
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
            ).paddingAll(18),
          ),

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
                  AppCard(
                    enableShadows: false,
                    color: scheme.errorContainer.withValues(alpha: 0.4),
                    padding: const EdgeInsets.all(12),
                    child: Icon(IconsaxPlusLinear.notification, size: 24, color: scheme.error),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonText.semiBold('Action needed', size: 16, color: scheme.onSurface),
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
                      color: scheme.surfaceContainerHighest.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(UiConstants.radiusDefault),
                    ),
                    child: Icon(IconsaxPlusLinear.arrow_right_2, size: 20, color: scheme.primary),
                  ),
                ],
              ),
            ),
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
                  AppCard(
                    enableShadows: false,
                    color: scheme.secondaryContainer,
                    padding: const EdgeInsets.all(12),
                    child: Icon(IconsaxPlusLinear.user_edit, size: 24, color: scheme.secondary),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonText.semiBold('Complete your profile', size: 16, color: scheme.onSurface),
                        const SizedBox(height: 4),
                        CommonText.regular(
                          'Add missing documents and bank details to start earning',
                          size: 12,
                          color: scheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 14),
                        AppButton(
                          bgColor: scheme.primaryContainer.withValues(alpha: 0.6),
                          label: 'Complete profile',
                          type: ButtonType.tonal,
                          icon: IconsaxPlusLinear.arrow_right_2,
                          onPressed: () => controller.setTab(4),
                          btnVerticalPadding: 12,
                          btnHorizontalPadding: 14,
                          textSize: 12,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Enhanced quick actions section
          Row(
            children: [
              CommonText.semiBold('Quick actions', size: 16, color: scheme.onSurface),
              const Spacer(),
              if (hasJobs)
                CommonText.regular(
                  '$jobCount ${jobCount == 1 ? 'job' : 'jobs'}',
                  size: 12,
                  color: scheme.onSurfaceVariant,
                ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: QuickActionChip(
                  icon: IconsaxPlusLinear.clock,
                  label: 'Availability',
                  subtitle: 'Set your schedule',
                  onTap: () => controller.setTab(3),
                  scheme: scheme,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: QuickActionChip(
                  icon: IconsaxPlusLinear.user,
                  label: controller.isProfileComplete ? 'Profile' : 'Complete',
                  subtitle: controller.isProfileComplete ? 'View profile' : 'Finish setup',
                  onTap: () => controller.setTab(4),
                  scheme: scheme,
                ),
              ),
            ],
          ),
        ],
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
                    CcsDateUtils.longDate(DateTime.now()),
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
