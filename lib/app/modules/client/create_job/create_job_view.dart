import 'package:intl/intl.dart';

import 'package:ccs_app/export.dart';
import 'create_job_controller.dart';

/// "Create a Cleaning Job" form. Opened from Client Jobs tab.
class CreateJobView extends GetView<CreateJobController> {
  const CreateJobView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create a Cleaning Job'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: controller.formKey,
          child: SingleChildScrollView(
            padding: UiConstants.padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionTitle(label: 'Property & scheduling', scheme: scheme),
                const SizedBox(height: 8),
                _DropdownField<String>(
                  label: 'Property',
                  value: controller.selectedPropertyId.value,
                  hint: 'Select',
                  items: const ['Select', 'Property 1', 'Property 2'],
                  onChanged: (v) => controller.selectedPropertyId.value = v,
                  validator: (_) => controller.validateProperty(controller.selectedPropertyId.value),
                ),
                const SizedBox(height: 12),
                Obx(() => _DateField(
                      label: 'Job Start Date',
                      value: controller.jobStartDate.value,
                      onTap: () => _pickDate(context, controller),
                      onClear: () => controller.setJobStartDate(null),
                      validator: (_) => controller.jobStartDate.value == null ? 'Job Start Date is required' : null,
                      scheme: scheme,
                    )),
                const SizedBox(height: 12),
                Obx(() => Row(
                      children: [
                        Expanded(
                          child: _TimeField(
                            label: 'Start Time',
                            time: controller.startTime.value,
                            onTap: () => _pickTime(context, controller, isStart: true),
                            scheme: scheme,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _TimeField(
                            label: 'End Time',
                            time: controller.endTime.value,
                            onTap: () => _pickTime(context, controller, isStart: false),
                            scheme: scheme,
                          ),
                        ),
                      ],
                    )),
                const SizedBox(height: 12),
                Obx(() => _DropdownField<String>(
                      label: 'Would you like to pay the invoice from your:',
                      value: controller.invoicePaymentSource.value.isEmpty ? null : controller.invoicePaymentSource.value,
                      hint: 'Please select',
                      items: const ['Please select', 'Residential', 'Commercial'],
                      onChanged: (v) => controller.invoicePaymentSource.value = v ?? '',
                      validator: (_) =>
                          (controller.invoicePaymentSource.value.isEmpty || controller.invoicePaymentSource.value == 'Please select')
                              ? 'Payment source is required'
                              : null,
                    )),
                const SizedBox(height: 12),
                Obx(() => _NumberField(
                      label: 'Cleaner(s) Needed?',
                      value: controller.cleanersNeeded.value,
                      onChanged: (v) => controller.cleanersNeeded.value = v.clamp(1, 20),
                      scheme: scheme,
                    )),
                const SizedBox(height: 20),
                _SectionTitle(label: 'Preferences & access', scheme: scheme),
                const SizedBox(height: 8),
                Obx(() => _DropdownField<String>(
                      label: 'Staff Preference',
                      value: controller.staffPreference.value,
                      hint: 'Select',
                      items: const ['Male', 'Female', 'No preference'],
                      onChanged: (v) => controller.staffPreference.value = v ?? 'Male',
                      scheme: scheme,
                    )),
                const SizedBox(height: 12),
                Obx(() => _DropdownField<String>(
                      label: 'Access to Property',
                      value: controller.accessToProperty.value,
                      hint: 'Select',
                      items: const ['Client Will Open', 'Reception/Concierge', 'Key', 'Other'],
                      onChanged: (v) => controller.accessToProperty.value = v ?? 'Client Will Open',
                      scheme: scheme,
                    )),
                const SizedBox(height: 12),
                Obx(() => _DropdownField<String>(
                      label: 'Do you have a hoover?',
                      value: controller.hoover.value,
                      hint: 'Select',
                      items: const ['No', 'Yes', 'I will get one'],
                      onChanged: (v) => controller.hoover.value = v ?? 'No',
                      scheme: scheme,
                    )),
                const SizedBox(height: 12),
                Obx(() => CheckboxListTile(
                      title: CommonText.regular('Check this if you are going to provide cleaning products', size: 14, color: scheme.onSurface),
                      value: controller.provideCleaningProducts.value,
                      onChanged: (v) => controller.provideCleaningProducts.value = v ?? false,
                      controlAffinity: ListTileControlAffinity.leading,
                    )),
                Obx(() => CheckboxListTile(
                      title: CommonText.regular('Do you have a washing machine?', size: 14, color: scheme.onSurface),
                      value: controller.provideWashingMachine.value,
                      onChanged: (v) => controller.provideWashingMachine.value = v ?? false,
                      controlAffinity: ListTileControlAffinity.leading,
                    )),
                Obx(() => CheckboxListTile(
                      title: CommonText.regular('Do you have a dryer?', size: 14, color: scheme.onSurface),
                      value: controller.provideDryer.value,
                      onChanged: (v) => controller.provideDryer.value = v ?? false,
                      controlAffinity: ListTileControlAffinity.leading,
                    )),
                const SizedBox(height: 20),
                _SectionTitle(label: 'Additional', scheme: scheme),
                const SizedBox(height: 8),
                CommonTextField(
                  controller: controller.notesController,
                  label: 'Additional Instructions / Notes',
                  hint: '',
                  maxLines: 4,
                  maxLength: CreateJobController.maxNotesLength,
                  validator: controller.validateNotes,
                ),
                Obx(() => Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: CommonText.regular(
                        '${controller.notesLength.value}/${CreateJobController.maxNotesLength} characters',
                        size: 12,
                        color: scheme.onSurfaceVariant,
                      ),
                    )),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    label: 'Create',
                    type: ButtonType.primary,
                    onPressed: controller.submit,
                    btnVerticalPadding: 14,
                    textSize: 16,
                  ),
                ),
                const SizedBox(height: UiConstants.gap),
              ],
            ),
          ),
        ),
      ),
    );
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.label, required this.scheme});

  final String label;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return CommonText.semiBold(label, size: 16, color: scheme.onSurface);
  }
}

