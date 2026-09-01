import 'dart:async';

import 'package:ccs_app/app/widget/common/wheel_picker_time.dart';
import 'package:ccs_app/app/widget/layout/app_scaffold.dart';
import 'package:ccs_app/app/widget/layout/bottom_action_bar.dart';
import 'package:ccs_app/export.dart';
import 'package:flutter_html/flutter_html.dart';

import 'create_job_controller.dart';
import '../../../network/response/end_of_tenancy_bands_response.dart';

/// "Create a Cleaning Job" form. Opened from Client Jobs tab.
class CreateJobView extends GetView<CreateJobController> {
  const CreateJobView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;

    return Obx(() {
      controller.endTime.value;
      controller.isEndOfTenancy.value;
      return AppScaffold(
        appBar: Header(
          title: '${controller.isEdit ? "Update" : "Create"} a Cleaning Job',
          hasBackIcon: true,
          headerLogoIcon: false,
          titleCentered: false,
        ),
        backgroundColor: scheme.surface,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Form(
              key: controller.formKey,
              child: Column(
                spacing: 16,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 14,
                      children: [
                        CommonText.semiBold('Property & scheduling', size: 16, color: scheme.onSurface),
                        Obx(() => controller.isLoading.value
                            ? Center(child: CircularProgressIndicator())
                            : GestureDetector(
                                onTap: () {
                                  if (controller.properties.isEmpty) {
                                    Notifier.error('Please create property.');
                                  }
                                },
                                child: CommonDropDownField<String>(
                                  label: 'Property',
                                  hint: 'Select',
                                  items: controller.properties.map((item) => item.propertyName ?? "").toList(),
                                  itemLabel: (v) => v,
                                  value: controller.selectedProperty.value,
                                  onChanged: (v) => controller.onPropertySelected(v),
                                  validator: (v) => controller.validateProperty(v),
                                ),
                              )),
                        CommonTextField(
                          controller: controller.dateDisplayController,
                          label: 'Job Start Date',
                          hint: '-- / -- / ----',
                          isReadOnly: true,
                          onTap: () => _pickDate(context, controller),
                          validator: (_) => controller.jobStartDate.value == null ? 'Job Start Date is required' : null,
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (controller.jobStartDate.value != null)
                                IconButton(
                                  icon: const Icon(IconsaxPlusLinear.close_circle, size: 18),
                                  onPressed: () => controller.setJobStartDate(null),
                                  constraints: const BoxConstraints(),
                                  padding: const EdgeInsets.all(4),
                                ),
                              Icon(IconsaxPlusLinear.calendar_1, size: 20, color: scheme.primary).marginOnly(right: 12),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: CommonTextField(
                                controller: controller.startTimeDisplayController,
                                label: 'Start Time',
                                hint: '--:--',
                                isReadOnly: true,
                                onTap: () => wheelTimePicker(context, controller, isStart: true),
                                suffixIcon: Icon(IconsaxPlusLinear.clock, size: 20, color: scheme.primary),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: CommonTextField(
                                controller: controller.endTimeDisplayController,
                                label: controller.isEndOfTenancy.value ? 'End Time (optional)' : 'End Time',
                                hint: '--:--',
                                isReadOnly: true,
                                onTap: () => wheelTimePicker(context, controller, isStart: false),
                                validator: controller.validateEndTime,
                                suffixIcon: Icon(IconsaxPlusLinear.clock, size: 20, color: scheme.primary),
                              ),
                            ),
                          ],
                        ),
                        CommonDropDownField<String>(
                          label: 'Would you like to pay the invoice from your:',
                          hint: 'Please select',
                          items: const ['Residential', 'Commercial'],
                          itemLabel: (v) => v,
                          value: controller.invoicePaymentSource.value.isEmpty ? null : controller.invoicePaymentSource.value,
                          onChanged: (v) => controller.invoicePaymentSource.value = v ?? '',
                          validator: (v) => v == null ? 'Payment source is required' : null,
                        ),
                        CommonTextField(
                          controller: controller.cleanersNeededController,
                          label: 'Cleaner(s) Needed?',
                          hint: '1',
                          keyboardType: TextInputType.number,
                          maxLength: 2,
                          validator: controller.validateCleanersNeeded,
                          onChanged: controller.onCleanersNeededChanged,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                        CommonTextField(
                          controller: controller.cleaningTypeCtrl,
                          label: 'Cleaning Type',
                          isReadOnly: true,
                          hint: 'Select Cleaning Type',
                          keyboardType: TextInputType.text,
                          suffixIcon: Icon(IconsaxPlusLinear.arrow_down),
                          onTap: () {
                            Notifier.openSheet(
                              context,
                              top: true,
                              showPrimaryButton: false,
                              showSecondaryButton: false,
                              showIcon: false,
                              expandBody: true,
                              body: Column(
                                children: [
                                  _SearchSection(controller: controller, scheme: scheme).marginOnly(bottom: 8),
                                  Expanded(
                                    child: Obx(() {
                                      if (controller.isLoadingCleaningType.value) {
                                        return const Center(child: CircularProgressIndicator());
                                      }
                                      if (controller.cleaningTypeList.isEmpty) {
                                        return const Center(
                                          child: NoDataView(
                                            title: 'No Cleaning Type Found',
                                          ),
                                        );
                                      }
                                      return ListView.builder(
                                        itemCount: controller.cleaningTypeList.length,
                                        itemBuilder: (context, index) {
                                          final item = controller.cleaningTypeList[index];
                                          return AppCard(
                                            color: item.isSelect ? scheme.secondaryContainer : scheme.onPrimary,
                                            borderWidth: item.isSelect ? 1.5 : 0,
                                            borderColor: item.isSelect ? scheme.secondary : Colors.transparent,
                                            onTap: () {
                                              controller.selectCleaningType(item);
                                              Get.back();
                                            },
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                CommonText.semiBold(item.name ?? "").marginOnly(bottom: 4),
                                                if ((item.description ?? '').trim().isNotEmpty)
                                                  Html(
                                                    data: item.description!,
                                                    style: {
                                                      'body': Style(
                                                        fontSize: FontSize(14),
                                                        color: scheme.onSurface.withValues(alpha: 0.7),
                                                        margin: Margins.zero,
                                                        padding: HtmlPaddings.zero,
                                                        fontWeight: FontWeight.w400,
                                                      ),
                                                      'p': Style(
                                                        margin: Margins.only(bottom: 4),
                                                        padding: HtmlPaddings.zero,
                                                      ),
                                                      'ul': Style(margin: Margins.only(left: 8, bottom: 4)),
                                                      'ol': Style(margin: Margins.only(left: 8, bottom: 4)),
                                                      'li': Style(margin: Margins.only(bottom: 2)),
                                                    },
                                                  ),
                                              ],
                                            ).paddingAll(16),
                                          ).marginAll(8);
                                        },
                                      );
                                    }),
                                  ),
                                ],
                              ),
                            );
                          },
                          validator: (v) => controller.validateRequired(v, 'Cleaning Type'),
                        ),
                        if (controller.isEndOfTenancy.value) _EndOfTenancyOptions(controller: controller, scheme: scheme),
                      ],
                    ).paddingSymmetric(horizontal: 18, vertical: 16),
                  ),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 14,
                      children: [
                        CommonText.semiBold('Preferences & access', size: 16, color: scheme.onSurface),
                        CommonDropDownField<String>(
                          label: 'Staff Preference',
                          hint: 'Select',
                          items: CreateJobController.staffPreferenceOptions,
                          itemLabel: (v) => v,
                          value: controller.staffPreference.value,
                          onChanged: (v) => controller.staffPreference.value = v ?? 'Male',
                        ),
                        CommonDropDownField<String>(
                          label: 'Access to Property',
                          hint: 'Select',
                          items: CreateJobController.accessOptions,
                          itemLabel: (v) => v,
                          value: controller.accessToProperty.value,
                          onChanged: (v) => controller.accessToProperty.value = v ?? 'Client Will Open',
                        ),
                        CommonDropDownField<String>(
                          label: 'Do you have a hoover?',
                          hint: 'Select',
                          items: CreateJobController.hooverOptions,
                          itemLabel: (v) => v,
                          value: controller.hoover.value,
                          onChanged: (v) => controller.hoover.value = v ?? 'No',
                        ),
                        AppCheckBox(
                          title: 'Check this if you are going to provide cleaning products',
                          value: controller.provideCleaningProducts.value,
                          onChange: (v) => controller.provideCleaningProducts.value = v,
                        ),
                        AppCheckBox(
                          title: 'Do you have a washing machine?',
                          value: controller.provideWashingMachine.value,
                          onChange: (v) => controller.provideWashingMachine.value = v,
                        ),
                        AppCheckBox(
                          title: 'Do you have a dryer?',
                          value: controller.provideDryer.value,
                          onChange: (v) => controller.provideDryer.value = v,
                        ),
                      ],
                    ).paddingSymmetric(horizontal: 18, vertical: 16),
                  ),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 14,
                      children: [
                        CommonText.semiBold('Additional instructions', size: 16, color: scheme.onSurface),
                        CommonTextField(
                          controller: controller.notesController,
                          label: 'Notes',
                          hint: 'Enter any special instructions for the cleaners...',
                          maxLines: 6,
                          minLines: 4,
                          maxLength: CreateJobController.maxNotesLength,
                          validator: controller.validateNotes,
                        ),
                      ],
                    ).paddingSymmetric(horizontal: 18, vertical: 16),
                  ),
                ],
              ).paddingSymmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ),
        bottomNavigationBar: SingleActionBottomBar(
          label: controller.isEdit ? "Update" : "Create",
          onPressed: () => controller.submit(context),
        ),
      );
    });
  }
}

