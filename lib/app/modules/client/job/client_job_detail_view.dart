import 'package:ccs_app/app/model/chat_message.dart';
import 'package:ccs_app/app/services/pref.dart';
import 'package:ccs_app/app/widget/layout/app_scaffold.dart';
import 'package:ccs_app/export.dart';

import '../../../model/client_job.dart';
import 'client_job_detail_controller.dart';

enum _JobMenuAction { edit, delete }

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
           /* IconButton(
              icon: Icon(IconsaxPlusLinear.message_text, size: 22),
              tooltip: 'Contact',
              onPressed: controller.onContactClient,
            ),*/

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
          ],
        ),
        backgroundColor: scheme.surface,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: UiConstants.padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Property & client
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonText.semiBold('Property', size: 16, color: scheme.onSurface),
                      const SizedBox(height: 12),
                      LabelValueRow(label: 'Property', value: j?.property?.propertyName ?? "N/A", scheme: scheme),
                      if (j?.property?.propertyType != null) LabelValueRow(label: 'Property type', value: j?.property?.propertyType ?? "", scheme: scheme),
                      if (j?.property?.subType != null) LabelValueRow(label: 'Subtype', value: j?.property?.subType ?? "", scheme: scheme),
                      if (j?.property?.address != null || j?.property?.city != null || j?.property?.postalCode != null)
                        LabelValueRow(
                          label: 'Address',
                          value: [j?.property?.address, j?.property?.city, j?.property?.postalCode].whereType<String>().join(', '),
                          scheme: scheme,
                        ),
                      if (j?.accessToProperty != null) LabelValueRow(label: 'Access', value: j?.accessToProperty ?? "", scheme: scheme),
                      if (j?.property?.animalProperty != null)
                        LabelValueRow(label: 'Animals', value: j?.property?.animalProperty == "1" ? "Yes" : "No", scheme: scheme),
                      if (j?.jobType != null) LabelValueRow(label: 'Payment source', value: j?.jobType?.capitalizeFirst ?? "", scheme: scheme),
                      LabelValueRow(label: 'Cleaners needed', value: '${j?.numberOfCleaners ?? 0}', scheme: scheme),
                    ],
                  ).paddingAll(UiConstants.defaultPadding),
                ),
                const SizedBox(height: 16),

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
                            label: 'Job Scheduled: ${(j?.jobSchedule ?? false) ? 'Yes' : 'No'}',
                            backgroundColor: (j?.jobSchedule ?? false) ? scheme.primaryContainer : scheme.primaryContainer,
                            foregroundColor: (j?.jobSchedule ?? false) ? scheme.primary : scheme.primary,
                          ),
                          InfoChip(
                              label: 'Status: ${j?.status?.capitalizeFirst ?? "N/A"}',
                              backgroundColor: getBgColor(j?.status ?? "", scheme),
                              foregroundColor: getFgColor(j?.status ?? "", scheme)),
                          if (j?.scheduler?.frequency != null)
                            InfoChip(
                                label: j?.scheduler?.frequency?.capitalizeFirst ?? "",
                                backgroundColor: scheme.tertiaryContainer,
                                foregroundColor: scheme.tertiary),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (j?.jobStartDate != null)
                        LabelValueRow(label: 'Job start date', value: CcsDateUtils.fullDate(DateTime.parse(j?.jobStartDate ?? "")), scheme: scheme),
                      if (j?.date != null && j?.jobStartDate == null)
                        LabelValueRow(label: 'Job date', value: CcsDateUtils.fullDate(DateTime.parse(j?.date ?? "")), scheme: scheme),
                      if (j?.startTime != null && j?.endTime != null)
                        LabelValueRow(
                            label: 'Job time',
                            value: "${CcsDateTimeX.convertTime(j?.startTime ?? " ")}  -  ${CcsDateTimeX.convertTime(j?.endTime ?? "")}",
                            scheme: scheme),
                      if (j?.jobEndDate != null)
                        LabelValueRow(
                            label: 'Job end date',
                            value: j?.jobEndDate != null ? CcsDateUtils.fullDate(DateTime.parse(j?.jobEndDate ?? "")) : '–',
                            scheme: scheme),
                      if (j?.jobSchedule == false && j?.status != 'Cancelled') ...[
                        const SizedBox(height: 8),
                        AppButton(
                          label: 'Schedule',
                          icon: IconsaxPlusLinear.calendar_1,
                          onPressed: c.onScheduleJob,
                          btnVerticalPadding: 8,
                          btnCornerRadius: 12,
                          btnHorizontalPadding: 12,
                        ),
                      ],
                      if (j?.jobSchedule == true) ...[
                        const SizedBox(height: 8),
                        AppButton(
                          label: 'Cancel job',
                          onPressed: () => c.onCancelJob(),
                          type: ButtonType.outline,
                          txtClr: context.colorScheme.error,
                          borderClr: context.colorScheme.error,
                          btnVerticalPadding: 8,
                          btnCornerRadius: 12,
                          btnHorizontalPadding: 12,
                        ),
                      ],
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
                      if (j?.property?.staffPreference != null) LabelValueRow(label: 'Staff preference', value: j?.staffPreference ?? "", scheme: scheme),
                      if (j?.property?.hoover != null) LabelValueRow(label: 'Hoover', value: j?.property?.hoover ?? "", scheme: scheme),
                      LabelValueRow(label: 'Cleaning products', value: j?.provideCleaningProducts == true ? 'Yes' : 'No', scheme: scheme),
                      LabelValueRow(label: 'Washing machine', value: j?.provideWashingMachine == true ? 'Yes' : 'No', scheme: scheme),
                      LabelValueRow(label: 'Dryer', value: j?.provideDryer == true ? 'Yes' : 'No', scheme: scheme),
                    ],
                  ).paddingAll(UiConstants.defaultPadding),
                ),
                const SizedBox(height: 16),

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
                      var cleaner = j.jobCleaners?.firstWhereOrNull((element) => element.userId == cl.id);

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
                          onTap: () => Get.toNamed(Routes.STAFF_DETAILS, arguments: {"id": item.id.toInt(), "type": 'staffDetail'}),
                        ),
                      );
                    },
                  ),
                ],

                AppButton(
                    label: 'Chat',
                    type: ButtonType.tonal,
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
                        participants[cleaner.id.toString()] =
                            ChatParticipant(id: cleaner.id.toString(), name: cleaner.name, role: RoleConstants.roleKeyCleaner);
                      }
                      Get.toNamed(Routes.JOB_CHAT, arguments: {
                        'type': ChatConstants.typeJob,
                        'jobId': job?.id.toString(),
                        'job': chatJob,
                        'participants': participants,
                      });
                    }).marginOnly(top: 12)
              ],
            ),
          ),
        ),
      );
    });
  }
}
