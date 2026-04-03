import 'package:ccs_app/app/model/client_job.dart';
import 'package:ccs_app/app/network/response/get_staff_job_details_response.dart';
import 'package:ccs_app/app/services/pref.dart';
import 'package:ccs_app/app/widget/job/job_detail_shared.dart';
import 'package:ccs_app/app/widget/layout/app_scaffold.dart';
import 'package:ccs_app/app/widget/layout/bottom_action_bar.dart';
import 'package:ccs_app/export.dart';

import 'cleaner_job_detail_controller.dart';

/// Cleaner job detail: aligned section layout with client job detail.
class CleanerJobDetailView extends GetView<CleanerJobDetailController> {
  const CleanerJobDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Obx(() {
      final j = controller.job.value;
      final loading = controller.isFetching.value;
      final err = controller.fetchError.value;

      // 'Accepted','Rejected'
      var cleanerStatus = j?.cleanerJobStatus;
      var cleaner = ((j?.jobCleaners?.firstWhereOrNull((item) => item.userId.toString() == Prefs().userId)));

      var status = cleanerStatus ?? (j?.status ?? "N/A");
      if (j?.status == Constants.jobFinished) {
        status = j?.status ?? status;
      }
      return AppScaffold(
        appBar: Header(
          title: j?.cleaningType?.name ?? (loading ? '' : 'Job details'),
          headerLogoIcon: false,
          hasBackIcon: true,
          titleCentered: false,
          actions: const [],
        ),
        backgroundColor: scheme.surface,
        body: SwipeRefresh(
          onRefresh: () async {
            await controller.fetchJobDetails(isLoaderShown: false);
          },
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: _cleanerBody(
                    context: context,
                    controller: controller,
                    scheme: scheme,
                    j: j,
                    loading: loading,
                    err: err,
                    cleanerStatus: status,
                    cleaner: cleaner,
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Obx(() {
          return controller.bottomBarState != 0
              ? SingleActionBottomBar(
                  label: controller.bottomBarLabel,
                  onPressed: controller.bottomBarOnPressed ?? () {},
                  buttonType: controller.bottomBarButtonType,
                )
              : const SizedBox.shrink();
        }),
      );
    });
  }
}

Widget _cleanerBody({
  required BuildContext context,
  required CleanerJobDetailController controller,
  required ColorScheme scheme,
  required StaffJobDetails? j,
  required bool loading,
  required String? err,
  required String? cleanerStatus,
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

  final p = j.property;
  final streetCity = [p?.address, p?.city].whereType<String>().where((s) => s.trim().isNotEmpty).join(', ');
  final postcode = p?.postalCode?.trim();
  final addressText = [
    if (streetCity.isNotEmpty) streetCity,
    if (postcode != null && postcode.isNotEmpty) postcode,
  ].join(', ');
  final typeLine = [p?.propertyType, p?.subType]
      .whereType<String>()
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .join(' · ');
  final canChat = j.user?.id != null;

  return SingleChildScrollView(
    padding: UiConstants.padding,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        JobDetailSection(
          semanticLabel: 'Property and client',
          emoji: '🏠',
          title: 'Property & client',
          scheme: scheme,
          child: AppCard(
            child: JobPropertyBlock(
              clientName: j.user?.name,
              propertyName: p?.propertyName ?? 'N/A',
              typeLine: typeLine.isEmpty ? null : typeLine,
              addressText: addressText.isEmpty ? null : addressText,
              metaLine: _cleanerPropertyMetaLine(j),
              paymentLine: (j.jobType != null && j.jobType!.trim().isNotEmpty) ? 'Payment: ${j.jobType!.capitalizeFirst}' : null,
              scheme: scheme,
            ).paddingAll(UiConstants.defaultPadding),
          ),
        ),
        const SizedBox(height: 20),
        JobDetailSection(
          semanticLabel: 'Status and schedule',
          emoji: '📅',
          title: 'Status & schedule',
          scheme: scheme,
          child: AppCard(
            child: _CleanerStatusScheduleBody(
              controller: c,
              j: j,
              scheme: scheme,
              cleanerStatus: cleanerStatus,
              cleaner: cleaner,
            ).paddingAll(UiConstants.defaultPadding),
          ),
        ),
        const SizedBox(height: 20),
        JobDetailSection(
          semanticLabel: 'Preferences and equipment',
          emoji: '🧰',
          title: 'Preferences & equipment',
          scheme: scheme,
          child: AppCard(
            child: JobPreferencesBlock(
              scheme: scheme,
              staffPreference: j.staffPreference ?? j.property?.staffPreference,
              equipmentChips: buildJobEquipmentChips(
                scheme: scheme,
                hoover: j.hoover ?? j.property?.hoover,
                provideCleaningProducts: j.property?.provideCleaningProducts ?? j.provideCleaningProducts,
                provideWashingMachine: j.property?.provideWashingMachine ?? j.provideWashingMachine,
                provideDryer: j.property?.provideDryer ?? j.provideDryer,
              ),
            ).paddingAll(UiConstants.defaultPadding),
          ),
        ),
        if (j.additionalDetails != null && j.additionalDetails.toString().trim().isNotEmpty) ...[
          const SizedBox(height: 20),
          JobDetailSection(
            semanticLabel: 'Additional notes',
            emoji: '📝',
            title: 'Additional notes',
            scheme: scheme,
            child: AppCard(
              child: CommonText.regular(
                j.additionalDetails.toString().trim(),
                size: 14,
                color: scheme.onSurfaceVariant,
              ).paddingAll(UiConstants.defaultPadding),
            ),
          ),
        ],
        if (j.jobCleaners != null && j.jobCleaners!.isNotEmpty) ...[
          const SizedBox(height: 20),
          JobDetailSection(
            semanticLabel: 'Cleaners',
            emoji: '👷',
            title: 'Cleaners',
            scheme: scheme,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: (j.cleaners ?? []).map((cl) {
                final item = j.jobCleaners?.firstWhereOrNull((e) => e.userId.toString() == cl.id.toString());
                final cardCleaner = ClientJobCleaner(
                  id: cl.id.toString(),
                  name: cl.name ?? 'N/A',
                  status: cl.status ?? 'N/A',
                  isReview: item?.isReviewed ?? false,
                );
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Semantics(
                    label: 'Cleaner ${cardCleaner.name}',
                    child: CleanerCard(
                      cleaner: cardCleaner,
                      onShare: () => c.onShareCleanerProfile(cardCleaner),
                      scheme: scheme,
                      onReview: () => {},
                      onTap: () => {},
                      showActions: false,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
        Semantics(
          label: 'Job chat',
          container: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Divider(height: 32, thickness: 1, color: scheme.outline.withValues(alpha: 0.12)),
              AppButton(
                label: 'Chat',
                type: ButtonType.tonal,
                onPressed: canChat ? c.onContactClient : null,
              ),
              if (!canChat)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: CommonText.regular(
                    'Chat is available when the client is linked to this job.',
                    size: 12,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ).marginSymmetric(vertical: 16),
      ],
    ),
  );
}

String _cleanerPropertyMetaLine(StaffJobDetails j) {
  final parts = <String>[];
  final access = j.accessToProperty ?? j.property?.accessToProperty;
  if (access != null && access.trim().isNotEmpty) {
    parts.add(access.trim());
  }
  if (j.property?.animalProperty != null) {
    parts.add(j.property!.animalProperty == '1' ? 'Animals on property' : 'No animals');
  }
  final n = j.numberOfCleaners ?? 0;
  parts.add(n == 1 ? '1 cleaner' : '$n cleaners');
  return parts.join(' • ');
}

class _CleanerStatusScheduleBody extends StatelessWidget {
  const _CleanerStatusScheduleBody({
    required this.controller,
    required this.j,
    required this.scheme,
    required this.cleanerStatus,
    required this.cleaner,
  });

  final CleanerJobDetailController controller;
  final StaffJobDetails j;
  final ColorScheme scheme;
  final String? cleanerStatus;
  final JobCleaners? cleaner;

  @override
  Widget build(BuildContext context) {
    final ctrl = controller;
    final statusLabel = cleanerStatus ?? j.status ?? 'N/A';
    final hasDate = _staffHasScheduleDate(j);

    String? timeRange;
    if (j.startTime != null && j.endTime != null) {
      timeRange =
          '${CcsDateTimeX.convertTime(j.startTime ?? '')} – ${CcsDateTimeX.convertTime(j.endTime ?? '')}';
    }
    String? endsFormatted;
    if (j.jobEndDate != null && j.jobEndDate.toString().trim().isNotEmpty) {
      endsFormatted = _staffParseEndDate(j.jobEndDate);
    }
    final scheduleSummary = jobScheduleSummaryLine(
      dateFormatted: hasDate ? _staffScheduleDateText(j) : null,
      timeRange: timeRange,
      endsFormatted: endsFormatted,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            InfoChip(
              label: statusLabel,
              backgroundColor: getBgColor(statusLabel, scheme),
              foregroundColor: getFgColor(statusLabel, scheme),
            ),
            InfoChip(
              label: hasDate ? 'Scheduled' : 'Not scheduled',
              backgroundColor: hasDate ? scheme.primaryContainer : scheme.surfaceContainerHighest,
              foregroundColor: hasDate ? scheme.primary : scheme.onSurfaceVariant,
            ),
            if (j.scheduler?.frequency != null && j.scheduler!.frequency!.trim().isNotEmpty)
              InfoChip(
                label: j.scheduler!.frequency!.capitalizeFirst ?? '',
                backgroundColor: scheme.tertiaryContainer,
                foregroundColor: scheme.tertiary,
              ),
          ],
        ),
        if (scheduleSummary.isNotEmpty) ...[
          const SizedBox(height: 10),
          CommonText.regular(scheduleSummary, size: 14, color: scheme.onSurface),
        ],
        if ((j.status == 'Pending' || j.status?.toLowerCase() == 'pending') &&
            cleanerStatus?.toLowerCase() != 'accepted' &&
            cleanerStatus?.toLowerCase() != 'rejected') ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Accept',
                  onPressed: ctrl.onAccept,
                  type: ButtonType.primary,
                  icon: IconsaxPlusLinear.tick_circle,
                  btnVerticalPadding: 8,
                  btnHorizontalPadding: 12,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  label: 'Decline',
                  onPressed: ctrl.onDecline,
                  type: ButtonType.outline,
                  icon: IconsaxPlusLinear.close_circle,
                  bgColor: Colors.transparent,
                  txtClr: scheme.error,
                  borderClr: scheme.error,
                  btnVerticalPadding: 8,
                  btnHorizontalPadding: 12,
                ),
              ),
            ],
          ),
        ],
        if (cleanerStatus?.toLowerCase() == 'completed' || cleanerStatus?.toLowerCase() == Constants.jobFinished.toLowerCase()) ...[
          const SizedBox(height: 12),
          if (cleaner?.checkInDate != null)
            LabelValueRow(
              label: 'Check-In Date',
              value: CcsDateUtils.fullDate(DateTime.parse(cleaner!.checkInDate!)),
              scheme: scheme,
            ),
          if (cleaner?.checkOutDate != null)
            LabelValueRow(
              label: 'Check-Out Date',
              value: CcsDateUtils.fullDate(DateTime.parse(cleaner!.checkOutDate!)),
              scheme: scheme,
            ),
          LabelValueRow(
            label: 'Check-In/Check-Out Time',
            value: '${cleaner?.checkInTime ?? 'N/A'} – ${cleaner?.checkOutTime ?? 'N/A'}',
            scheme: scheme,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: scheme.primary.withValues(alpha: 0.3), width: 1),
            ),
            child: Row(
              children: [
                Icon(IconsaxPlusLinear.tick_circle, size: 28, color: scheme.primary),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonText.semiBold('Check-in & check-out completed', size: 14, color: scheme.onSurface),
                      const SizedBox(height: 4),
                      CommonText.regular('No further action needed for this job.', size: 12, color: scheme.onSurfaceVariant),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

bool _staffHasScheduleDate(StaffJobDetails j) {
  final start = j.jobStartDate?.toString().trim() ?? '';
  final d = j.date?.trim() ?? '';
  return start.isNotEmpty || d.isNotEmpty;
}

String _staffScheduleDateText(StaffJobDetails j) {
  final raw = (j.jobStartDate != null && j.jobStartDate.toString().trim().isNotEmpty)
      ? j.jobStartDate.toString()
      : (j.date ?? '');
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
