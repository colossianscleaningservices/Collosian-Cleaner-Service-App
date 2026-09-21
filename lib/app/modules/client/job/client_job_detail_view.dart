import 'package:ccs_app/app/model/chat_message.dart';
import 'package:ccs_app/app/network/response/get_client_job_details_response.dart';
import 'package:ccs_app/app/services/pref.dart';
import 'package:ccs_app/app/widget/job/job_detail_shared.dart';
import 'package:ccs_app/app/widget/layout/app_scaffold.dart';
import 'package:ccs_app/export.dart';

import '../../../model/client_job.dart';
import 'client_job_detail_controller.dart';

enum _JobMenuAction { edit, delete }

/// Client job detail: status-first ticket layout with property, team, and job actions.
class ClientJobDetailView extends GetView<ClientJobDetailController> {
  const ClientJobDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final scheme = context.colorScheme;

    return Obx(() {
      final j = c.job.value;
      final loading = c.isFetching.value;
      final err = c.fetchError.value;
      final hasCleaners = j?.cleaners != null && j!.cleaners!.isNotEmpty;

      return AppScaffold(
        appBar: Header(
          title: j?.cleaningType?.name ?? (loading ? '' : 'Job details'),
          headerLogoIcon: false,
          hasBackIcon: true,
          titleCentered: false,
          actions: [
            if (hasCleaners)
              IconButton(
                tooltip: 'Chat',
                onPressed: () => _openJobChat(c),
                icon: Icon(IconsaxPlusLinear.message_text, size: 22, color: scheme.primary),
              ),
            if (j != null && _shouldShowJobMenu(j))
              PopupMenuButton<_JobMenuAction>(
                tooltip: 'More options',
                color: context.colorScheme.onPrimary,
                icon: Icon(IconsaxPlusLinear.more, size: 24, color: scheme.onSurface),
                onSelected: (action) {
                  switch (action) {
                    case _JobMenuAction.edit:
                      c.onEdit();
                      break;
                    case _JobMenuAction.delete:
                      c.confirmDeleteJob(context);
                      break;
                  }
                },
                itemBuilder: (context) {
                  return [
                    PopupMenuItem(
                      value: _JobMenuAction.edit,
                      child: Row(
                        children: [
                          Icon(IconsaxPlusLinear.edit_2, size: 18, color: scheme.onSurfaceVariant),
                          const SizedBox(width: 8),
                          CommonText.regular('Edit job', size: 14, color: scheme.onSurface),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: _JobMenuAction.delete,
                      child: Row(
                        children: [
                          Icon(IconsaxPlusLinear.trash, size: 18, color: scheme.error),
                          const SizedBox(width: 8),
                          CommonText.regular('Delete job', size: 14, color: scheme.onSurface),
                        ],
                      ),
                    ),
                  ];
                },
              ),
          ],
        ),
        backgroundColor: scheme.surface,
        body: SwipeRefresh(
          onRefresh: () async {
            await controller.fetchJobDetails(isLoaderShown: false);
          },
          child: SafeArea(
            child: _bodyForState(
              context: context,
              c: c,
              j: j,
              loading: loading,
              err: err,
              scheme: scheme,
            ),
          ),
        ),
      );
    });
  }
}

Widget _bodyForState({
  required BuildContext context,
  required ClientJobDetailController c,
  required ClientJobDetails? j,
  required bool loading,
  required String? err,
  required ColorScheme scheme,
}) {
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

  return _ClientJobContent(controller: c, job: j, scheme: scheme);
}

class _ClientJobContent extends StatelessWidget {
  const _ClientJobContent({
    required this.controller,
    required this.job,
    required this.scheme,
  });

