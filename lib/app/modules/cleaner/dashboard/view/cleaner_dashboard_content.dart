import 'package:ccs_app/app/network/response/staff_dashboard_response.dart';
import 'package:ccs_app/export.dart';
import 'package:linear_progress_bar/ui/circular_percent_indicator.dart';
import 'package:ccs_app/app/services/pref.dart';
import '../cleaner_dashboard_controller.dart';
import 'cleaner_earnings_view.dart';

/// Cleaner home: dashboard layout with jobs hero, earnings, action needed, quick actions.
/// Title/subtitle come from [Header] via [Constants.cleanerTopHeading].
class CleanerDashboardContent extends GetView<CleanerDashboardController> {
  const CleanerDashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return SwipeRefresh(
      onRefresh: () async {
        await controller.fetchDashboardData(showAlert: false);
        await controller.getProfile();
      },
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: UiConstants.padding,
          child: Column(
            spacing: 18,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Enhanced greeting section
              _GreetingSection(scheme: scheme),

              // Enhanced jobs hero card
              Obx(() {
                controller.staffDash.value;

                List<UpcomingJob?> upcomingJobs = [];
                if (controller.staffDash.value?.upcomingJob != null) upcomingJobs.add(controller.staffDash.value?.upcomingJob);
                final upcoming = upcomingJobs;
                final hasJobs = upcoming.isNotEmpty;
                final nextJob = hasJobs ? upcoming.first : null;

                return AppCard(
                  color: scheme.primary,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
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
                                    '${upcoming.length} ${upcoming.length == 1 ? 'job' : 'jobs'} scheduled',
                                    size: 12,
                                    color: scheme.onPrimary.withValues(alpha: 0.6),
                                  ),
                              ],
                            ),
                          ),
                          if (hasJobs)
                            AppCard(
                              color: scheme.primaryContainer.withValues(alpha: 0.2),
                              onTap: () => controller.openAllJobs(),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CommonText.medium('View all', size: 12, color: scheme.onPrimary),
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
                                    onTap: null,
                                    child: CommonText.medium('Next', size: 11, color: scheme.onPrimary).paddingSymmetric(horizontal: 12, vertical: 6),
                                  ),
                                  const Spacer(),
                                  Icon(
                                    IconsaxPlusLinear.calendar_1,
                                    size: 16,
                                    color: scheme.onPrimary,
                                  ),
                                  const SizedBox(width: 4),
                                  if (nextJob.date?.isNullOrEmpty == false)
                                    CommonText.regular(
                                      CcsDateUtils.shortDateNoYear(DateTime.parse(nextJob.date ?? "")),
                                      size: 12,
                                      color: scheme.onPrimary,
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              CommonText.semiBold(nextJob.cleaningType?.name ?? " - ", size: 16, color: scheme.onPrimary),
                              if (nextJob.startTime?.isNullOrEmpty == false && nextJob.endTime?.isNullOrEmpty == false) ...[
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(IconsaxPlusLinear.clock, size: 14, color: scheme.onPrimary.withValues(alpha: 0.6)),
                                    const SizedBox(width: 6),
                                    CommonText.regular(
                                      CcsDateUtils.parseTimeRange(nextJob.startTime ?? "", nextJob.endTime ?? ""),
                                      size: 12,
                                      color: scheme.onPrimary.withValues(alpha: 0.6),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ).paddingSymmetric(horizontal: 16, vertical: 14),
                          onTap: () => controller.openDetail(nextJob.id),
                        ),
                      ] else ...[
                        AppCard(
                          onTap: null,
                          color: scheme.primaryContainer.withValues(alpha: 0.2),
                          child: SizedBox(
                            width: double.infinity,
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
                                  size: 12,
                                  color: scheme.onPrimary,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                AppButton(
                                  label: 'Edit availability',
                                  type: ButtonType.tonal,
                                  icon: IconsaxPlusLinear.clock,
                                  onPressed: () => controller.setTab(2),
                                  btnVerticalPadding: 12,
                                  btnHorizontalPadding: 16,
                                  textSize: 14,
                                ).marginOnly(bottom: 12),
                              ],
                            ).paddingOnly(top: 8, left: 20, right: 20),
                          ),
                        ),
                      ],
                    ],
                  ).paddingAll(16),
                );
              }),

              Obx(() {
                final isStudent = Prefs().getData(Prefs.isStudent) == 'true';
                final usedHours = controller.staffDash.value?.studentWeeklyHoursUsed ?? 0;

                if (isStudent && usedHours > 20) {
                  return AppCard(
                    color: scheme.errorContainer.withValues(alpha: 0.4),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(IconsaxPlusLinear.info_circle, size: 24, color: scheme.error),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CommonText.semiBold('Working hours exceeded', size: 16, color: scheme.error),
                              const SizedBox(height: 4),
                              CommonText.regular(
                                'You have exceeded the weekly limit of 20 working hours for students.',
                                size: 12,
                                color: scheme.error,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),

              AppCard(
                onTap: () {
                  Get.to(() => const CleanerEarningsView());
                  if (controller.payoutEarning.value == null) controller.getPayoutDash();
                },
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
                          CommonText.regular('Total Earnings', size: 12, color: scheme.onSurfaceVariant),
                          Obx(() {
                            return CommonText.bold(controller.earningsTotal.value, size: 22, color: scheme.onSurface);
                          }),
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
              
              // Enhanced profile completion card
              Obx(() {
                final completion = controller.staffDash.value?.profileCompletion?.percentage ?? 0;

                if (controller.isProfileComplete.value) return const SizedBox.shrink();
                return AppCard(
                  radius: UiConstants.radiusLarge,
                  enableShadows: true,
                  shadowOpacity: 0.06,
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: CircularPercentIndicator(
                          radius: 32,
                          lineWidth: 6.0,
                          percent: completion > 0 ? completion / 100 : 0.0,
                          center: Text("$completion%"),
                          progressColor: context.colorScheme.secondary,
                          backgroundColor: Colors.grey.shade300,
                          animation: true,
                        ),
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
                              onPressed: () => Get.toNamed(Routes.CLEANER_EDIT_PROFILE),
                              btnVerticalPadding: 12,
                              btnHorizontalPadding: 14,
                              textSize: 12,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

/// Greeting with the cleaner's name, today's date, and assigned job count.
class _GreetingSection extends GetView<CleanerDashboardController> {
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

    return Obx(() {
      final name = controller.userDisplayName.value.trim();
      final title = name.isEmpty ? '$greeting!' : '$greeting, $name!';
      final jobCount = controller.staffDash.value?.assignedJobCount?.toInt() ?? 0;
      final jobLabel = jobCount == 1 ? '1 job assigned' : '$jobCount jobs assigned';

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText.bold(title, size: 24, color: scheme.onSurface, maxLines: 2,overflow: TextOverflow.ellipsis,),
          const SizedBox(height: 8),
          CommonText.regular(
            '${CcsDateUtils.longDate(DateTime.now())} · $jobLabel',
            size: 14,
            color: scheme.onSurfaceVariant,
          ),
        ],
      );
    });
  }
}
