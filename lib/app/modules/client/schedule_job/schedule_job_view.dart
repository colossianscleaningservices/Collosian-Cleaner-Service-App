import 'package:ccs_app/app/widget/layout/app_scaffold.dart';
import 'package:ccs_app/app/widget/layout/bottom_action_bar.dart';
import 'package:ccs_app/export.dart';

import '../../../widget/common/wheel_picker_time.dart';
import 'schedule_job_controller.dart';

/// Schedule job page: start date, job times, frequency, repeat day, copy cleaners.
class ScheduleJobView extends GetView<ScheduleJobController> {
  const ScheduleJobView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final c = controller;
    final propertyLabel = c.job.value?.property?.propertyName;

    return Obx(() {
      return AppScaffold(
        appBar: Header(
          title: c.pageTitle,
          headerLogoIcon: false,
          hasBackIcon: true,
          titleCentered: false,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: UiConstants.padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CommonText.semiBold(
                  '${c.isEditMode.value ? 'Edit schedule' : 'Schedule job'} on property $propertyLabel',
                  size: 18,
                  color: scheme.onSurface,
                ).marginOnly(bottom: 16),
                CommonTextField(
                  controller: c.startDateDisplayController,
                  label: 'Start date *',
                  hint: '-- / -- / ----',
                  isReadOnly: true,
                  onTap: () => c.pickStartDate(context),
                  suffixIcon: Icon(IconsaxPlusLinear.calendar_1, size: 20, color: scheme.primary),
                ),
                CommonText.regular(
                  c.isEditMode.value
                      ? 'Schedule start date. Cannot be in the past.'
                      : 'When should this schedule begin? Must be tomorrow or a future date.',
                  size: 12,
                  color: scheme.onSurfaceVariant,
                ).marginOnly(bottom: 16, top: 4),
                CommonTextField(
                  controller: c.startTimeDisplayController,
                  label: 'Start time *',
                  hint: '--:--',
                  isReadOnly: true,
                  onTap: () => _wheelTimePicker(context, c, isStart: true),
                  suffixIcon: Icon(IconsaxPlusLinear.clock, size: 20, color: scheme.primary),
                ).marginOnly(bottom: 16),
                CommonTextField(
                  controller: c.endTimeDisplayController,
                  label: 'End time *',
                  hint: '--:--',
                  isReadOnly: true,
                  onTap: () => _wheelTimePicker(context, c, isStart: false),
                  suffixIcon: Icon(IconsaxPlusLinear.clock, size: 20, color: scheme.primary),
                ),
                CommonText.regular(
                  'Set the job start and end times for this schedule.',
                  size: 12,
                  color: scheme.onSurfaceVariant,
                ).marginOnly(bottom: 16, top: 4),
                CommonDropDownField<String>(
                  label: 'Frequency *',
                  hint: 'Select',
                  items: frequencyOptions,
                  itemLabel: (v) => v,
                  value: c.frequency.value,
                  onChanged: (v) {
                    if (v != null) c.frequency.value = v;
                  },
                ).marginOnly(bottom: 16),
                if (c.needsRepeatOnDay) ...[
                  Builder(
                    builder: (_) {
                      final selectedIndex = repeatOnDayValues.indexOf(c.repeatOnDay.value).clamp(0, repeatOnDayValues.length - 1);
                      return CommonDropDownField<String>(
                        label: 'Repeat on day *',
                        hint: 'Select',
                        items: repeatOnDayLabels,
                        itemLabel: (v) => v,
                        value: repeatOnDayLabels[selectedIndex],
                        onChanged: (v) {
                          final index = v != null ? repeatOnDayLabels.indexOf(v) : -1;
                          if (index >= 0) c.repeatOnDay.value = repeatOnDayValues[index];
                        },
                      );
                    },
                  ),
                ],
                AppCheckBox(
                  title: 'Copy cleaners from parent job',
                  value: c.copyCleanersFromParent.value,
                  onChange: (v) => c.copyCleanersFromParent.value = v,
                ).marginOnly(top: c.needsRepeatOnDay ? 16 : 0),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        bottomNavigationBar: SingleActionBottomBar(label: c.submitLabel, onPressed: () => c.submit()),
      );
    });
  }
}

Future<void> _wheelTimePicker(
  BuildContext context,
  ScheduleJobController ctrl, {
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
      title: isStart ? 'Select start time' : 'Select end time',
      initial: initial,
    ),
  );
}
