import 'package:ccs_app/app/widget/layout/app_scaffold.dart';
import 'package:ccs_app/export.dart';

import 'client_job_detail_controller.dart';

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
          title: j.jobType,
          headerLogoIcon: false,
          hasBackIcon: true,
          titleCentered: false,
          actions: [
            IconButton(
              icon: Icon(IconsaxPlusLinear.message_text, size: 22, color: scheme.primary),
              tooltip: 'Chat',
              onPressed: () => Get.toNamed(Routes.CHAT),
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
                            label: 'JOB SCHEDULED: ${j.isScheduled ? 'YES' : 'NO'}',
                            backgroundColor: j.isScheduled ? scheme.primaryContainer : scheme.surfaceContainerHighest,
                            foregroundColor: j.isScheduled ? scheme.primary : scheme.onSurfaceVariant,
                          ),
                          InfoChip(label: 'Status: ${j.status.toUpperCase()}', backgroundColor: scheme.secondaryContainer, foregroundColor: scheme.secondary),
                        if (j.recurrence != null) InfoChip(label: j.recurrence!, backgroundColor: scheme.tertiaryContainer, foregroundColor: scheme.tertiary),
                        ],
                      ),
                      const SizedBox(height: 12),
                      LabelValueRow(label: 'Job start date', value: CcsDateUtils.fullDate(j.date), scheme: scheme),
                      LabelValueRow(label: 'Job start time', value: j.startTime, scheme: scheme),
                      LabelValueRow(label: 'Job end date', value: j.jobEndDate != null ? CcsDateUtils.fullDate(j.jobEndDate!) : '–', scheme: scheme),
                      LabelValueRow(label: 'Job end time', value: j.endTime, scheme: scheme),
                      if (!j.isScheduled) ...[
                        const SizedBox(height: 16),
                        AppButton(
                          label: 'Schedule',
                          icon: IconsaxPlusLinear.calendar_1,
                          onPressed: c.onScheduleJob,
                        ),
                      ],
                      if (j.isScheduled) ...[
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: c.onCancelJob,
                          child: CommonText.regular('Cancel job', size: 14, color: scheme.error),
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
                    LabelValueRow(label: 'Client', value: j.clientName, scheme: scheme),
                    LabelValueRow(label: 'Property', value: j.propertyOneLine, scheme: scheme),
                    if (j.propertyLabel != null) LabelValueRow(label: 'Label', value: j.propertyLabel!, scheme: scheme),
                    if (j.accessToProperty != null) LabelValueRow(label: 'Access', value: j.accessToProperty!, scheme: scheme),
                    if (j.address != null || j.city != null || j.postalCode != null)
                      LabelValueRow(
                        label: 'Address',
                        value: [j.address, j.city, j.postalCode].whereType<String>().join(', '),
                        scheme: scheme,
                      ),
                    if (j.propertyType != null) LabelValueRow(label: 'Property type', value: j.propertyType!, scheme: scheme),
                    if (j.propertySubtype != null) LabelValueRow(label: 'Subtype', value: j.propertySubtype!, scheme: scheme),
                    if (j.animals != null) LabelValueRow(label: 'Animals', value: j.animals!, scheme: scheme),
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
                    if (j.staffPreference != null) LabelValueRow(label: 'Staff preference', value: j.staffPreference!, scheme: scheme),
                    if (j.hoover != null) LabelValueRow(label: 'Hoover', value: j.hoover!, scheme: scheme),
                    LabelValueRow(label: 'Cleaning products', value: j.provideCleaningProducts ? 'Yes' : 'No', scheme: scheme),
                    LabelValueRow(label: 'Washing machine', value: j.provideWashingMachine ? 'Yes' : 'No', scheme: scheme),
                    LabelValueRow(label: 'Dryer', value: j.provideDryer ? 'Yes' : 'No', scheme: scheme),
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
                    if (j.invoicePaymentSource != null) LabelValueRow(label: 'Payment source', value: j.invoicePaymentSource!, scheme: scheme),
                    LabelValueRow(label: 'Cleaners needed', value: '${j.cleanersNeeded}', scheme: scheme),
                  ],
                ).paddingAll(UiConstants.defaultPadding),
              ),

              if (j.additionalNotes != null && j.additionalNotes!.isNotEmpty) ...[
                const SizedBox(height: 16),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonText.semiBold('Additional notes', size: 16, color: scheme.onSurface),
                      const SizedBox(height: 8),
                      CommonText.regular(j.additionalNotes!, size: 14, color: scheme.onSurfaceVariant),
                    ],
                  ).paddingAll(UiConstants.defaultPadding),
                ),
              ],

              if (j.cleaners.isNotEmpty) ...[
                const SizedBox(height: 16),
                CommonText.semiBold('Cleaners', size: 16, color: scheme.onSurface),
                const SizedBox(height: 8),
                ...j.cleaners.map(
                  (cl) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: CleanerCard(
                      cleaner: cl,
                      isReview: true,
                      onShare: () => c.onShareCleanerProfile(cl),
                      scheme: scheme,
                      onReview: () => c.onReviewCleanerProfile(cl),
                    ),
                  ),
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