  final ClientJobDetailController controller;
  final ClientJobDetails job;
  final ColorScheme scheme;

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
    final notes = job.additionalDetails?.trim() ?? '';
    final hasNotes = notes.isNotEmpty;
    final hasCleaners = job.cleaners != null && job.cleaners!.isNotEmpty;
    final assignedCount = job.jobCleaners?.length ?? job.cleaners?.length ?? 0;
    final neededCount = job.numberOfCleaners ?? 0;
    final teamTitle = neededCount > 0 ? 'Team · $assignedCount of ${neededCount.toInt()}' : 'Team';
    final invoice = job.invoice;
    final actions = _manageActions(context, job, controller, scheme);
    final showExtendRequested = job.isRequested == true && job.status != 'Finished' && job.status != 'Pending';
    final isPaused = job.scheduler?.active == false;
    final scheduled = job.jobSchedule ?? false;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: UiConstants.padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _HeroOverviewCard(job: job, scheme: scheme),
          if (showExtendRequested) ...[
            const SizedBox(height: 12),
            _InfoBanner(
              icon: IconsaxPlusLinear.clock_1,
              message: 'A time extension has been requested for this job.',
              scheme: scheme,
              tone: _BannerTone.secondary,
            ),
          ],
          if (scheduled && isPaused && !_isJobClosed(job.status)) ...[
            const SizedBox(height: 12),
            _InfoBanner(
              icon: IconsaxPlusLinear.pause,
              message: 'This recurring schedule is paused.',
              scheme: scheme,
              tone: _BannerTone.error,
            ),
          ],
          if (actions.isNotEmpty) ...[
            const SizedBox(height: 20),
            _DetailSection(
              semanticLabel: 'Manage job',
              icon: IconsaxPlusLinear.setting_2,
              title: 'Manage job',
              scheme: scheme,
              child: AppCard(
                child: Column(
                  children: [
                    for (var i = 0; i < actions.length; i++) ...[
                      if (i > 0) Divider(height: 1, color: scheme.outline.withValues(alpha: 0.12)),
                      actions[i],
                    ],
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          _DetailSection(
            semanticLabel: 'Property',
            icon: IconsaxPlusLinear.home_2,
            title: 'Property',
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
                ],
              ).paddingAll(UiConstants.defaultPadding),
            ),
          ),
          if (job.hasEndOfTenancyDetails) ...[
            const SizedBox(height: 20),
            _DetailSection(
              semanticLabel: 'End of Tenancy',
              icon: IconsaxPlusLinear.key,
              title: 'End of tenancy',
              scheme: scheme,
              child: AppCard(
                child: _EndOfTenancyDetailBlock(j: job, scheme: scheme).paddingAll(UiConstants.defaultPadding),
              ),
            ),
          ],
          const SizedBox(height: 20),
          _DetailSection(
            semanticLabel: 'Cleaners',
            icon: IconsaxPlusLinear.profile_2user,
            title: teamTitle,
            scheme: scheme,
            child: hasCleaners
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ...job.cleaners!.map((cl) {
                        final cleaner = job.jobCleaners?.firstWhereOrNull((element) => element.userId == cl.id);
                        final item = ClientJobCleaner(
                          id: cl.id.toString(),
                          avatarUrl: cl.imageUrl,
                          name: cl.name ?? '',
                          status: cleaner?.status ?? 'N/A',
                        );
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Semantics(
                            label: 'Cleaner ${item.name}',
                            child: CleanerCard(
                              cleaner: item,
                              isReview: cleaner?.isReviewed == true ? false : true,
                              scheme: scheme,
                              checkInText: _staffCheckDisplay(cleaner?.checkInDate, cleaner?.checkInTime),
                              checkOutText: _staffCheckDisplay(cleaner?.checkOutDate, cleaner?.checkOutTime),
                              onReview: () => controller.onReviewCleanerProfile(item),
                              onTap: () => Get.toNamed(Routes.STAFF_DETAILS, arguments: {'id': item.id.toInt(), 'type': 'staffDetail'}),
                            ),
                          ),
                        );
                      }),
                      _ChatTeamCard(onTap: () => _openJobChat(controller), scheme: scheme),
                    ],
                  )
                : _EmptyTeamCard(neededCount: neededCount, scheme: scheme),
          ),
          const SizedBox(height: 20),
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
                  provideCleaningProducts: job.provideCleaningProducts,
                  provideWashingMachine: job.provideWashingMachine,
                  provideDryer: job.provideDryer,
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
          if (invoice != null && invoice.pdfUrl != null) ...[
            const SizedBox(height: 20),
            _DetailSection(
              semanticLabel: 'Invoice',
              icon: IconsaxPlusLinear.receipt_1,
              title: 'Invoice',
              scheme: scheme,
              child: _InvoiceCard(
                invoice: invoice,
                scheme: scheme,
                onView: () => controller.onViewFile(invoice.pdfUrl ?? ''),
                onDownload: () => controller.downloadFile(invoice.pdfUrl ?? '', invoice.invoiceNumber),
              ),
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

  final ClientJobDetails job;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final statusLabel = JobStatusX.displayLabel(job.status);
    final statusForColor = job.status ?? statusLabel;
    final scheduled = job.jobSchedule ?? false;
    final isPaused = job.scheduler?.active == false;
    final jobClosed = _isJobClosed(job.status);
    final timeRange = CcsDateUtils.formatJobTimeRange(job.startTime, job.endTime);
    String? endsFormatted;
    if (job.jobEndDate != null && job.jobEndDate!.trim().isNotEmpty) {
      try {
        endsFormatted = CcsDateUtils.fullDate(DateTime.parse(job.jobEndDate!));
      } catch (_) {
        endsFormatted = job.jobEndDate;
      }
    }
    final dateText = _hasScheduleDate(job) ? _scheduleDateText(job) : null;
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
                              label: scheduled ? 'Scheduled' : 'Not scheduled',
                              backgroundColor: scheduled ? scheme.primaryContainer : scheme.surfaceContainerHighest,
                              foregroundColor: scheduled ? scheme.primary : scheme.onSurfaceVariant,
                            ),
                          if (scheduled && isPaused && !jobClosed)
                            InfoChip(
                              label: 'Paused',
                              backgroundColor: scheme.errorContainer,
                              foregroundColor: scheme.onErrorContainer,
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
                Expanded(
                  child: CommonText.semiBold(title, size: 15, color: scheme.onSurface),
                ),
              ],
            ),
          ),
          child,
        ],
      ),
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

