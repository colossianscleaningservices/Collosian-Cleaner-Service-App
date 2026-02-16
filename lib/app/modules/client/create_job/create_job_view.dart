import 'package:ccs_app/app/widget/layout/app_scaffold.dart';
import 'package:ccs_app/app/widget/layout/bottom_action_bar.dart';
import 'package:ccs_app/export.dart';

import 'create_job_controller.dart';

/// "Create a Cleaning Job" form. Opened from Client Jobs tab.
class CreateJobView extends GetView<CreateJobController> {
  const CreateJobView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;

    return Obx(() {
      controller.endTime.value;
      return AppScaffold(
        appBar: Header(
          title: 'Create a Cleaning Job',
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
                        Obx(() {
                          return controller.isLoadingProperties.value
                              ? Center(child: CircularProgressIndicator())
                              : CommonDropDownField<String>(
                                  label: 'Property',
                                  hint: 'Select',
                                  items: controller.properties.map((item) => item.propertyName ?? "").toList(),
                                  itemLabel: (v) => v,
                                  value: controller.selectedProperty.value,
                                  onChanged: (v) => controller.selectedProperty.value = v,
                                  validator: (v) => controller.validateProperty(v),
                                );
                        }),
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
                                  icon: const Icon(Icons.close, size: 18),
                                  onPressed: () => controller.setJobStartDate(null),
                                  constraints: const BoxConstraints(),
                                  padding: const EdgeInsets.all(4),
                                ),
                              Icon(Icons.calendar_today, size: 20, color: scheme.primary),
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
                                onTap: () => _pickTime(context, controller, isStart: true),
                                suffixIcon: Icon(Icons.access_time, size: 20, color: scheme.primary),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: CommonTextField(
                                controller: controller.endTimeDisplayController,
                                label: 'End Time',
                                hint: '--:--',
                                isReadOnly: true,
                                onTap: () => _pickTime(context, controller, isStart: false),
                                suffixIcon: Icon(Icons.access_time, size: 20, color: scheme.primary),
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
                          items: const ['Male', 'Female', 'No Preference'],
                          itemLabel: (v) => v,
                          value: controller.staffPreference.value,
                          onChanged: (v) => controller.staffPreference.value = v ?? 'Male',
                        ),
                        CommonDropDownField<String>(
                          label: 'Access to Property',
                          hint: 'Select',
                          items: const ['Client Will Open', 'Reception/Concierge', 'Key', 'Other'],
                          itemLabel: (v) => v,
                          value: controller.accessToProperty.value,
                          onChanged: (v) => controller.accessToProperty.value = v ?? 'Client Will Open',
                        ),
                        CommonDropDownField<String>(
                          label: 'Do you have a hoover?',
                          hint: 'Select',
                          items: const ['No', 'Yes', 'I will get one'],
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
                  CommonTextField(
                    controller: controller.notesController,
                    label: 'Additional Instructions / Notes',
                    hint: '',
                    maxLines: 6,
                    minLines: 4,
                    maxLength: CreateJobController.maxNotesLength,
                    validator: controller.validateNotes,
                  ),
                ],
              ).paddingSymmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ),
        bottomNavigationBar: SingleActionBottomBar(
          label: 'Create',
          isLoading: controller.isSaving.value,
          onPressed: controller.submit,
        ),
      );
    });
  }
}

Future<void> _pickDate(BuildContext context, CreateJobController ctrl) async {
  final d = await showDatePicker(
    context: context,
    initialDate: ctrl.jobStartDate.value ?? DateTime.now(),
    firstDate: DateTime.now(),
    lastDate: DateTime(2030, 12, 31),
  );
  if (d != null && context.mounted) ctrl.setJobStartDate(d);
}

Future<void> _pickTime(BuildContext context, CreateJobController ctrl, {required bool isStart}) async {
  final initial = isStart ? ctrl.startTime.value : ctrl.endTime.value;
  final t = await showTimePicker(
    context: context,
    initialTime: initial ?? const TimeOfDay(hour: 9, minute: 0),
  );
  if (t != null && context.mounted) {
    if (isStart) {
      ctrl.setStartTime(t);
    } else {
      ctrl.setEndTime(t);
    }
  }
}
