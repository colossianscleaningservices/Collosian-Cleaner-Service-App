import 'package:ccs_app/app/model/client_job.dart';
import 'package:ccs_app/app/network/response/get_staff_job_details_response.dart';
import 'package:ccs_app/app/services/pref.dart';
import 'package:ccs_app/app/widget/job/job_detail_shared.dart';
import 'package:ccs_app/app/widget/layout/app_scaffold.dart';
import 'package:ccs_app/app/widget/layout/bottom_action_bar.dart';
import 'package:ccs_app/export.dart';

import 'cleaner_job_detail_controller.dart';

/// Cleaner job detail: status-first ticket layout with scannable property, client, and schedule.
class CleanerJobDetailView extends GetView<CleanerJobDetailController> {
  const CleanerJobDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Obx(() {
      final j = controller.job.value;
      final loading = controller.isFetching.value;
      final err = controller.fetchError.value;
      final canChat = j?.user?.id != null;

      final cleaner = j?.jobCleaners?.firstWhereOrNull((item) => item.userId.toString() == Prefs().userId);
      return AppScaffold(
        appBar: Header(
          title: j?.cleaningType?.name ?? (loading ? '' : 'Job details'),
          headerLogoIcon: false,
          hasBackIcon: true,
          titleCentered: false,
          actions: [
            if (canChat)
              IconButton(
                tooltip: 'Chat',
                onPressed: controller.onContactClient,
                icon: Icon(IconsaxPlusLinear.message_text, size: 22, color: scheme.primary),
              ),
          ],
        ),
        backgroundColor: scheme.surface,
        body: SwipeRefresh(
          onRefresh: () async {
            await controller.fetchJobDetails(isLoaderShown: false);
          },
          child: SafeArea(
            child: _cleanerBody(
              context: context,
              controller: controller,
              scheme: scheme,
              j: j,
              loading: loading,
              err: err,
              cleaner: cleaner,
            ),
          ),
        ),
        bottomNavigationBar: Obx(() {
          if (controller.isFetching.value && controller.job.value == null) {
            return const _BottomBarLoadingSkeleton();
          }
          if (controller.canAcceptOrDecline) {
            return DualActionBottomBar(
              secondaryLabel: 'Decline',
              secondaryOnPressed: controller.onDecline,
              secondaryButtonType: ButtonType.outline,
              primaryLabel: 'Accept',
              primaryOnPressed: controller.onAccept,
            );
          }
          return controller.bottomBarState != 0
              ? SingleActionBottomBar(
                  label: controller.bottomBarLabel,
                  onPressed: controller.bottomBarOnPressed,
                  buttonType: controller.bottomBarButtonType,
                )
              : const SizedBox.shrink();
        }),
      );
    });
  }
}

