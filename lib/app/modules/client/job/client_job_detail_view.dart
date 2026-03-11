import 'package:ccs_app/app/model/chat_message.dart';
import 'package:ccs_app/app/services/pref.dart';
import 'package:ccs_app/app/widget/layout/app_scaffold.dart';
import 'package:ccs_app/export.dart';

import '../../../model/client_job.dart';
import 'client_job_detail_controller.dart';

//Missing Info :- Client Name, Recurrence
/// Client job detail: status, schedule, property, preferences, cleaners.
class ClientJobDetailView extends GetView<ClientJobDetailController> {
  const ClientJobDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final scheme = context.colorScheme;

    return Obx(() {
      final j = c.job.value;
      return AppScaffold(
        appBar: Header(
          title: j?.cleaningType?.name ?? "",
          headerLogoIcon: false,
          hasBackIcon: true,
          titleCentered: false,
          actions: [
            IconButton(
              icon: Icon(IconsaxPlusLinear.message_text, size: 22, color: scheme.primary),
              tooltip: 'Chat',
              onPressed: () {
                final job = c.job.value;
                final chatJob = ChatJob(
                  id: job?.id.toString() ?? "",
                  jobType: job?.jobType,
                  propertyOneLine: job?.property?.propertyName,
                  date: DateTime.parse(job?.date ?? "").toIso8601String(),
                  clientName: /*job?.clientName*/ "",
                );
                final participants = <String, ChatParticipant>{};
                // Current user (client)
                final userId = Prefs().userId;
                final userName = Prefs().userFullName;
                participants[userId] = ChatParticipant(id: userId, name: userName, role: RoleConstants.roleKeyClient);
                // Assigned cleaners
                for (final cleaner in job?.cleaners ?? []) {
                  participants[cleaner.id] = ChatParticipant(id: cleaner.id, name: cleaner.name, role: RoleConstants.roleKeyCleaner);
                }
                Get.toNamed(Routes.JOB_CHAT, arguments: {
                  'type': ChatConstants.typeJob,
                  'jobId': job?.id.toString(),
                  'job': chatJob,
                  'participants': participants,
                });
              },
            ),
            IconButton(
              icon: Icon(IconsaxPlusLinear.edit_2, size: 22, color: scheme.primary),
              tooltip: 'Edit job',
              onPressed: c.onEdit,
            ),
            IconButton(
              icon: Icon(IconsaxPlusLinear.trash, size: 22, color: scheme.error),
              tooltip: 'Delete job',
              onPressed: () => c.confirmDeleteJob(context),
            ),
          ],
        ),
        backgroundColor: scheme.surface,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: UiConstants.padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Status & schedule
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonText.semiBold('Status & schedule', size: 16, color: scheme.onSurface),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          InfoChip(
                            label: 'JOB SCHEDULED: ${(j?.jobSchedule ?? false) ? 'YES' : 'NO'}',
                            backgroundColor: (j?.jobSchedule ?? false) ? scheme.primaryContainer : scheme.surfaceContainerHighest,
                            foregroundColor: (j?.jobSchedule ?? false) ? scheme.primary : scheme.onSurfaceVariant,
                          ),
                          InfoChip(
                              label: 'Status: ${j?.status?.toUpperCase() ?? "N/A"}',
                              backgroundColor: scheme.secondaryContainer,
                              foregroundColor: scheme.secondary),
                          // if (j.recurrence != null) InfoChip(label: j.recurrence!, backgroundColor: scheme.tertiaryContainer, foregroundColor: scheme.tertiary),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (j?.jobStartDate != null)
                        LabelValueRow(label: 'Job start date', value: CcsDateUtils.fullDate(DateTime.parse(j?.jobStartDate ?? "")), scheme: scheme),
                      LabelValueRow(label: 'Job start time', value: j?.startTime ?? "N/A", scheme: scheme),
                      if (j?.jobEndDate != null)
                        LabelValueRow(
                            label: 'Job end date',
                            value: j?.jobEndDate != null ? CcsDateUtils.fullDate(DateTime.parse(j?.jobEndDate ?? "")) : '–',
                            scheme: scheme),
                      LabelValueRow(label: 'Job end time', value: j?.endTime ?? "N/A", scheme: scheme),
                      if (j?.jobSchedule == false && j?.status != 'Cancelled') ...[
                        const SizedBox(height: 16),
                        AppButton(
                          label: 'Schedule',
                          icon: IconsaxPlusLinear.calendar_1,
                          onPressed: c.onScheduleJob,
                        ),
                      ],
                      if (j?.jobSchedule == true) ...[
                        const SizedBox(height: 12),
                        AppButton(
                          label: 'Cancel job',
                          onPressed: () => c.onCancelJob(),
                          type: ButtonType.outline,
                          txtClr: context.colorScheme.error,
                          borderClr: context.colorScheme.error,
                        ),
                      ],
                    ],
                  ).paddingAll(UiConstants.defaultPadding),
                ),
                const SizedBox(height: 16),