enum _BannerTone { secondary, error }

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({
    required this.icon,
    required this.message,
    required this.scheme,
    required this.tone,
  });

  final IconData icon;
  final String message;
  final ColorScheme scheme;
  final _BannerTone tone;

  @override
  Widget build(BuildContext context) {
    final bg = tone == _BannerTone.error
        ? scheme.errorContainer.withValues(alpha: 0.55)
        : scheme.secondaryContainer.withValues(alpha: 0.55);
    final border = tone == _BannerTone.error ? scheme.error.withValues(alpha: 0.22) : scheme.secondary.withValues(alpha: 0.22);
    final iconColor = tone == _BannerTone.error ? scheme.error : scheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(UiConstants.radiusLarge),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: 10),
          Expanded(
            child: CommonText.regular(message, size: 13, color: scheme.onSurface),
          ),
        ],
      ),
    );
  }
}

class _ManageActionTile extends StatelessWidget {
  const _ManageActionTile({
    required this.icon,
    required this.label,
    required this.scheme,
    required this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final ColorScheme scheme;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final color = destructive ? scheme.error : scheme.primary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: (destructive ? scheme.errorContainer : scheme.primaryContainer).withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(UiConstants.radiusDefault),
                ),
                child: Icon(icon, size: 17, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CommonText.medium(label, size: 14, color: destructive ? scheme.error : scheme.onSurface),
              ),
              Icon(IconsaxPlusLinear.arrow_right_3, size: 16, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatTeamCard extends StatelessWidget {
  const _ChatTeamCard({required this.onTap, required this.scheme});

  final VoidCallback onTap;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(UiConstants.radiusDefault),
            ),
            child: Icon(IconsaxPlusLinear.message_text, size: 20, color: scheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText.semiBold('Message team', size: 14, color: scheme.onSurface),
                const SizedBox(height: 2),
                CommonText.regular('Chat with assigned cleaners', size: 12, color: scheme.onSurfaceVariant),
              ],
            ),
          ),
          Icon(IconsaxPlusLinear.arrow_right_3, size: 16, color: scheme.onSurfaceVariant),
        ],
      ).paddingAll(UiConstants.defaultPadding),
    );
  }
}

class _EmptyTeamCard extends StatelessWidget {
  const _EmptyTeamCard({required this.neededCount, required this.scheme});

  final num neededCount;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final needed = neededCount == 1 ? '1 cleaner' : '${neededCount.toInt()} cleaners';
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(UiConstants.radiusDefault),
            ),
            child: Icon(IconsaxPlusLinear.profile_2user, size: 20, color: scheme.onSurfaceVariant),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText.semiBold('No one assigned yet', size: 14, color: scheme.onSurface),
                const SizedBox(height: 4),
                CommonText.regular(
                  neededCount > 0
                      ? 'This job needs $needed. Chat opens once someone is assigned.'
                      : 'Chat is available when at least one cleaner is assigned to this job.',
                  size: 13,
                  color: scheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ],
      ).paddingAll(UiConstants.defaultPadding),
    );
  }
}