class _EndOfTenancyOptions extends StatelessWidget {
  const _EndOfTenancyOptions({required this.controller, required this.scheme});

  final CreateJobController controller;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      controller.selectedBand.value;
      controller.customExtras.length;
      controller.selectedAddOnIds.length;
      final band = controller.selectedBand.value;
      final listedAddOns = band?.addOns ?? [];
      final sizeLabel = band?.name ?? 'this property size';

      return SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommonText.semiBold('End of Tenancy options', size: 16, color: scheme.onSurface),
            const SizedBox(height: 6),
            CommonText.regular(
              'Choose the size that matches your property and add anything extra you need. Your final price is confirmed on your invoice.',
              size: 13,
              color: scheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            if (controller.isLoadingEotBands.value)
              const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 12), child: CircularProgressIndicator()))
            else if (controller.selectedPropertyModel == null)
              CommonText.regular(
                'Select a property to load End of Tenancy options.',
                size: 13,
                color: scheme.onSurfaceVariant,
              )
            else ...[
              CommonDropDownField<EndOfTenancyBand>(
                label: 'Property size',
                hint: 'Select property size',
                items: controller.eotBands.toList(),
                itemLabel: (v) => v.displayLabel,
                value: band,
                onChanged: controller.onBandChanged,
                validator: controller.validateEotBand,
              ),
              if (controller.wasBandMatchedFromProperty.value) ...[
                const SizedBox(height: 6),
                CommonText.regular(
                  'Matched from your property details. You can change it if it is not right.',
                  size: 12,
                  color: scheme.onSurfaceVariant,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: CommonText.semiBold('Optional extras', size: 15, color: scheme.onSurface)),
                  AppCard(
                    color: scheme.primary,
                    enableShadows: false,
                    onTap: () => controller.addCustomExtra(),
                    child: Row(
                      children: [
                        Icon(IconsaxPlusLinear.add, size: 16, color: scheme.onPrimary),
                        CommonText.medium('Add extra', size: 13, color: scheme.onPrimary)
                      ],
                    ).paddingSymmetric(horizontal: 12, vertical: 8),
                  )
                ],
              ),
              const SizedBox(height: 4),
              CommonText.regular(
                "Not listed for a $sizeLabel? Use 'Add extra' and we will confirm the price before you are charged.",
                size: 12,
                color: scheme.onSurfaceVariant,
              ),
              if (listedAddOns.isNotEmpty) ...[
                const SizedBox(height: 10),
                ...listedAddOns.map(
                  (addon) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: AppCheckBox(
                      title: addon.displayName,
                      value: controller.isListedAddOnSelected(addon.id),
                      onChange: (_) {
                        controller.toggleListedAddOn(addon.id);
                        return true;
                      },
                    ),
                  ),
                ),
              ] else if (controller.customExtras.isEmpty) ...[
                const SizedBox(height: 8),
                CommonText.regular(
                  "No optional extras for this property size — use 'Add extra' to ask for something.",
                  size: 12,
                  color: scheme.onSurfaceVariant,
                ),
              ],
              if (controller.customExtras.isNotEmpty) ...[
                const SizedBox(height: 12),
                ...controller.customExtras.map((extra) => _CustomExtraCard(
                      key: ObjectKey(extra),
                      controller: controller,
                      extra: extra,
                      scheme: scheme,
                    )),
              ],
            ],
          ],
        ),
      );
    });
  }
}