class _BottomBarLoadingSkeleton extends StatelessWidget {
  const _BottomBarLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return BottomActionBar(
      children: [
        Expanded(
          child: Container(
            height: UiConstants.defaultButtonHeight,
            decoration: BoxDecoration(
              color: scheme.secondary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}

Widget _cleanerBody({
  required BuildContext context,
  required CleanerJobDetailController controller,
  required ColorScheme scheme,
  required StaffJobDetails? j,
  required bool loading,
  required String? err,
  required JobCleaners? cleaner,
}) {
  final c = controller;

  if (c.jobId == null) {
    return Center(
      child: Padding(
        padding: UiConstants.padding,
        child: CommonText.regular(
          'This job could not be opened.',
          size: 15,
          color: scheme.onSurfaceVariant,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
  if (j == null && loading) {
    return JobDetailLoadingSkeleton(scheme: scheme);
  }
  if (j == null && err != null) {
    return JobDetailFetchError(
      message: err,
      scheme: scheme,
      onRetry: () => c.fetchJobDetails(isLoaderShown: false),
    );
  }
  if (j == null) {
    return Center(
      child: CommonText.regular(
        'No job data.',
        size: 15,
        color: scheme.onSurfaceVariant,
      ),
    );
  }

  return _CleanerJobContent(
    controller: c,
    job: j,
    scheme: scheme,
    cleaner: cleaner,
  );
}

class _CleanerJobContent extends StatelessWidget {
  const _CleanerJobContent({
    required this.controller,
    required this.job,
    required this.scheme,
    required this.cleaner,
  });

  final CleanerJobDetailController controller;
  final StaffJobDetails job;
  final ColorScheme scheme;
  final JobCleaners? cleaner;

  @override
  Widget build(BuildContext context) {
    final p = job.property;
    final streetCity = [p?.address, p?.city].whereType<String>().where((s) => s.trim().isNotEmpty).join(', ');
    final postcode = p?.postalCode?.trim();
    final addressText = [
      if (streetCity.isNotEmpty) streetCity,
      if (postcode != null && postcode.isNotEmpty) postcode,
    ].join(', ');
    final typeLine = [p?.propertyType, p?.subType].whereType<String>().map((s) => s.trim()).where((s) => s.isNotEmpty).join(' · ');
    final notes = job.additionalDetails?.toString().trim() ?? '';
    final hasNotes = notes.isNotEmpty;
    final hasTeam = job.jobCleaners != null && job.jobCleaners!.isNotEmpty;
    final clientName = job.user?.name?.trim() ?? '';

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: UiConstants.padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _HeroOverviewCard(job: job, scheme: scheme),
          if (controller.canAcceptOrDecline) ...[
            const SizedBox(height: 12),
            _InvitationBanner(scheme: scheme),
          ],
          Obx(() {
            return (controller.canStartJob && !controller.isCheckInTimeValid)
                ? Column(
                    children: [
                      const SizedBox(height: 12),
                      _CheckInWindowBanner(controller: controller, scheme: scheme),
                    ],
                  )
                : SizedBox.shrink();
          }),
          const SizedBox(height: 20),
          _DetailSection(
            semanticLabel: 'Property and client',
            icon: IconsaxPlusLinear.home_2,
            title: 'Property & client',
            scheme: scheme,
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  JobPropertyBlock(
                    propertyName: p?.propertyName ?? 'N/A',
                    typeLine: typeLine.isEmpty ? null : typeLine,
                    addressText: addressText.isEmpty ? null : addressText,
                    scheme: scheme,
                  ),
                  if (_propertyFacts(job).isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _propertyFacts(job)
                          .map(
                            (fact) => _FactChip(
                              icon: fact.$1,
                              label: fact.$2,
                              scheme: scheme,
                            ),
                          )
                          .toList(),
                    ),
                  ],
                  if (_accessText(job) != null) ...[
                    const SizedBox(height: 12),
                    _AccessRow(access: _accessText(job)!, scheme: scheme),
                  ],
                  if (clientName.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Divider(height: 1, color: scheme.outline.withValues(alpha: 0.16)),
                    const SizedBox(height: 14),
                    _ClientRow(
                      name: clientName,
                      imageUrl: job.user?.imageUrl,
                      canChat: job.user?.id != null,
                      onChat: controller.onContactClient,
                      scheme: scheme,
                    ),
                  ],
                ],
              ).paddingAll(UiConstants.defaultPadding),
            ),
          ),
          if (controller.isCleanerWorkComplete) ...[
            const SizedBox(height: 20),
            _DetailSection(
              semanticLabel: 'Attendance',
              icon: IconsaxPlusLinear.tick_circle,
              title: 'Attendance',
              scheme: scheme,
              child: _AttendanceCard(cleaner: cleaner, scheme: scheme),
            ),
          ],
          if (hasTeam) ...[
            const SizedBox(height: 20),
            _DetailSection(
              semanticLabel: 'Cleaners',
              icon: IconsaxPlusLinear.profile_2user,
              title: 'Team',
              scheme: scheme,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: (job.cleaners ?? []).map((cl) {
                  final item = job.jobCleaners?.firstWhereOrNull((e) => e.userId.toString() == cl.id.toString());
                  final isCurrentCleaner = cl.id.toString() == Prefs().userId;
                  final roleId = int.tryParse(Prefs().getData(Prefs.roleId));
                  final phone = cl.phoneNumber?.trim() ?? '';
                  final canCall = RoleConstants.isCleaner(roleId) && !isCurrentCleaner && phone.isNotEmpty;
                  final cardCleaner = ClientJobCleaner(
                    id: cl.id.toString(),
                    name: cl.name ?? 'N/A',
                    status: cl.status ?? 'N/A',
                    isReview: item?.isReviewed ?? false,
                    avatarUrl: cl.imageUrl,
                    cleanerType: item?.cleanerType ?? (isCurrentCleaner ? job.myCleanerType : null),
                    cleanerTypeLabel: item?.cleanerTypeLabel ?? (isCurrentCleaner ? job.myCleanerTypeLabel : null),
                  );
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Semantics(
                      label: canCall ? 'Cleaner ${cardCleaner.name}, call' : 'Cleaner ${cardCleaner.name}',
                      child: CleanerCard(
                        cleaner: cardCleaner,
                        scheme: scheme,
                        onReview: () => {},
                        onTap: () => {},
                        showActions: false,
                        onCall: canCall ? () => controller.callTeammate(phone) : null,
                        footer: isCurrentCleaner && _showTraineeProgress(job) ? _TraineeProgressBlock(job: job, scheme: scheme) : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
          SizedBox(height: job.cleaners?.isNotEmpty == true ? 10 : 20),
          _DetailSection(
            semanticLabel: 'Preferences and equipment',
            icon: IconsaxPlusLinear.box_1,
            title: 'On site',
            scheme: scheme,
            child: AppCard(
              child: JobPreferencesBlock(
                scheme: scheme,
                staffPreference: job.staffPreference ?? job.property?.staffPreference,
                equipmentChips: buildJobEquipmentChips(
                  scheme: scheme,
                  hoover: job.hoover ?? job.property?.hoover,
                  provideCleaningProducts: job.property?.provideCleaningProducts ?? job.provideCleaningProducts,
                  provideWashingMachine: job.property?.provideWashingMachine ?? job.provideWashingMachine,
                  provideDryer: job.property?.provideDryer ?? job.provideDryer,
                ),
              ).paddingAll(UiConstants.defaultPadding),
            ),
          ),
          if (hasNotes) ...[
            const SizedBox(height: 20),
            _DetailSection(
              semanticLabel: 'Additional notes',
              icon: IconsaxPlusLinear.document_text_1,
              title: 'Notes',
              scheme: scheme,
              child: _NotesCard(notes: notes, scheme: scheme),
            ),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _HeroOverviewCard extends StatelessWidget {
  const _HeroOverviewCard({
    required this.job,
    required this.scheme,
  });

  final StaffJobDetails job;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final statusLabel = JobStatusX.displayLabelForCleaner(
      jobStatus: job.status,
      cleanerJobStatus: job.cleanerJobStatus,
    );
    final statusForColor = JobStatusX.isJobFinished(job.status)
        ? (job.status ?? 'Finished')
        : JobStatusX.isCleanerCompleted(job.cleanerJobStatus)
            ? (job.cleanerJobStatus ?? 'Completed')
            : (job.status ?? statusLabel);
    final jobClosed = JobStatusX.isCancelled(job.status) || JobStatusX.isJobFinished(job.status);
    final hasDate = _staffHasScheduleDate(job);
    final timeRange = CcsDateUtils.formatJobTimeRange(job.startTime, job.endTime);
    String? endsFormatted;
    if (job.jobEndDate != null && job.jobEndDate.toString().trim().isNotEmpty) {
      endsFormatted = _staffParseEndDate(job.jobEndDate);
    }
    final dateText = hasDate ? _staffScheduleDateText(job) : null;
    final frequency = job.scheduler?.frequency?.trim();
    final payment = job.jobType?.trim();
    final title = (job.cleaningType?.name != null && job.cleaningType!.name!.trim().isNotEmpty)
        ? job.cleaningType!.name!.trim()
        : (job.property?.propertyName?.trim().isNotEmpty == true ? job.property!.propertyName!.trim() : 'Job details');
    final lineColor = JobCard.statusLineColor(statusForColor, scheme);

    return Semantics(
      container: true,
      label: 'Status and schedule',
      child: AppCard(
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: lineColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 16, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: CommonText.semiBold(
                              title,
                              size: 18,
                              color: scheme.onSurface,
                            ),
                          ),
                          const SizedBox(width: 8),
                          InfoChip(
                            label: statusLabel,
                            backgroundColor: getBgColor(statusForColor, scheme),
                            foregroundColor: getFgColor(statusForColor, scheme),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (!jobClosed)
                            InfoChip(
                              label: hasDate ? 'Scheduled' : 'Not scheduled',
                              backgroundColor: hasDate ? scheme.primaryContainer : scheme.surfaceContainerHighest,
                              foregroundColor: hasDate ? scheme.primary : scheme.onSurfaceVariant,
                            ),
                          if (frequency != null && frequency.isNotEmpty)
                            InfoChip(
                              label: frequency.capitalizeFirst ?? frequency,
                              backgroundColor: scheme.tertiaryContainer,
                              foregroundColor: scheme.tertiary,
                            ),
                          if (payment != null && payment.isNotEmpty)
                            InfoChip(
                              label: payment.capitalizeFirst ?? payment,
                              backgroundColor: scheme.secondaryContainer,
                              foregroundColor: scheme.onSecondaryContainer,
                            ),
                        ],
                      ),
                      if (dateText != null || (timeRange != null && timeRange.trim().isNotEmpty) || endsFormatted != null) ...[
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            color: scheme.surfaceContainerHigh.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(UiConstants.radiusDefault),
                          ),
                          child: Column(
                            children: [
                              if (dateText != null)
                                _ScheduleFact(
                                  icon: IconsaxPlusLinear.calendar_1,
                                  label: 'Date',
                                  value: dateText,
                                  scheme: scheme,
                                ),
                              if (timeRange != null && timeRange.trim().isNotEmpty) ...[
                                if (dateText != null) const SizedBox(height: 10),
                                _ScheduleFact(
                                  icon: IconsaxPlusLinear.clock,
                                  label: 'Time',
                                  value: timeRange.trim(),
                                  scheme: scheme,
                                ),
                              ],
                              if (endsFormatted != null) ...[
                                const SizedBox(height: 10),
                                _ScheduleFact(
                                  icon: IconsaxPlusLinear.calendar_tick,
                                  label: 'Ends',
                                  value: endsFormatted,
                                  scheme: scheme,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InvitationBanner extends StatelessWidget {
  const _InvitationBanner({required this.scheme});

  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(UiConstants.radiusLarge),
        border: Border.all(color: scheme.secondary.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          Icon(IconsaxPlusLinear.info_circle, size: 20, color: scheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: CommonText.regular(
              'This job is waiting for your response.',
              size: 13,
              color: scheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckInWindowBanner extends StatelessWidget {
  const _CheckInWindowBanner({required this.controller, required this.scheme});

  final CleanerJobDetailController controller;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final start = controller.jobStartDateTime;
    final current = controller.now.value;

    String message = 'Check-in is available 15 minutes before to 30 minutes after job start time.';
    if (start != null) {
      final windowStart = start.subtract(const Duration(minutes: 15));
      final windowEnd = start.add(const Duration(minutes: 30));
      final timeStr = CcsDateTimeX.convertTime(controller.job.value?.startTime ?? '');
      if (current.isBefore(windowStart)) {
        message = 'Check-in will be enabled 15 minutes before job start time${timeStr.isNotEmpty ? ' ($timeStr)' : ''}.';
      } else if (current.isAfter(windowEnd)) {
        message = 'Check-in window has ended (available up to 30 minutes after start time).';
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(UiConstants.radiusLarge),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(IconsaxPlusLinear.clock, size: 20, color: scheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: CommonText.regular(
              message,
              size: 13,
              color: scheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _TraineeProgressBlock extends StatelessWidget {
  const _TraineeProgressBlock({required this.job, required this.scheme});

  final StaffJobDetails job;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final completed = job.traineeCompletedSessions?.toInt() ?? 0;
    final required = job.traineeRequiredSessions?.toInt() ?? 0;
    final remaining = (required - completed).clamp(0, required);
    final progress = required <= 0 ? 0.0 : (completed / required).clamp(0.0, 1.0);
    final met = required > 0 && completed >= required;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(UiConstants.radiusDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(IconsaxPlusLinear.book_1, size: 16, color: scheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: CommonText.regular(
                  met ? 'Training requirement met' : '$remaining more session${remaining == 1 ? '' : 's'} to complete training',
                  size: 12,
                  color: scheme.onSurfaceVariant,
                ),
              ),
              CommonText.semiBold(
                '$completed / $required',
                size: 13,
                color: scheme.primary,
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: scheme.secondaryContainer.withValues(alpha: 0.45),
              color: scheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({
    required this.semanticLabel,
    required this.icon,
    required this.title,
    required this.scheme,
    required this.child,
  });

  final String semanticLabel;
  final IconData icon;
  final String title;
  final ColorScheme scheme;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: semanticLabel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10, left: 2),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(UiConstants.radiusMedium),
                  ),
                  child: Icon(icon, size: 15, color: scheme.primary),
                ),
                const SizedBox(width: 10),
                CommonText.semiBold(title, size: 15, color: scheme.onSurface),
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _ClientRow extends StatelessWidget {
  const _ClientRow({
    required this.name,
    required this.scheme,
    required this.canChat,
    required this.onChat,
    this.imageUrl,
  });

  final String name;
  final String? imageUrl;
  final ColorScheme scheme;
  final bool canChat;
  final VoidCallback onChat;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppAvatar(imageUrl: imageUrl, name: name, radius: 12),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonText.semiBold(name, size: 16, color: scheme.onSurface, maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              CommonText.regular('Client', size: 12, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
        if (canChat)
          Material(
            color: scheme.primaryContainer.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(UiConstants.radiusDefault),
            child: InkWell(
              onTap: onChat,
              borderRadius: BorderRadius.circular(UiConstants.radiusDefault),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(IconsaxPlusLinear.message_text, size: 16, color: scheme.primary),
                    const SizedBox(width: 6),
                    CommonText.semiBold('Chat', size: 13, color: scheme.primary),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _AccessRow extends StatelessWidget {
  const _AccessRow({required this.access, required this.scheme});

  final String access;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(UiConstants.radiusDefault),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(IconsaxPlusLinear.key, size: 18, color: scheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText.regular('Access', size: 12, color: scheme.onSurfaceVariant),
                const SizedBox(height: 2),
                CommonText.medium(access, size: 14, color: scheme.onSurface),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotesCard extends StatelessWidget {
  const _NotesCard({required this.notes, required this.scheme});

  final String notes;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 3,
            height: 36,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: scheme.secondary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: CommonText.regular(notes, size: 14, color: scheme.onSurface),
          ),
        ],
      ).paddingAll(UiConstants.defaultPadding),
    );
  }
}

class _AttendanceCard extends StatelessWidget {
  const _AttendanceCard({required this.cleaner, required this.scheme});

  final JobCleaners? cleaner;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    String? checkInTimeRange;
    if (cleaner?.checkInTime != null && cleaner?.checkOutTime != null) {
      checkInTimeRange = '${CcsDateTimeX.convertTime(cleaner?.checkInTime ?? '')} – ${CcsDateTimeX.convertTime(cleaner?.checkOutTime ?? '')}';
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: scheme.tertiaryContainer.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(UiConstants.radiusDefault),
            ),
            child: Row(
              children: [
                Icon(IconsaxPlusLinear.tick_circle, size: 24, color: scheme.tertiary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonText.semiBold('Check-in and check-out complete', size: 14, color: scheme.onSurface),
                      const SizedBox(height: 2),
                      CommonText.regular('No further action needed for this job.', size: 12, color: scheme.onSurfaceVariant),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (cleaner?.checkInDate != null) ...[
            const SizedBox(height: 14),
            _ScheduleFact(
              icon: IconsaxPlusLinear.login,
              label: 'Check-in',
              value: CcsDateUtils.fullDate(DateTime.parse(cleaner!.checkInDate!)),
              scheme: scheme,
            ),
          ],
          if (cleaner?.checkOutDate != null) ...[
            const SizedBox(height: 10),
            _ScheduleFact(
              icon: IconsaxPlusLinear.logout,
              label: 'Check-out',
              value: CcsDateUtils.fullDate(DateTime.parse(cleaner!.checkOutDate!)),
              scheme: scheme,
            ),
          ],
          if (checkInTimeRange != null && checkInTimeRange.isNotEmpty) ...[
            const SizedBox(height: 10),
            _ScheduleFact(
              icon: IconsaxPlusLinear.clock,
              label: 'Hours',
              value: checkInTimeRange,
              scheme: scheme,
            ),
          ],
        ],
      ).paddingAll(UiConstants.defaultPadding),
    );
  }
}

class _ScheduleFact extends StatelessWidget {
  const _ScheduleFact({
    required this.icon,
    required this.label,
    required this.value,
    required this.scheme,
  });

  final IconData icon;
  final String label;
  final String value;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: scheme.primary),
        const SizedBox(width: 10),
        SizedBox(
          width: 78,
          child: CommonText.regular(label, size: 13, color: scheme.onSurfaceVariant),
        ),
        Expanded(
          child: CommonText.medium(value, size: 14, color: scheme.onSurface),
        ),
      ],
    );
  }
}

class _FactChip extends StatelessWidget {
  const _FactChip({
    required this.icon,
    required this.label,
    required this.scheme,
  });

  final IconData icon;
  final String label;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(UiConstants.radiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: scheme.onSurfaceVariant),
          const SizedBox(width: 6),
          CommonText.medium(label, size: 12, color: scheme.onSurfaceVariant),
        ],
      ),
    );
  }
}

List<(IconData, String)> _propertyFacts(StaffJobDetails j) {
  final facts = <(IconData, String)>[];
  final p = j.property;
  final beds = p?.bedrooms;
  final baths = p?.bathrooms;
  final living = p?.livingRooms;
  if (beds != null && beds > 0) {
    facts.add((IconsaxPlusLinear.home_2, beds == 1 ? '1 bed' : '$beds beds'));
  }
  if (baths != null && baths > 0) {
    facts.add((IconsaxPlusLinear.drop, baths == 1 ? '1 bath' : '$baths baths'));
  }
  if (living != null && living > 0) {
    facts.add((IconsaxPlusLinear.building, living == 1 ? '1 living' : '$living living'));
  }
  if (p?.animalProperty != null) {
    facts.add((
      IconsaxPlusLinear.pet,
      p!.animalProperty == '1' ? 'Animals on property' : 'No animals',
    ));
  }
  final n = j.numberOfCleaners ?? 0;
  facts.add((IconsaxPlusLinear.profile_2user, n == 1 ? '1 cleaner' : '$n cleaners'));
  return facts;
}

String? _accessText(StaffJobDetails j) {
  final access = j.accessToProperty ?? j.property?.accessToProperty;
  if (access == null || access.trim().isEmpty) return null;
  return access.trim();
}

bool _isTrainee(StaffJobDetails j) {
  final type = j.myCleanerType?.trim().toLowerCase() ?? '';
  final label = j.myCleanerTypeLabel?.trim().toLowerCase() ?? '';
  return type == 'trainee' || label == 'trainee';
}

bool _showTraineeProgress(StaffJobDetails j) {
  if (!_isTrainee(j)) return false;
  return j.traineeCompletedSessions != null || j.traineeRequiredSessions != null;
}

bool _staffHasScheduleDate(StaffJobDetails j) {
  final start = j.jobStartDate?.toString().trim() ?? '';
  final d = j.date?.trim() ?? '';
  return start.isNotEmpty || d.isNotEmpty;
}

String _staffScheduleDateText(StaffJobDetails j) {
  final raw = (j.jobStartDate != null && j.jobStartDate.toString().trim().isNotEmpty) ? j.jobStartDate.toString() : (j.date ?? '');
  try {
    return CcsDateUtils.fullDate(DateTime.parse(raw));
  } catch (_) {
    return raw;
  }
}

String _staffParseEndDate(dynamic jobEndDate) {
  final raw = jobEndDate.toString();
  try {
    return CcsDateUtils.fullDate(DateTime.parse(raw));
  } catch (_) {
    return raw;
  }
}