class _InvoiceCard extends StatelessWidget {
  const _InvoiceCard({
    required this.invoice,
    required this.scheme,
    required this.onView,
    required this.onDownload,
  });

  final Invoice invoice;
  final ColorScheme scheme;
  final VoidCallback onView;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    final number = invoice.invoiceNumber?.trim();
    final status = invoice.status?.trim();

    return AppCard(
      onTap: onView,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(UiConstants.radiusDefault),
            ),
            child: Icon(IconsaxPlusLinear.receipt_1, size: 22, color: scheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText.semiBold(
                  (number != null && number.isNotEmpty) ? number : 'Invoice',
                  size: 15,
                  color: scheme.onSurface,
                ),
                if (status != null && status.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  InfoChip(
                    label: status.capitalizeFirst ?? status,
                    backgroundColor: getBgColor(status, scheme),
                    foregroundColor: getFgColor(status, scheme),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            tooltip: 'Download invoice',
            onPressed: onDownload,
            icon: Icon(IconsaxPlusLinear.arrow_down_2, size: 22, color: scheme.primary),
          ),
        ],
      ).paddingOnly(left: UiConstants.defaultPadding, top: 8, bottom: 8, right: 4),
    );
  }
}

class _EndOfTenancyDetailBlock extends StatelessWidget {
  const _EndOfTenancyDetailBlock({required this.j, required this.scheme});

  final ClientJobDetails j;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final listed = j.addOns ?? [];
    final custom = j.customAddOns ?? [];
    final bandName = j.endOfTenancyBand?.displayLabel.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (bandName != null && bandName.isNotEmpty) ...[
          _ScheduleFact(
            icon: IconsaxPlusLinear.ruler,
            label: 'Size',
            value: bandName,
            scheme: scheme,
          ),
          if (listed.isNotEmpty || custom.isNotEmpty) const SizedBox(height: 14),
        ],
        if (listed.isNotEmpty) ...[
          CommonText.semiBold('Optional extras', size: 13, color: scheme.onSurface).paddingOnly(bottom: 8),
          ...listed.map(
            (addon) => _EotExtraTile(
              title: addon.displayName,
              note: addon.note ?? addon.description,
              quantity: addon.quantity,
              scheme: scheme,
            ),
          ),
        ],
        if (custom.isNotEmpty) ...[
          CommonText.semiBold('Custom extras', size: 13, color: scheme.onSurface)
              .paddingOnly(top: listed.isNotEmpty ? 6 : 0, bottom: 8),
          ...custom.map(
            (addon) => _EotExtraTile(
              title: (addon.label ?? '').trim().isEmpty ? 'Extra' : addon.label!.trim(),
              note: addon.note,
              quantity: addon.quantity,
              scheme: scheme,
            ),
          ),
        ],
        if (listed.isEmpty && custom.isEmpty)
          CommonText.regular(
            'No extras added for this job.',
            size: 13,
            color: scheme.onSurfaceVariant,
          ),
      ],
    );
  }
}

class _EotExtraTile extends StatelessWidget {
  const _EotExtraTile({
    required this.title,
    required this.scheme,
    this.note,
    this.quantity,
  });

  final String title;
  final String? note;
  final num? quantity;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final qty = quantity?.toInt();
    final hasNote = note != null && note!.trim().isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(UiConstants.radiusDefault),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText.medium(title, size: 14, color: scheme.onSurface),
                if (hasNote) ...[
                  const SizedBox(height: 2),
                  CommonText.regular(note!.trim(), size: 13, color: scheme.onSurfaceVariant),
                ],
              ],
            ),
          ),
          if (qty != null && qty > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: scheme.primaryContainer.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(UiConstants.radiusSmall),
              ),
              child: CommonText.semiBold('×$qty', size: 12, color: scheme.primary),
            ),
          ],
        ],
      ),
    );
  }
}

