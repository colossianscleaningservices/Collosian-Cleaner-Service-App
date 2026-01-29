import 'package:ccs_app/export.dart';
import 'package:intl/intl.dart';

import '../../../model/availability.dart';
import 'cleaner_dashboard_controller.dart';

class CleanerAvailabilityView extends GetView<CleanerDashboardController> {
  const CleanerAvailabilityView({super.key});

  /// 12h format e.g. "09:00 AM", "06:00 PM".
  static String _formatTime(TimeOfDay t) => DateFormat.jm().format(DateTime(2000, 1, 1, t.hour, t.minute));

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;

    return SafeArea(
      child: SingleChildScrollView(
        padding: UiConstants.padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SET SCHEDULE with underline (per screenshot)
            CommonText.semiBold('SET SCHEDULE', size: 16, color: scheme.onSurface),
            const SizedBox(height: 4),
            Container(height: 2, width: 160, color: scheme.onSurface.withValues(alpha: 0.5)),
            const SizedBox(height: 16),

            // Date range: From | To with calendar icon
            /*Obx(
              () => Row(
                children: [
                  Expanded(
                    child: _DateField(
                      value: controller.scheduleValidFrom.value,
                      onTap: () => _pickDate(context, controller, isFrom: true),
                      scheme: scheme,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DateField(
                      value: controller.scheduleValidTo.value,
                      onTap: () => _pickDate(context, controller, isFrom: false),
                      scheme: scheme,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),*/

            // Day cards: Monday–Sunday, toggle + Add + slots (From–To, red minus, alternating green/pink)
            Obx(() {
              final list = controller.weeklySchedule;
              if (list.isEmpty) return const SizedBox.shrink();
              return Column(
                children: List.generate(
                  7,
                  (i) => _DayCard(
                    dayName: kDayNames[i],
                    day: list[i],
                    onEnabledChanged: (v) => controller.updateDay(i, enabled: v),
                    onAdd: () => controller.addSlot(i),
                    onRemoveSlot: (si) => controller.removeSlot(i, si),
                    onStartTap: (si) => _pickTime(context, controller, i, si, isStart: true),
                    onEndTap: (si) => _pickTime(context, controller, i, si, isStart: false),
                    scheme: scheme,
                  ),
                ),
              );
            }),

            const SizedBox(height: 16),
            CommonText.semiBold('Blocked days', size: 16, color: scheme.onSurface),
            CommonText.regular(
              'Add specific dates when you won\'t be available (e.g. vacation, appointments).',
              size: 13,
              color: scheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            AppButton(
              label: 'Add blocked day',
              type: ButtonType.outline,
              icon: IconsaxPlusLinear.calendar_add,
              onPressed: () => _pickBlockedDate(context, controller),
              btnVerticalPadding: 10,
              btnHorizontalPadding: 14,
              textSize: 13,
            ),
            const SizedBox(height: 12),
            Obx(() {
              final days = controller.blockedDays;
              if (days.isEmpty) {
                return Card(
                  margin: EdgeInsets.zero,
                  color: context.colorScheme.onPrimary,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Icon(IconsaxPlusLinear.calendar_remove, color: scheme.onSurfaceVariant, size: 20),
                        const SizedBox(width: 12),
                        CommonText.regular('No blocked days.', size: 13, color: scheme.onSurfaceVariant),
                      ],
                    ),
                  ),
                );
              }
              final sorted = List<DateTime>.from(days)..sort();
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: sorted.map((d) => _BlockedChip(date: d, onRemove: () => controller.removeBlockedDay(d), scheme: scheme)).toList(),
              );
            }),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                label: 'Update',
                type: ButtonType.primary,
                onPressed: () => Notifier.info('Schedule updated (API coming soon)'),
                btnVerticalPadding: 14,
                textSize: 15,
              ),
            ),
            const SizedBox(height: UiConstants.gap),
          ],
        ),
      ),
    );
  }
}

Future<void> _pickDate(BuildContext context, CleanerDashboardController ctrl, {required bool isFrom}) async {
  final initial = isFrom ? ctrl.scheduleValidFrom.value : ctrl.scheduleValidTo.value;
  final d = await showDatePicker(context: context, initialDate: initial, firstDate: DateTime(2020, 1, 1), lastDate: DateTime(2030, 12, 31));
  if (d == null || !context.mounted) return;
  if (isFrom) {
    ctrl.setScheduleValidFrom(d);
  } else {
    ctrl.setScheduleValidTo(d);
  }
}

Future<void> _pickTime(BuildContext context, CleanerDashboardController ctrl, int dayIndex, int slotIndex, {required bool isStart}) async {
  final list = ctrl.weeklySchedule;
  if (dayIndex < 0 || dayIndex >= list.length) return;
  final slots = list[dayIndex].slots;
  if (slotIndex < 0 || slotIndex >= slots.length) return;
  final slot = slots[slotIndex];
  final initial = isStart ? slot.start : slot.end;
  final t = await showTimePicker(context: context, initialTime: initial);
  if (t == null || !context.mounted) return;
  ctrl.updateSlot(dayIndex, slotIndex, start: isStart ? t : null, end: isStart ? null : t);
}