                // Property & client
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonText.semiBold('Property & client', size: 16, color: scheme.onSurface),
                      const SizedBox(height: 12),
                      LabelValueRow(label: 'Client', value: Prefs().getData(Prefs.id) == j?.property?.userId.toString() ? 'Self' : "N/A", scheme: scheme),
                      LabelValueRow(label: 'Property', value: j?.property?.propertyName ?? "N/A", scheme: scheme),
                      if (j?.property?.propertyName != null) LabelValueRow(label: 'Label', value: j?.property?.propertyName ?? "", scheme: scheme),
                      if (j?.accessToProperty != null) LabelValueRow(label: 'Access', value: j?.accessToProperty ?? "", scheme: scheme),
                      if (j?.property?.address != null || j?.property?.city != null || j?.property?.postalCode != null)
                        LabelValueRow(
                          label: 'Address',
                          value: [j?.property?.address, j?.property?.city, j?.property?.postalCode].whereType<String>().join(', '),
                          scheme: scheme,
                        ),
                      if (j?.property?.propertyType != null) LabelValueRow(label: 'Property type', value: j?.property?.propertyType ?? "", scheme: scheme),
                      if (j?.property?.subType != null) LabelValueRow(label: 'Subtype', value: j?.property?.subType ?? "", scheme: scheme),
                      if (j?.property?.animalProperty != null) LabelValueRow(label: 'Animals', value: j?.property?.animalProperty ?? "", scheme: scheme),
                    ],
                  ).paddingAll(UiConstants.defaultPadding),
                ),
                const SizedBox(height: 16),

                // Preferences & equipment
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonText.semiBold('Preferences & equipment', size: 16, color: scheme.onSurface),
                      const SizedBox(height: 12),
                      if (j?.property?.staffPreference != null)
                        LabelValueRow(label: 'Staff preference', value: j?.property?.staffPreference ?? "", scheme: scheme),
                      if (j?.property?.hoover != null) LabelValueRow(label: 'Hoover', value: j?.property?.hoover ?? "", scheme: scheme),
                      LabelValueRow(label: 'Cleaning products', value: j?.provideCleaningProducts == true ? 'Yes' : 'No', scheme: scheme),
                      LabelValueRow(label: 'Washing machine', value: j?.provideWashingMachine == true ? 'Yes' : 'No', scheme: scheme),
                      LabelValueRow(label: 'Dryer', value: j?.provideDryer == true ? 'Yes' : 'No', scheme: scheme),
                    ],
                  ).paddingAll(UiConstants.defaultPadding),
                ),
                const SizedBox(height: 16),

                // Payment & staff
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonText.semiBold('Payment & staff', size: 16, color: scheme.onSurface),
                      const SizedBox(height: 12),
                      if (j?.jobType != null) LabelValueRow(label: 'Payment source', value: j?.jobType?.capitalizeFirst ?? "", scheme: scheme),
                      LabelValueRow(label: 'Cleaners needed', value: '${j?.numberOfCleaners ?? 0}', scheme: scheme),
                    ],
                  ).paddingAll(UiConstants.defaultPadding),
                ),

                if (j?.additionalDetails != null && j?.additionalDetails?.isNotEmpty == true) ...[
                  const SizedBox(height: 16),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonText.semiBold('Additional notes', size: 16, color: scheme.onSurface),
                        const SizedBox(height: 8),
                        CommonText.regular(j?.additionalDetails ?? "", size: 14, color: scheme.onSurfaceVariant),
                      ],
                    ).paddingAll(UiConstants.defaultPadding),
                  ),
                ],

                if (j?.cleaners?.isNotEmpty == true) ...[
                  const SizedBox(height: 16),
                  CommonText.semiBold('Cleaners', size: 16, color: scheme.onSurface),
                  const SizedBox(height: 8),
                  ...?j?.cleaners?.map(
                    (cl) {

                      var cleaner  = j.jobCleaners?.firstWhereOrNull((element) => element.userId == cl.id);

                      var item = ClientJobCleaner(
                        id: cl.id.toString(),
                        avatarUrl: cl.imageUrl,
                        name: cl.name ?? "",
                        status: cleaner?.status ?? "N/A",
                      );

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: CleanerCard(
                          cleaner: item,
                          isReview: cleaner?.isReviewed == true ? false : true,
                          onShare: () => c.onShareCleanerProfile(item),
                          scheme: scheme,
                          onReview: () => c.onReviewCleanerProfile(item),
                        ),
                      );
                    },
                  ),
                ],
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      );
    });
  }
}