class _DropdownField<T> extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
    this.validator,
    this.scheme,
  });

  final String label;
  final T? value;
  final String hint;
  final List<T> items;
  final ValueChanged<T?> onChanged;
  final FormFieldValidator<String>? validator;
  final ColorScheme? scheme;

  @override
  Widget build(BuildContext context) {
    final s = scheme ?? context.colorScheme;
    return FormField<String>(
      validator: validator,
      builder: (ff) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (label.isNotEmpty) ...[
              CommonText.medium(label, size: 14, color: s.onSurface),
              const SizedBox(height: 6),
            ],
            InputDecorator(
              decoration: buildCommonDecoration(
                context: context,
                hint: hint,
                suffixIcon: const Icon(Icons.arrow_drop_down),
                borderColor: ff.hasError ? s.error : null,
              ).copyWith(
                errorText: ff.errorText,
              ),
              isEmpty: value == null || value.toString() == hint,
              child: DropdownButtonHideUnderline(
                child: DropdownButton<T>(
                  value: value == null || (items.isNotEmpty && value == items.first && items.first.toString() == hint) ? null : value,
                  hint: CommonText.regular(hint, size: 14, color: s.onSurfaceVariant),
                  isExpanded: true,
                  items: items.map((e) => DropdownMenuItem<T>(value: e, child: Text(e.toString()))).toList(),
                  onChanged: onChanged,
                ),
              ),
            ),
            if (ff.hasError) ...[
              const SizedBox(height: 4),
              CommonText.regular(ff.errorText ?? '', size: 12, color: s.error),
            ],
          ],
        );
      },
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
    this.onClear,
    required this.validator,
    required this.scheme,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onTap;
  final VoidCallback? onClear;
  final FormFieldValidator<String>? validator;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      validator: validator,
      initialValue: value != null ? DateFormat('MM/dd/yyyy').format(value!) : null,
      builder: (ff) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommonText.medium(label, size: 14, color: scheme.onSurface),
            const SizedBox(height: 6),
            Material(
              color: context.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(UiConstants.radiusDefault),
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(UiConstants.radiusDefault),
                child: InputDecorator(
                  decoration: buildCommonDecoration(
                    context: context,
                    hint: '-- / -- / ----',
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (value != null && onClear != null)
                          IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: onClear,
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(4),
                          ),
                        Icon(Icons.calendar_today, size: 20, color: scheme.primary),
                      ],
                    ),
                  ),
                  isEmpty: value == null,
                  child: Text(value != null ? DateFormat('MM/dd/yyyy').format(value!) : '', style: TextStyle(fontSize: 14, color: scheme.onSurface)),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TimeField extends StatelessWidget {
  const _TimeField({required this.label, required this.time, required this.onTap, required this.scheme});

  final String label;
  final TimeOfDay? time;
  final VoidCallback onTap;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final t = time;
    final str = t != null ? '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}' : '--:--';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText.medium(label, size: 14, color: scheme.onSurface),
        const SizedBox(height: 6),
        Material(
          color: context.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(UiConstants.radiusDefault),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(UiConstants.radiusDefault),
            child: InputDecorator(
              decoration: buildCommonDecoration(context: context, hint: '--:--'),
              isEmpty: time == null,
              child: CommonText.regular(str, size: 14, color: scheme.onSurface),
            ),
          ),
        ),
      ],
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({required this.label, required this.value, required this.onChanged, required this.scheme});

  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText.medium(label, size: 14, color: scheme.onSurface),
        const SizedBox(height: 6),
        Row(
          children: [
            IconButton.filled(
              onPressed: () => onChanged(value - 1),
              icon: const Icon(Icons.remove, size: 20),
              style: IconButton.styleFrom(
                backgroundColor: scheme.primaryContainer,
                foregroundColor: scheme.primary,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CommonText.semiBold('$value', size: 18, color: scheme.onSurface),
            ),
            IconButton.filled(
              onPressed: () => onChanged(value + 1),
              icon: const Icon(Icons.add, size: 20),
              style: IconButton.styleFrom(
                backgroundColor: scheme.primaryContainer,
                foregroundColor: scheme.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