Future<void> _pickBlockedDate(BuildContext context, CleanerDashboardController ctrl) async {
  final d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2030, 12, 31));
  if (d == null || !context.mounted) return;
  ctrl.addBlockedDay(d);
}

class _DateField extends StatelessWidget {
  const _DateField({required this.value, required this.onTap, required this.scheme});

  final DateTime value;
  final VoidCallback onTap;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(UiConstants.radiusDefault),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(UiConstants.radiusDefault),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Expanded(child: CommonText.medium(DateFormat('yyyy-MM-dd').format(value), size: 14, color: scheme.onSurface)),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: scheme.primary.withValues(alpha: 0.25), shape: BoxShape.circle),
                child: Icon(IconsaxPlusLinear.calendar_1, size: 18, color: scheme.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Color _slotRowColor(ColorScheme scheme, int index) {
  return index.isEven ? scheme.primary.withValues(alpha: 0.1) : const Color(0xFFFCE4EC);
}

class _DayCard extends StatelessWidget {
  const _DayCard({
    required this.dayName,
    required this.day,
    required this.onEnabledChanged,
    required this.onAdd,
    required this.onRemoveSlot,
    required this.onStartTap,
    required this.onEndTap,
    required this.scheme,
  });

  final String dayName;
  final DayAvailability day;
  final ValueChanged<bool> onEnabledChanged;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemoveSlot;
  final ValueChanged<int> onStartTap;
  final ValueChanged<int> onEndTap;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row: Day name | Toggle | Add (per screenshot)
          Row(
            children: [
              Expanded(child: CommonText.semiBold(dayName, size: 14, color: scheme.onSurface)),
              Switch.adaptive(
                value: day.enabled,
                onChanged: onEnabledChanged,
                activeTrackColor: scheme.primary.withValues(alpha: 0.2),
                thumbColor: WidgetStateProperty.resolveWith((_) => day.enabled ? scheme.primary.withValues(alpha: 0.6) : null),
              ),
              const SizedBox(width: 4),
              TextButton(
                onPressed: day.enabled ? onAdd : null,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: CommonText.medium('Add', size: 14, color: day.enabled ? scheme.primary : scheme.onSurfaceVariant),
              ),
            ],
          ),

          // Slots: [From] To [To] [red minus] — alternating light green / light pink
          if (day.enabled) ...[
            if (day.slots.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: CommonText.regular('Tap Add to set your hours.', size: 12, color: scheme.onSurfaceVariant),
              )
            else
              ...day.slots.asMap().entries.map((e) {
                final i = e.key;
                final slot = e.value;
                final rowColor = _slotRowColor(scheme, i);
                return Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    children: [
                      _TimeChip(
                        time: CleanerAvailabilityView._formatTime(slot.start),
                        onTap: () => onStartTap(i),
                        backgroundColor: rowColor,
                        scheme: scheme,
                      ),
                      const SizedBox(width: 8),
                      CommonText.regular('To', size: 13, color: scheme.onSurfaceVariant),
                      const SizedBox(width: 8),
                      _TimeChip(
                        time: CleanerAvailabilityView._formatTime(slot.end),
                        onTap: () => onEndTap(i),
                        backgroundColor: rowColor,
                        scheme: scheme,
                      ),
                      const SizedBox(width: 10),
                      Material(
                        color: scheme.error,
                        shape: const CircleBorder(),
                        child: InkWell(
                          onTap: () => onRemoveSlot(i),
                          customBorder: const CircleBorder(),
                          child: const Padding(
                            padding: EdgeInsets.all(8),
                            child: Icon(Icons.remove, size: 18, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ],
      ).paddingSymmetric(horizontal: 14, vertical: 12),
    ).marginOnly(bottom: 12);
  }
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({required this.time, required this.onTap, required this.backgroundColor, required this.scheme});

  final String time;
  final VoidCallback onTap;
  final Color backgroundColor;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(UiConstants.radiusDefault),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(UiConstants.radiusDefault),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: CommonText.semiBold(time, size: 14, color: scheme.onSurface),
        ),
      ),
    );
  }
}

class _BlockedChip extends StatelessWidget {
  const _BlockedChip({required this.date, required this.onRemove, required this.scheme});

  final DateTime date;
  final VoidCallback onRemove;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: scheme.errorContainer.withValues(alpha: 0.4),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onRemove,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(IconsaxPlusLinear.calendar_remove, size: 16, color: scheme.onErrorContainer),
              const SizedBox(width: 6),
              CommonText.medium(DateFormat('EEE d MMM yyyy').format(date), size: 13, color: scheme.onErrorContainer),
              const SizedBox(width: 6),
              Icon(IconsaxPlusLinear.close_circle, size: 18, color: scheme.onErrorContainer),
            ],
          ),
        ),
      ),
    );
  }
}
