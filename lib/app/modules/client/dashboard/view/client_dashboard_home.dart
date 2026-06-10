import 'package:ccs_app/app/modules/client/dashboard/client_dashboard_controller.dart';
import 'package:ccs_app/app/network/response/property_list_response.dart';
import 'package:ccs_app/export.dart';
import 'package:linear_progress_bar/linear_progress_bar.dart';
import 'package:step_progress/step_progress.dart';

import '../../../../network/response/jobs.dart';

/// Dashboard content (the actual dashboard UI, not the shell).
class ClientDashboardContent extends GetView<ClientDashboardController> {
  const ClientDashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return SwipeRefresh(
      onRefresh: () async {
        await controller.getClientDash();
        await controller.getProfile();
      },
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: UiConstants.padding,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.sizeOf(context).height - MediaQuery.paddingOf(context).top - MediaQuery.paddingOf(context).bottom,
            ),
            child: Obx(() {
              final progress = controller.registrationProgress.value;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 20,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (progress < 100) ...{
                    _ProfileProgressCard(scheme: context.colorScheme, controller: controller),
                    _RegistrationProgressCard(scheme: context.colorScheme, controller: controller)
                  } else ...{
                    _CardSection(
                      title: 'Properties',
                      leadingIcon: IconsaxPlusLinear.home_2,
                      leadingIconColor: scheme.secondary,
                      trailing: _ViewAllChip(
                        label: 'View all',
                        scheme: scheme,
                        onTap: () => Get.toNamed(Routes.PROPERTY),
                      ),
                      child: Obx(() {
                        final list = controller.dashboardProperties;
                        if (list.isEmpty) {
                          return _EmptyStateInline(
                            icon: IconsaxPlusLinear.home_2,
                            title: 'No properties yet',
                            subtitle: 'Add a property to book cleanings.',
                            actionLabel: 'Add property',
                            scheme: scheme,
                            padding: 0,
                            onAction: () => Get.toNamed(Routes.ADD_PROPERTY),
                          );
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (var i = 0; i < list.length; i++)
                              _DashboardPropertyTile(
                                property: list[i],
                                scheme: scheme,
                                onTap: () => Get.toNamed(Routes.ADD_PROPERTY, arguments: {'from': 'dash', 'property': list.value[i]}),
                                isLast: i == (list.length - 1),
                              ),
                          ],
                        );
                      }),
                    ),
                    Obx(() {
                      Jobs? todayJob;
                      if (controller.clientDash.value?.todayJobs?.isNotEmpty == true) {
                        todayJob = controller.clientDash.value?.todayJobs?.first;
                      }
                      return AppCard(
                        color: scheme.primary,
                        radius: UiConstants.radiusXLarge,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 18,
                          children: [
                            Row(
                              children: [
                                Icon(IconsaxPlusLinear.calendar_1, size: 20, color: scheme.onPrimary.withValues(alpha: 0.9)),
                                const SizedBox(width: 8),
                                CommonText.semiBold(
                                  'Today',
                                  size: 17,
                                  color: scheme.onPrimary,
                                ),
                                const Spacer(),
                                AppCard(
                                  color: scheme.primaryContainer.withValues(alpha: 0.2),
                                  onTap: () => controller.setTab(2),
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
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  AppCard(
                                    color: scheme.primaryContainer.withValues(alpha: 0.2),
                                    padding: const EdgeInsets.all(12),
                                    child: Icon(IconsaxPlusLinear.calendar, size: 24, color: scheme.onPrimary),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: todayJob != null
                                          ? Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                CommonText.semiBold(todayJob.cleaningType?.name ?? " - ", size: 16, color: scheme.onPrimary),
                                                if (todayJob.startTime?.isNullOrEmpty == false && todayJob.endTime?.isNullOrEmpty == false) ...[
                                                  const SizedBox(height: 6),
                                                  Row(
                                                    children: [
                                                      Icon(IconsaxPlusLinear.clock, size: 14, color: scheme.onPrimary.withValues(alpha: 0.6)),
                                                      const SizedBox(width: 6),
                                                      CommonText.regular(
                                                        CcsDateUtils.parseTimeRange(todayJob.startTime ?? "", todayJob.endTime ?? ""),
                                                        size: 12,
                                                        color: scheme.onPrimary.withValues(alpha: 0.6),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ],
                                            )
                                          : Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                CommonText.semiBold(
                                                  'No jobs found for today.',
                                                  size: 16,
                                                  color: scheme.onPrimary,
                                                ),
                                                const SizedBox(height: 4),
                                                CommonText.regular(
                                                  'Your next booking will appear here.',
                                                  size: 12,
                                                  color: scheme.onPrimary.withValues(alpha: 0.75),
                                                ),
                                              ],
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ).paddingAll(20),
                      );
                    }),
                    Obx(() {
                      var upcoming = controller.clientDash.value?.upcomingJobs;
                      return _CardSection(
                        title: 'Upcoming Pre-Bookings',
                        leadingIcon: IconsaxPlusLinear.calendar_tick,
                        leadingIconColor: scheme.secondary,
                        trailing: _ViewAllChip(
                          label: 'View all',
                          scheme: scheme,
                          onTap: () => Get.toNamed(Routes.UPCOMING_JOB),
                        ),
                        child: (upcoming != null && upcoming.isNotEmpty == true)
                            ? AppGrid(
                                physics: NeverScrollableScrollPhysics(),
                                maxExtent: 126,
                                axisSpacing: 16,
                                phoneCount: 1,
                                tabletCount: 2,
                                landscapeCount: 3,
                                child: upcoming.map((job) {
                                  String? timeRange;
                                  if (job.startTime != null && job.endTime != null) {
                                    timeRange = '${CcsDateTimeX.convertTime(job.startTime ?? '')} – ${CcsDateTimeX.convertTime(job.endTime ?? '')}';
                                  }
                                  return JobCard(
                                    padding: 4,
                                    title: job.cleaningType?.name ?? "N/A",
                                    dateTime: '${CcsDateUtils.shortDateNoYear(DateTime.parse(job.date ?? ""))} · $timeRange',
                                    status: job.status ?? "N/A",
                                    propertyName: job.property?.propertyName ?? "N/A",
                                    address: job.property?.address ?? "N/A",
                                    onTap: () => controller.openDetail(job),
                                    isFromDash: true,
                                  );
                                }).toList(),
                              )
                            : _EmptyStateInline(
                                icon: IconsaxPlusLinear.calendar_tick,
                                title: 'No upcoming bookings',
                                subtitle: 'Scheduled bookings will appear here.',
                                scheme: scheme,
                              ),
                      );
                    }),
                  }

                  /*CommonText.semiBold('Quick Actions', size: 16, color: scheme.onSurface),
              Row(
                children: [
                  Expanded(
                    child: QuickActionChip(
                      icon: IconsaxPlusLinear.additem,
                      label: 'Create Job',
                      subtitle: 'Add a new Job',
                      onTap: () => controller.setTab(3),
                      scheme: scheme,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: QuickActionChip(
                      icon: IconsaxPlusLinear.home_hashtag,
                      label: 'Property',
                      subtitle: 'Add a new property',
                      onTap: () => controller.setTab(4),
                      scheme: scheme,
                    ),
                  ),
                ],
              ),*/
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _CardSection extends StatelessWidget {
  const _CardSection({
    required this.title,
    required this.child,
    this.leadingIcon,
    this.leadingIconColor,
    this.trailing,
  });

  final String title;
  final Widget child;
  final IconData? leadingIcon;
  final Color? leadingIconColor;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final iconColor = leadingIconColor ?? scheme.primary;
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (leadingIcon != null) ...[
                  Icon(leadingIcon, size: 20, color: iconColor).marginOnly(right: 8),
                ],
                Expanded(
                  child: CommonText.semiBold(
                    title,
                    size: 16,
                    color: scheme.onSurface,
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ).marginOnly(bottom: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class _ViewAllChip extends StatelessWidget {
  const _ViewAllChip({
    required this.label,
    required this.scheme,
    required this.onTap,
    this.isOnPrimary = false,
  });

  final String label;
  final ColorScheme scheme;
  final VoidCallback onTap;
  final bool isOnPrimary;

  @override
  Widget build(BuildContext context) {
    final fg = isOnPrimary ? scheme.onPrimary : scheme.secondary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(UiConstants.radiusDefault),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CommonText.medium(label, size: 12, color: fg).marginOnly(right: 4),
              Icon(IconsaxPlusLinear.arrow_right_2, size: 12, color: fg),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyStateInline extends StatelessWidget {
  const _EmptyStateInline({required this.icon, required this.title, this.subtitle, this.actionLabel, this.onAction, required this.scheme, this.padding = 16});

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final ColorScheme scheme;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: padding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppCard(enableShadows: false, color: scheme.surfaceContainerHigh, child: Icon(icon, size: 28, color: scheme.onSurfaceVariant).paddingAll(14))
                .marginOnly(bottom: 12),
            CommonText.semiBold(title, size: 14, color: scheme.onSurface),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              CommonText.regular(
                subtitle!,
                size: 12,
                color: scheme.onSurfaceVariant,
                textAlign: TextAlign.center,
              ),
            ],
            if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: onAction,
                icon: Icon(IconsaxPlusLinear.add, size: 18, color: scheme.secondary),
                label: Text(actionLabel!),
                style: TextButton.styleFrom(
                  foregroundColor: scheme.secondary,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DashboardPropertyTile extends StatelessWidget {
  const _DashboardPropertyTile({
    required this.property,
    required this.scheme,
    required this.onTap,
    this.isLast = false,
  });

  final PropertyModel property;
  final ColorScheme scheme;
  final VoidCallback onTap;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final addressLine = [
      if (property.address != null && property.address!.isNotEmpty) property.address,
      if (property.city != null && property.city!.isNotEmpty) property.city,
    ].join(', ');
    final typeParts = <String>[
      if (property.businessType != null && property.businessType!.isNotEmpty) property.businessType!,
      if (property.propertyType != null && property.propertyType!.isNotEmpty) property.propertyType!,
    ];
    final typeLabel = typeParts.join(' • ');

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
      child: AppCard(
        onTap: onTap,
        enableShadows: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AppCard.iconContainer(
              context: context,
              child: Icon(IconsaxPlusLinear.home_2, color: scheme.secondary, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CommonText.semiBold(property.propertyName ?? 'N/A', size: 16, color: scheme.onSurface),
                  if (addressLine.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    CommonText.regular(
                      addressLine,
                      size: 14,
                      color: scheme.onSurfaceVariant,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (typeLabel.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(UiConstants.radiusSmall),
                      ),
                      child: CommonText.medium(
                        typeLabel.toUpperCase(),
                        size: 12,
                        color: scheme.onSurfaceVariant,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(IconsaxPlusLinear.arrow_right_3, size: 20, color: scheme.primary),
          ],
        ).paddingSymmetric(vertical: 12, horizontal: 8),
      ),
    );
  }
}

class _ProfileProgressCard extends StatelessWidget {
  const _ProfileProgressCard({
    required this.scheme,
    required this.controller,
  });

  final ColorScheme scheme;
  final ClientDashboardController controller;

  @override
  Widget build(BuildContext context) {
    final missingFields = controller.clientDash.value?.missingFields;
    return AppCard(
      onTap: null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Obx(() {
              final completion = controller.clientDash.value?.profileCompletion ?? 0;
              return CircularPercentIndicator(
                radius: 32,
                lineWidth: 6.0,
                percent: completion > 0 ? completion / 100 : 0.0,
                center: Text("$completion%"),
                progressColor: context.colorScheme.secondary,
                backgroundColor: Colors.grey.shade300,
                animation: true,
              );
            }),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText.semiBold('Complete Your Profile', size: 16, color: scheme.onSurface),
                const SizedBox(height: 2),
                if (missingFields?.isNotEmpty == true)
                  CommonText.regular(
                    "Missing : ${missingFields?.first.replaceAll('_', ' ')}",
                    size: 13,
                    color: scheme.onSurfaceVariant,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          AppButton(
            label: 'Complete',
            onPressed: () => Get.toNamed(Routes.CLIENT_EDIT_PROFILE),
            btnVerticalPadding: 8,
            btnCornerRadius: 12,
            btnHorizontalPadding: 12,
          ),
        ],
      ).paddingAll(UiConstants.defaultPadding),
    );
  }
}

class _RegistrationProgressCard extends StatelessWidget {
  const _RegistrationProgressCard({
    required this.scheme,
    required this.controller,
  });

  final ColorScheme scheme;
  final ClientDashboardController controller;

  @override
  Widget build(BuildContext context) {
    final completion = controller.clientDash.value?.registrationProgress ?? 0;

    return AppCard(
      onTap: null,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: CommonText.bold('Registration Progress', size: 18, color: scheme.onSurface)),
              CommonText.semiBold(
                "$completion% COMPLETE",
                size: 16,
                color: scheme.onSurfaceVariant,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          const SizedBox(height: 16),
          StepProgress(
            stepNodeSize: 60,
            theme: StepProgressThemeData(
              shape: StepNodeShape.circle,
              defaultForegroundColor: scheme.outline.withValues(alpha: 0.5),
              activeForegroundColor: scheme.secondary,
              enableRippleEffect: false,
              stepAnimationDuration: const Duration(milliseconds: 220),
              nodeLabelAlignment: StepLabelAlignment.bottom,
              nodeLabelStyle: StepLabelStyle(
                titleStyle: context.textTheme.bodyMedium?.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                defualtColor: scheme.onSurfaceVariant.withValues(alpha: 0.5),
                activeColor: scheme.secondary,
                margin: const EdgeInsets.only(top: 6),
                maxWidth: 50,
              ),
              stepNodeStyle: StepNodeStyle(
                decoration: BoxDecoration(
                  color: scheme.surface,
                  shape: BoxShape.circle,
                ),
                activeDecoration: BoxDecoration(
                  color: scheme.secondary,
                  shape: BoxShape.circle,
                ),
                activeIconColor: scheme.surface,
              ),
              stepLineStyle: StepLineStyle(
                isBreadcrumb: true,
                foregroundColor: scheme.surface,
                activeColor: scheme.secondary,
                lineThickness: 8,
              ),
            ),
            nodeIconBuilder: (index, completedStepIndex) => controller.nodeIcons[index],
            nodeTitles: [
              'Create Profile',
              'Add Property',
              'Create Job',
            ],
            controller: controller.stepProgressController,
            totalSteps: controller.stepProgressController.totalSteps,
            currentStep: controller.stepProgressController.initialStep,
            onStepNodeTapped: null,
          ),
          const SizedBox(height: 16),
          AppButton(
            label: controller.stepProgressController.currentStep == 0 ? 'Add Property' : 'Create Job',
            onPressed: () {
              if (controller.stepProgressController.currentStep == 0) {
                Get.toNamed(Routes.ADD_PROPERTY);
              } else {
                controller.goToCreateJob();
              }
            },
            btnVerticalPadding: 8,
            btnCornerRadius: 12,
            btnHorizontalPadding: 12,
            type: ButtonType.outline,
          ),
        ],
      ).paddingAll(UiConstants.defaultPadding),
    );
  }
}
