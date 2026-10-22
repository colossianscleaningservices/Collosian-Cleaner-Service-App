import 'package:ccs_app/app/network/response/jobs.dart';
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
        await controller.fetchTodayJobs();
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
              // Greeting
              _GreetingSection(scheme: scheme),

              // 1. Earnings card — on top
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

              // Student hours warning
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

              // 2. Profile completion — compact inline
              Obx(() {
                final completion = controller.staffDash.value?.profileCompletion?.percentage ?? 0;

                if (controller.isProfileComplete.value) return const SizedBox.shrink();
                return AppCard(
                  onTap: () => Get.toNamed(Routes.CLEANER_EDIT_PROFILE),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      CircularPercentIndicator(
                        radius: 18,
                        lineWidth: 4.0,
                        percent: completion > 0 ? completion / 100 : 0.0,
                        center: CommonText.medium('$completion%', size: 9, color: scheme.onSurface),
                        progressColor: scheme.secondary,
                        backgroundColor: Colors.grey.shade300,
                        animation: true,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CommonText.semiBold('Complete your profile', size: 13, color: scheme.onSurface),
                            CommonText.regular(
                              'Add documents & bank details',
                              size: 11,
                              color: scheme.onSurfaceVariant,
                            ),
                          ],
                        ),
                      ),
                      Icon(IconsaxPlusLinear.arrow_right_2, size: 18, color: scheme.onSurfaceVariant),
                    ],
                  ),
                );
              }),

              // 3. Today's jobs — below earnings
              Obx(() {
                final todayList = controller.todayJobs;
                final isLoading = controller.isTodayJobsLoading.value;
                final hasJobs = todayList.isNotEmpty;

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
                                CommonText.semiBold("Today's jobs", size: 16, color: scheme.onPrimary),
                                if (hasJobs)
                                  CommonText.regular(
                                    '${todayList.length} ${todayList.length == 1 ? 'job' : 'jobs'} today',
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
                      const SizedBox(height: 16),
                      if (isLoading && !hasJobs)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: scheme.onPrimary,
                            ),
                          ),
                        )
                      else if (hasJobs)
                        ...todayList.map((job) => _TodayJobCard(
                              job: job,
                              scheme: scheme,
                              onTap: () => controller.openDetail(job.id),
                            ))
                      else ...[
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
                                  'No jobs today',
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

/// Individual job card shown inside the "Today's jobs" hero section.
class _TodayJobCard extends StatelessWidget {
  const _TodayJobCard({
    required this.job,
    required this.scheme,
    required this.onTap,
  });

  final Jobs job;
  final ColorScheme scheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cleaningName = job.cleaningType?.name;
    final title = (cleaningName != null && cleaningName.isNotEmpty && num.tryParse(cleaningName) == null)
        ? cleaningName
        : (job.jobType ?? 'Job');
    final timeRange = CcsDateUtils.formatJobTimeRange(job.startTime, job.endTime);
    final propertyName = job.property?.propertyName;
    final address = job.property?.address;
    final status = job.cleanerJobStatus ?? job.status;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        color: scheme.primaryContainer.withValues(alpha: 0.2),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: CommonText.semiBold(title, size: 15, color: scheme.onPrimary),
                ),
                if (status != null)
                  AppCard(
                    color: scheme.primaryContainer.withValues(alpha: 0.25),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    child: CommonText.medium(
                      status,
                      size: 11,
                      color: scheme.onPrimary.withValues(alpha: 0.8),
                    ),
                  ),
              ],
            ),
            if (timeRange != null && timeRange.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(IconsaxPlusLinear.clock, size: 14, color: scheme.onPrimary.withValues(alpha: 0.6)),
                  const SizedBox(width: 6),
                  CommonText.regular(timeRange, size: 12, color: scheme.onPrimary.withValues(alpha: 0.7)),
                ],
              ),
            ],
            if (propertyName != null && propertyName.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(IconsaxPlusLinear.home_2, size: 14, color: scheme.onPrimary.withValues(alpha: 0.6)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: CommonText.regular(
                      propertyName,
                      size: 12,
                      color: scheme.onPrimary.withValues(alpha: 0.7),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            if (address != null && address.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(IconsaxPlusLinear.location, size: 14, color: scheme.onPrimary.withValues(alpha: 0.6)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: CommonText.regular(
                      address,
                      size: 11,
                      color: scheme.onPrimary.withValues(alpha: 0.6),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ).paddingSymmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}