List<_ManageActionTile> _manageActions(
  BuildContext context,
  ClientJobDetails j,
  ClientJobDetailController c,
  ColorScheme scheme,
) {
  final actions = <_ManageActionTile>[];

  final unscheduled = j.jobSchedule == false && j.status != 'Cancelled' && j.status != 'Finished';
  final scheduled = j.jobSchedule == true && j.status != 'Cancelled';
  final isPaused = j.scheduler?.active == false;

  if (unscheduled) {
    actions.add(_ManageActionTile(
      icon: IconsaxPlusLinear.calendar_1,
      label: 'Schedule job',
      scheme: scheme,
      onTap: c.onScheduleJob,
    ));
  }
  if (j.isRequested == false && j.status != 'Finished') {
    actions.add(_ManageActionTile(
      icon: IconsaxPlusLinear.clock_1,
      label: 'Request more time',
      scheme: scheme,
      onTap: () => c.openFilter(context),
    ));
  }
  if (scheduled && !isPaused) {
    actions.add(_ManageActionTile(
      icon: IconsaxPlusLinear.edit_2,
      label: 'Edit schedule',
      scheme: scheme,
      onTap: c.onEditSchedule,
    ));
    actions.add(_ManageActionTile(
      icon: IconsaxPlusLinear.pause,
      label: 'Pause schedule',
      scheme: scheme,
      onTap: c.onPauseSchedule,
    ));
  }
  if (scheduled && isPaused) {
    actions.add(_ManageActionTile(
      icon: IconsaxPlusLinear.play,
      label: 'Resume schedule',
      scheme: scheme,
      onTap: c.onResumeSchedule,
    ));
  }
  if (unscheduled || scheduled) {
    actions.add(_ManageActionTile(
      icon: IconsaxPlusLinear.close_circle,
      label: 'Cancel job',
      scheme: scheme,
      onTap: c.onCancelJob,
      destructive: true,
    ));
  }
  return actions;
}

void _openJobChat(ClientJobDetailController c) {
  final job = c.job.value;
  if (job == null || job.cleaners == null || job.cleaners!.isEmpty) return;

  DateTime parsedDate;
  try {
    parsedDate = DateTime.parse(job.date ?? '');
  } catch (_) {
    parsedDate = DateTime.now();
  }

  final chatJob = ChatJob(
    id: job.id.toString(),
    jobType: job.jobType,
    propertyOneLine: job.property?.propertyName,
    date: parsedDate.toIso8601String(),
    clientName: '',
  );
  final participants = <String, ChatParticipant>{};
  final userId = Prefs().userId;
  final userName = Prefs().userFullName;
  participants[userId] = ChatParticipant(id: userId, name: userName, role: RoleConstants.roleKeyClient);
  for (final cleaner in job.cleaners ?? []) {
    participants[cleaner.id.toString()] = ChatParticipant(
      id: cleaner.id.toString(),
      name: cleaner.name,
      role: RoleConstants.roleKeyCleaner,
    );
  }
  Get.toNamed(Routes.JOB_CHAT, arguments: {
    'type': ChatConstants.typeJob,
    'jobId': job.id.toString(),
    'job': chatJob,
    'participants': participants,
  });
}

List<(IconData, String)> _propertyFacts(ClientJobDetails j) {
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

String? _accessText(ClientJobDetails j) {
  final access = j.accessToProperty ?? j.property?.accessToProperty;
  if (access == null || access.trim().isEmpty) return null;
  return access.trim();
}

String? _staffCheckDisplay(dynamic date, String? time) {
  String? datePart;
  final rawDate = date?.toString().trim();
  if (rawDate != null && rawDate.isNotEmpty) {
    try {
      datePart = CcsDateUtils.fullDate(DateTime.parse(rawDate));
    } catch (_) {
      datePart = rawDate;
    }
  }

  String? timePart;
  final rawTime = time?.trim();
  if (rawTime != null && rawTime.isNotEmpty) {
    timePart = CcsDateTimeX.convertTime(rawTime);
  }

  if (datePart != null && timePart != null) return '$datePart · $timePart';
  return datePart ?? timePart;
}

bool _shouldShowJobMenu(ClientJobDetails j) {
  final status = j.status?.toLowerCase();
  if (status == 'finished') return false;
  return true;
}

bool _isJobClosed(String? status) => JobStatusX.isCancelled(status) || JobStatusX.isJobFinished(status);

bool _hasScheduleDate(ClientJobDetails j) {
  if (j.jobStartDate != null && j.jobStartDate!.trim().isNotEmpty) return true;
  if (j.date != null && j.date!.trim().isNotEmpty) return true;
  return false;
}

String _scheduleDateText(ClientJobDetails j) {
  final raw = (j.jobStartDate != null && j.jobStartDate!.trim().isNotEmpty) ? j.jobStartDate! : (j.date ?? '');
  try {
    return CcsDateUtils.fullDate(DateTime.parse(raw));
  } catch (_) {
    return raw;
  }
}
