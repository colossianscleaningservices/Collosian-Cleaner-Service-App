import 'package:ccs_app/app/widget/layout/app_scaffold.dart';
import 'package:ccs_app/app/widget/layout/bottom_action_bar.dart';
import 'package:ccs_app/export.dart';

import 'schedule_job_controller.dart';

/// Schedule job page: start date, frequency, repeat day, copy cleaners.
class ScheduleJobView extends GetView<ScheduleJobController> {
  const ScheduleJobView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final c = controller;
    final propertyLabel = c.job.value?.property?.propertyName;

    return AppScaffold(
      appBar: Header(
        title: 'Schedule job',
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
                'Schedule job on property $propertyLabel',
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
                'When should this schedule begin? Must be tomorrow or a future date.',
                size: 12,
                color: scheme.onSurfaceVariant,
              ).marginOnly(bottom: 16, top: 4),
              if (c.hasRequiredJobTimes) ...[
                CommonTextField(
                  controller: c.jobTimeDisplayController,
                  label: 'Job time',
                  isReadOnly: true,
                  suffixIcon: Icon(IconsaxPlusLinear.clock, size: 20, color: scheme.onSurfaceVariant),
                ),
                CommonText.regular(
                  'Start and end times are taken from this job automatically.',
                  size: 12,
                  color: scheme.onSurfaceVariant,
                ).marginOnly(bottom: 16, top: 4),
              ] else ...[
                AppCard(
                  color: scheme.errorContainer,
                  enableShadows: false,
                  child: CommonText.regular(
                    'This job must have start and end times before it can be scheduled.',
                    size: 14,
                    color: scheme.onErrorContainer,
                  ).paddingAll(12),
                ),
              ],
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
              Obx(() {
                if (!c.needsRepeatOnDay) return const SizedBox.shrink();
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
              }),
              Obx(() {
                return AppCheckBox(
                  title: 'Copy cleaners from parent job',
                  value: c.copyCleanersFromParent.value,
                  onChange: (v) => c.copyCleanersFromParent.value = v,
                ).marginOnly(top: c.frequency.value == 'Weekly' || c.frequency.value == 'Fortnightly' ? 16 : 0);
              }),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SingleActionBottomBar(label: 'Schedule job', onPressed: () => c.submit()),
    );
  }
}
