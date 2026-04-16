import 'package:ccs_app/app/model/chat_message.dart';
import 'package:ccs_app/app/network/response/get_client_job_details_response.dart';
import 'package:ccs_app/app/services/pref.dart';
import 'package:ccs_app/app/widget/job/job_detail_shared.dart';
import 'package:ccs_app/app/widget/layout/app_scaffold.dart';
import 'package:ccs_app/export.dart';

import '../../../model/client_job.dart';
import 'client_job_detail_controller.dart';

enum _JobMenuAction { edit, delete }

/// Client job detail: status, schedule, property, preferences, cleaners.
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

      return AppScaffold(
        appBar: Header(
          title: j?.cleaningType?.name ?? (loading ? '' : 'Job details'),
          headerLogoIcon: false,
          hasBackIcon: true,
          titleCentered: false,
          actions: j != null && j.cleaners?.isEmpty == true
              ? [
                  PopupMenuButton<_JobMenuAction>(
                    tooltip: 'More options',
                    color: context.colorScheme.onPrimary,
                    icon: Icon(Icons.more_vert, size: 24, color: scheme.onSurface),
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
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: _JobMenuAction.edit,
                        child: Row(
                          children: [
                            Icon(IconsaxPlusLinear.edit_2, size: 18, color: scheme.onSurfaceVariant),
                            const SizedBox(width: 8),
                            const Text('Edit job'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: _JobMenuAction.delete,
                        child: Row(
                          children: [
                            Icon(IconsaxPlusLinear.trash, size: 18, color: scheme.error),
                            const SizedBox(width: 8),
                            const Text('Delete job'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ]
              : [],
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

  final p = j.property;
  final streetCity = [p?.address, p?.city].whereType<String>().where((s) => s.trim().isNotEmpty).join(', ');
  final postcode = p?.postalCode?.trim();
  final addressText = [
    if (streetCity.isNotEmpty) streetCity,
    if (postcode != null && postcode.isNotEmpty) postcode,
  ].join(', ');
  final typeLine = [p?.propertyType, p?.subType].whereType<String>().map((s) => s.trim()).where((s) => s.isNotEmpty).join(' · ');
  final hasCleaners = j.cleaners != null && j.cleaners!.isNotEmpty;

  return SingleChildScrollView(
    padding: UiConstants.padding,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        JobDetailSection(
          semanticLabel: 'Property',
          emoji: '🏠',
          title: 'Property',
          scheme: scheme,
          child: AppCard(
            child: JobPropertyBlock(
              propertyName: p?.propertyName ?? 'N/A',
              typeLine: typeLine.isEmpty ? null : typeLine,
              addressText: addressText.isEmpty ? null : addressText,
              metaLine: _propertyMetaLine(j),
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
            child: _StatusScheduleSection(j: j, scheme: scheme, c: c).paddingAll(UiConstants.defaultPadding),
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
                provideCleaningProducts: j.provideCleaningProducts,
                provideWashingMachine: j.provideWashingMachine,
                provideDryer: j.provideDryer,
              ),
            ).paddingAll(UiConstants.defaultPadding),
          ),
        ),
        const SizedBox(height: 20),
        if (j.additionalDetails != null && j.additionalDetails!.trim().isNotEmpty) ...[
          JobDetailSection(
            semanticLabel: 'Additional notes',
            emoji: '📝',
            title: 'Additional notes',
            scheme: scheme,
            child: AppCard(
              child: CommonText.regular(j.additionalDetails!.trim(), size: 14, color: scheme.onSurfaceVariant).paddingAll(UiConstants.defaultPadding),
            ),
          ),
          const SizedBox(height: 20),
        ],
        if (j.cleaners != null && j.cleaners!.isNotEmpty) ...[
          JobDetailSection(
            semanticLabel: 'Cleaners',
            emoji: '👷',
            title: c.cleanerHeading.value ?? 'Cleaners',
            scheme: scheme,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: j.cleaners!.map((cl) {
                final jobCleaners = j.jobCleaners;
                final cleaner = jobCleaners?.firstWhereOrNull((element) => element.userId == cl.id);

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
                      onShare: () => c.onShareCleanerProfile(item),
                      scheme: scheme,
                      onReview: () => c.onReviewCleanerProfile(item),
                      onTap: () => Get.toNamed(Routes.STAFF_DETAILS, arguments: {'id': item.id.toInt(), 'type': 'staffDetail'}),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
        ],
        if (j.invoice != null && j.invoice?.pdfUrl != null) ...[
          JobDetailSection(
            semanticLabel: 'Invoice',
            emoji: '📋',
            title: 'Invoice',
            scheme: scheme,
            child: AppCard(
              onTap: () => c.onViewFile(j.invoice?.pdfUrl ?? ''),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(IconsaxPlusLinear.note, size: 28, color: context.colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonText.semiBold(j.invoice?.invoiceNumber ??'invoice.pdf', size: 15, color: scheme.onSurface),
                        const SizedBox(height: 4),
                        CommonText.regular('Status:${j.invoice?.status ??''}', size: 13, color: scheme.onSurfaceVariant),
                      ],
                    ),
                  ),
                  InkWell(onTap: () {
                    c.downloadFile(j.invoice?.pdfUrl ?? '');

                  }, child: Icon(IconsaxPlusLinear.arrow_down_2, size: 28, color: context.colorScheme.primary)),
                ],
              ).paddingAll(UiConstants.defaultPadding),
            ),
          ),
          const SizedBox(height: 8),
        ],
        Semantics(
          label: 'Job chat',
          container: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Divider(height: 32, thickness: 1, color: scheme.outline.withValues(alpha: 0.12)),
              j?.jobCleaners?.isEmpty == true
                  ? SizedBox.shrink()
                  : AppButton(
                      label: 'Chat',
                      type: ButtonType.tonal,
                      onPressed: hasCleaners
                          ? () {
                              final job = c.job.value;
                              final chatJob = ChatJob(
                                id: job?.id.toString() ?? '',
                                jobType: job?.jobType,
                                propertyOneLine: job?.property?.propertyName,
                                date: DateTime.parse(job?.date ?? '').toIso8601String(),
                                clientName: '',
                              );
                              final participants = <String, ChatParticipant>{};
                              final userId = Prefs().userId;
                              final userName = Prefs().userFullName;
                              participants[userId] = ChatParticipant(id: userId, name: userName, role: RoleConstants.roleKeyClient);
                              for (final cleaner in job?.cleaners ?? []) {
                                participants[cleaner.id.toString()] =
                                    ChatParticipant(id: cleaner.id.toString(), name: cleaner.name, role: RoleConstants.roleKeyCleaner);
                              }
                              Get.toNamed(Routes.JOB_CHAT, arguments: {
                                'type': ChatConstants.typeJob,
                                'jobId': job?.id.toString(),
                                'job': chatJob,
                                'participants': participants,
                              });
                            }
                          : null,
                    ),
              if (!hasCleaners)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: CommonText.regular(
                    'Chat is available when at least one cleaner is assigned to this job.',
                    size: 12,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
      ],
    ),
  );
}

String _propertyMetaLine(ClientJobDetails j) {
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

class _StatusScheduleSection extends StatelessWidget {
  const _StatusScheduleSection({required this.j, required this.scheme, required this.c});

  final ClientJobDetails j;
  final ColorScheme scheme;
  final ClientJobDetailController c;

  @override
  Widget build(BuildContext context) {
    final scheduled = j.jobSchedule ?? false;
    final statusLabel = j.status?.capitalizeFirst ?? 'N/A';

    String? timeRange;
    if (j.startTime != null && j.endTime != null) {
      timeRange = '${CcsDateTimeX.convertTime(j.startTime ?? '')} – ${CcsDateTimeX.convertTime(j.endTime ?? '')}';
    }
    String? endsFormatted;
    if (j.jobEndDate != null && j.jobEndDate!.trim().isNotEmpty) {
      try {
        endsFormatted = CcsDateUtils.fullDate(DateTime.parse(j.jobEndDate!));
      } catch (_) {
        endsFormatted = j.jobEndDate;
      }
    }
    final scheduleSummary = jobScheduleSummaryLine(
      dateFormatted: _hasScheduleDate(j) ? _scheduleDateText(j) : null,
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
              backgroundColor: getBgColor(j.status ?? '', scheme),
              foregroundColor: getFgColor(j.status ?? '', scheme),
            ),
            if (j.status != 'Finished' && j.status != 'Cancelled')
              InfoChip(
                label: scheduled ? 'Scheduled' : 'Not scheduled',
                backgroundColor: scheduled ? scheme.primaryContainer : scheme.surfaceContainerHighest,
                foregroundColor: scheduled ? scheme.primary : scheme.onSurfaceVariant,
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

        const SizedBox(height: 12),

        Row(
          children: [
            if (j.jobSchedule == false && j.status != 'Cancelled' && j.status != 'Finished') ...[
              AppButton(
                label: 'Schedule',
                icon: IconsaxPlusLinear.calendar_1,
                onPressed: c.onScheduleJob,
                btnVerticalPadding: 8,
                btnCornerRadius: 12,
                btnHorizontalPadding: 12,
              ).marginOnly(right: 8),
            ],

            AppButton(
              label: 'Extend Time',
              icon: IconsaxPlusLinear.clock_1,
              onPressed: (){
                c.openFilter(context);
              },
              btnVerticalPadding: 8,
              btnCornerRadius: 12,
              btnHorizontalPadding: 12,
            ),


          ],

        ),

        if (j.jobSchedule == true && j.status != 'Cancelled') ...[
          const SizedBox(height: 12),
          AppButton(
            label: 'Cancel job',
            onPressed: () => c.onCancelJob(),
            type: ButtonType.outline,
            txtClr: scheme.error,
            borderClr: scheme.error,
            btnVerticalPadding: 8,
            btnCornerRadius: 12,
            btnHorizontalPadding: 12,
          ),
        ],
      ],
    );
  }
}

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
