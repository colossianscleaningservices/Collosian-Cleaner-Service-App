import 'package:ccs_app/app/model/client_job.dart';
import 'package:ccs_app/app/services/pref.dart';
import 'package:ccs_app/app/widget/layout/app_scaffold.dart';
import 'package:ccs_app/app/widget/layout/bottom_action_bar.dart';
import 'package:ccs_app/export.dart';

import 'cleaner_job_detail_controller.dart';

/// Cleaner job detail: same layout as client (AppScaffold, Header, AppCard sections).
/// App bar: Directions, Contact. Status area: Accept/Decline when Pending.
class CleanerJobDetailView extends GetView<CleanerJobDetailController> {
  const CleanerJobDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Obx(() {
      final j = controller.job.value;

      // 'Accepted','Rejected'
      var cleanerStatus = ((j?.jobCleaners?.firstWhereOrNull((item) => item.userId.toString() == Prefs().userId)?.status));
      var cleaner = ((j?.jobCleaners?.firstWhereOrNull((item) => item.userId.toString() == Prefs().userId)));

      return AppScaffold(
        appBar: Header(
          title: controller.job.value?.cleaningType?.name ?? "",
          headerLogoIcon: false,
          hasBackIcon: true,
          titleCentered: false,
          actions: [
            /*IconButton(
            icon: Icon(IconsaxPlusLinear.map_1, size: 22),
            tooltip: 'Directions',
            onPressed: controller.onDirections,
          ),*/
            IconButton(
              icon: Icon(IconsaxPlusLinear.message_text, size: 22),
              tooltip: 'Contact',
              onPressed: controller.onContactClient,
            ),
          ],
        ),
        backgroundColor: scheme.surface,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
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
                                InfoChip(label: cleanerStatus ?? j?.status ?? "N/A", backgroundColor: scheme.primaryContainer, foregroundColor: scheme.primary),

                                /*if (j?.recurrence != null)
                                  InfoChip(label: j.recurrence!, backgroundColor: scheme.secondaryContainer, foregroundColor: scheme.secondary),*/
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (j?.date != null) LabelValueRow(label: 'Date', value: CcsDateUtils.fullDate(DateTime.parse(j?.date ?? "")), scheme: scheme),
                            LabelValueRow(label: 'Time', value: '${j?.startTime ?? "N/A"} – ${j?.endTime ?? "N/A"}', scheme: scheme),
                            if (j?.jobEndDate != null)
                              LabelValueRow(label: 'End date', value: CcsDateUtils.fullDate(DateTime.parse(j?.jobEndDate ?? "")), scheme: scheme),
                            if ((j?.status == 'Pending' || j?.status?.toLowerCase() == 'pending') &&
                                cleanerStatus?.toLowerCase() != 'accepted' &&
                                cleanerStatus?.toLowerCase() != 'rejected') ...[
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: AppButton(
                                      label: 'Accept',
                                      onPressed: controller.onAccept,
                                      type: ButtonType.primary,
                                      icon: IconsaxPlusLinear.tick_circle,
                                      btnVerticalPadding: 8,
                                      btnHorizontalPadding: 8,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: AppButton(
                                      label: 'Decline',
                                      onPressed: controller.onDecline,
                                      type: ButtonType.outline,
                                      icon: IconsaxPlusLinear.close_circle,
                                      bgColor: Colors.transparent,
                                      txtClr: scheme.error,
                                      borderClr: scheme.error,
                                      btnVerticalPadding: 8,
                                      btnHorizontalPadding: 8,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            if (cleanerStatus?.toLowerCase() == 'completed') ...[
                              Column(
                                children: [
                                  if (cleaner?.checkInDate != null)
                                    LabelValueRow(
                                        label: 'Check-In Date', value: CcsDateUtils.fullDate(DateTime.parse(cleaner?.checkInDate ?? "")), scheme: scheme),
                                  if (cleaner?.checkOutDate != null)
                                    LabelValueRow(
                                        label: 'Check-Out Date', value: CcsDateUtils.fullDate(DateTime.parse(cleaner?.checkOutDate ?? "")), scheme: scheme),
                                  LabelValueRow(
                                      label: 'Check-In/Check-Out Time',
                                      value: '${cleaner?.checkInTime ?? "N/A"} – ${cleaner?.checkOutTime ?? "N/A"}',
                                      scheme: scheme),
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
                            LabelValueRow(label: 'Client', value: j?.user?.name ?? "", scheme: scheme),
                            LabelValueRow(label: 'Property', value: j?.property?.propertyName ?? "N/A", scheme: scheme),
                            if (j?.property?.propertyName != null) LabelValueRow(label: 'Label', value: j?.property?.propertyName ?? "", scheme: scheme),
                            if (j?.accessToProperty != null) LabelValueRow(label: 'Access', value: j?.property?.accessToProperty ?? "", scheme: scheme),
                            if (j?.property?.address != null || j?.property?.city != null || j?.property?.postalCode != null)
                              LabelValueRow(
                                label: 'Address',
                                value: [j?.property?.address, j?.property?.city, j?.property?.postalCode].whereType<String>().join(', '),
                                scheme: scheme,
                              ),
                            if (j?.property?.propertyType != null)
                              LabelValueRow(label: 'Property type', value: j?.property?.propertyType ?? "", scheme: scheme),
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
                            if (j?.property?.staffPreference != null) LabelValueRow(label: 'Staff preference', value: j?.staffPreference ?? "", scheme: scheme),
                            if (j?.property?.hoover != null) LabelValueRow(label: 'Hoover', value: j?.property?.hoover ?? "", scheme: scheme),
                            LabelValueRow(label: 'Cleaning products', value: j?.property?.provideCleaningProducts == true ? 'Yes' : 'No', scheme: scheme),
                            LabelValueRow(label: 'Washing machine', value: j?.property?.provideWashingMachine == true ? 'Yes' : 'No', scheme: scheme),
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
                            LabelValueRow(label: 'Cleaners needed', value: '${j?.numberOfCleaners ?? 'N/A'}', scheme: scheme),
                          ],
                        ).paddingAll(UiConstants.defaultPadding),
                      ),

                      if (j?.additionalDetails != null && j?.additionalDetails.isNotEmpty) ...[
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

                      if (j?.jobCleaners?.isNotEmpty == true) ...[
                        const SizedBox(height: 16),
                        CommonText.semiBold('Cleaners', size: 16, color: scheme.onSurface),
                        const SizedBox(height: 8),
                        ...?j?.cleaners?.map(
                          (cl) {
                            var item = ((j.jobCleaners?.firstWhereOrNull((item) => item.userId.toString() == cl.id.toString())));
                            var cleaner =
                                ClientJobCleaner(id: cl.id.toString(), name: cl.name ?? "N/A", status: cl.status ?? "N/A", isReview: item?.isReviewed ?? false);
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: CleanerCard(
                                cleaner: cleaner,
                                onShare: () => controller.onShareCleanerProfile(cleaner),
                                scheme: scheme,
                                onReview: () => {},
                                onTap: () => Get.toNamed(Routes.STAFF_DETAILS,arguments: item?.id),
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
            ],
          ),
        ),
        bottomNavigationBar: Obx(() {
          return controller.bottomBarState != 0
              ? SingleActionBottomBar(
                  label: controller.bottomBarLabel,
                  onPressed: controller.bottomBarOnPressed ?? () {},
                  buttonType: controller.bottomBarButtonType,
                )
              : SizedBox.shrink();
        }),
      );
    });
  }
}