class _CustomExtraCard extends StatelessWidget {
  const _CustomExtraCard({
    required this.controller,
    required this.extra,
    required this.scheme,
    super.key,
  });

  final CreateJobController controller;
  final EotCustomExtraEntry extra;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CommonTextField(
                  controller: extra.labelController,
                  label: 'Label',
                  hint: 'e.g. clean the garage',
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Label is required';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(top: 22),
                child: IconButton(
                  tooltip: 'Delete extra',
                  onPressed: () => controller.removeCustomExtra(extra),
                  icon: Icon(IconsaxPlusLinear.trash, size: 22, color: scheme.error),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          CommonTextField(
            controller: extra.noteController,
            label: 'Description (optional)',
            hint: 'Anything we should know?',
            maxLines: 3,
            minLines: 2,
          ),
        ],
      ),
    );
  }
}

class _SearchSection extends StatelessWidget {
  const _SearchSection({required this.controller, required this.scheme});

  final CreateJobController controller;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => CommonTextField(
        hint: 'Search by name or description',
        label: 'Search',
        controller: controller.searchController,
        borderColor: scheme.outline.withValues(alpha: 0.2),
        focus: controller.searchFocus,
        onChanged: (value) => controller.searchTerm.value = value,
        prefixIcon: Icon(
          IconsaxPlusLinear.search_normal_1,
          size: 22,
          color: scheme.onSurfaceVariant,
        ),
        suffixIcon: controller.searchTerm.isNotEmpty
            ? IconButton(
                icon: Icon(
                  IconsaxPlusLinear.close_circle,
                  size: 20,
                  color: scheme.primary,
                ),
                onPressed: () {
                  controller.searchController.clear();
                  controller.searchTerm.value = '';
                },
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}

Future<void> _pickDate(BuildContext context, CreateJobController ctrl) async {
  final d = await showDatePicker(
    context: context,
    initialDate: ctrl.jobStartDate.value?.isBefore(DateTime.now()) == true ? DateTime.now() : ctrl.jobStartDate.value ?? DateTime.now(),
    firstDate: DateTime.now(),
    lastDate: DateTime(2030, 12, 31),
  );
  if (d != null && context.mounted) ctrl.setJobStartDate(d);
}

Future<void> wheelTimePicker(
  BuildContext context,
  CreateJobController ctrl, {
  required bool isStart,
}) async {
  final initial = isStart ? ctrl.startTime.value : ctrl.endTime.value;
  return Notifier.openSheet(
    context,
    top: true,
    showPrimaryButton: false,
    showSecondaryButton: false,
    showIcon: false,
    body: WheelPickerTime(
      onSelected: (selected) {
        if (isStart) {
          ctrl.setStartTime(selected);
        } else {
          ctrl.setEndTime(selected);
        }
      },
      title: isStart ? 'Select Start Time' : 'Select End Time',
      initial: initial,
    ),
  );
}
