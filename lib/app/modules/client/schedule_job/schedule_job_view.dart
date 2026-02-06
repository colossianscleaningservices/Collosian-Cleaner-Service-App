import 'package:ccs_app/app/widget/layout/app_scaffold.dart';
import 'package:ccs_app/app/widget/layout/bottom_action_bar.dart';
import 'package:ccs_app/export.dart';

import 'schedule_job_controller.dart';

/// Schedule job page: start/end date & time, frequency, repeat on weekdays, copy cleaners.
class ScheduleJobView extends GetView<ScheduleJobController> {
  const ScheduleJobView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final c = controller;
    final propertyLabel = c.job.propertyLabel ?? c.job.propertyOneLine;

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
            spacing: 16,
            children: [
              CommonText.semiBold(
                'Schedule job on property $propertyLabel',
                size: 18,
                color: scheme.onSurface,
              ),
              const SizedBox(height: 8),
              CommonTextField(
                controller: c.startDateDisplayController,
                label: 'Start date *',
                hint: '-- / -- / ----',
                isReadOnly: true,
                onTap: () => c.pickStartDate(context),
                suffixIcon: Icon(IconsaxPlusLinear.calendar_1, size: 20, color: scheme.primary),
              ),
              CommonText.regular(
                'When should this recurring schedule begin? Must be today or later.',
                size: 12,
                color: scheme.onSurfaceVariant,
              ),
              CommonTextField(
                controller: c.startTimeDisplayController,
                label: 'Start time',
                hint: '--:--',
                isReadOnly: true,
                onTap: () => c.pickStartTime(context),
                suffixIcon: Icon(IconsaxPlusLinear.clock, size: 20, color: scheme.primary),
              ),
              CommonTextField(
                controller: c.endDateDisplayController,
                label: 'End date',
                hint: '-- / -- / ----',
                isReadOnly: true,
                onTap: () => c.pickEndDate(context),
                suffixIcon: Obx(() {
                  final hasEnd = c.endDate.value != null;
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (hasEnd)
                        IconButton(
                          icon: Icon(Icons.close, size: 18, color: scheme.onSurfaceVariant),
                          onPressed: c.clearEndDate,
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(4),
                        ),
                      Icon(IconsaxPlusLinear.calendar_1, size: 20, color: scheme.primary),
                    ],
                  );
                }),
              ),
              CommonText.regular(
                'Optional. Must be after the start date. Leave empty for indefinite recurrence.',
                size: 12,
                color: scheme.onSurfaceVariant,
              ),
              CommonTextField(
                controller: c.endTimeDisplayController,
                label: 'End time',
                hint: '--:--',
                isReadOnly: true,
                onTap: () => c.pickEndTime(context),
                suffixIcon: Icon(IconsaxPlusLinear.clock, size: 20, color: scheme.primary),
              ),
              CommonDropDownField<String>(
                label: 'Frequency',
                hint: 'Select',
                items: frequencyOptions,
                itemLabel: (v) => v,
                value: c.frequency.value,
                onChanged: (v) {
                  if (v != null) c.frequency.value = v;
                },
              ),
              Obx(() {
                if (c.frequency.value == 'Weekly') {
                  return CommonDropDownField<String>(
                    label: 'Repeat every',
                    hint: 'Select',
                    items: repeatEveryWeekOptions,
                    itemLabel: (v) => v,
                    value: repeatEveryWeekOptions[c.repeatEveryWeekIndex.value.clamp(0, repeatEveryWeekOptions.length - 1)],
                    onChanged: (v) {
                      final i = v != null ? repeatEveryWeekOptions.indexOf(v) : 0;
                      if (i >= 0) c.repeatEveryWeekIndex.value = i;
                    },
                  );
                }
                if (c.frequency.value == 'Daily') {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonText.medium('Repeat every', size: 14, color: scheme.onSurface),
                        const SizedBox(height: 6),
                        CommonText.regular('Every day', size: 14, color: scheme.onSurfaceVariant),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
              Obx(() {
                if (c.frequency.value != 'Weekly') return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText.medium('Repeat on', size: 14, color: scheme.onSurface),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(7, (i) {
                        final weekday = i + 1; // 1=Mon .. 7=Sun
                        final selected = c.repeatOnWeekdays.contains(weekday);
                        return GestureDetector(
                          onTap: () => c.toggleRepeatOnWeekday(weekday),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: selected ? scheme.primary : scheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(UiConstants.radiusDefault),
                            ),
                            child: CommonText.medium(
                              weekdayLabels[i],
                              size: 13,
                              color: selected ? scheme.onPrimary : scheme.onSurfaceVariant,
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                );
              }),
              Obx(() {
                return CheckboxListTile(
                  value: c.copyCleanersFromParent.value,
                  onChanged: (v) => c.copyCleanersFromParent.value = v ?? false,
                  title: CommonText.regular('Copy cleaners from parent job', size: 14, color: scheme.onSurface),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  activeColor: scheme.primary,
                );
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
