import 'package:ccs_app/export.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../model/availability.dart';
import '../../../../widget/common/wheel_picker_time.dart';
import '../cleaner_dashboard_controller.dart';

class CleanerAvailabilityView extends GetView<CleanerDashboardController> {
  const CleanerAvailabilityView({super.key});

  /// 12h format e.g. "09:00 AM", "06:00 PM".
  static String _formatTime(TimeOfDay t) => CcsDateUtils.timeFromTimeOfDay(t);

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;

    return SafeArea(
      child: SingleChildScrollView(
        padding: UiConstants.padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SET SCHEDULE — section header with accent bar and subtitle
            Row(
              children: [
                Container(
                  width: 4,
                  height: 22,
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ).marginOnly(right: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonText.semiBold('Set schedule', size: 18, color: scheme.onSurface).marginOnly(bottom: 2),
                      CommonText.regular(
                        'Set your weekly working hours',
                        size: 12,
                        color: scheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ],
            ).marginOnly(bottom: 20),

            // Day cards: Monday–Sunday, toggle + Add slot + slots (From–To, remove)
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

            const SizedBox(height: 28),
            Row(
              children: [
                Container(
                  width: 4,
                  height: 18,
                  decoration: BoxDecoration(
                    color: scheme.error.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ).marginOnly(right: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonText.semiBold('Blocked days', size: 16, color: scheme.onSurface).marginOnly(bottom: 2),
                      CommonText.regular(
                        'Add dates when you won\'t be available (e.g. vacation, appointments).',
                        size: 12,
                        color: scheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            AppButton(
              label: 'Add blocked days',
              type: ButtonType.outline,
              icon: IconsaxPlusLinear.calendar_add,
              onPressed: () => _pickBlockedDate(context, controller),
              btnVerticalPadding: 10,
              btnHorizontalPadding: 14,
              textSize: 12,
            ),
            const SizedBox(height: 14),
            Obx(() {
              final days = controller.blockedDays;
              if (days.isEmpty) {
                return AppCard(
                  color: scheme.surfaceContainerLow.withValues(alpha: 0.6),
                  borderWidth: 1,
                  borderColor: scheme.outline.withValues(alpha: 0.25),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(UiConstants.radiusMedium),
                        ),
                        child: Icon(IconsaxPlusLinear.calendar_remove, color: scheme.onSurfaceVariant, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CommonText.medium('No blocked days', size: 14, color: scheme.onSurface),
                            const SizedBox(height: 2),
                            CommonText.regular(
                              'Add dates when you\'re away to avoid bookings.',
                              size: 12,
                              color: scheme.onSurfaceVariant,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ).paddingSymmetric(horizontal: 16, vertical: 18),
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
                onPressed: () => controller.setCleanerAvailability(),
                btnVerticalPadding: 14,
                textSize: 16,
              ),
            ),
            const SizedBox(height: UiConstants.gap),
          ],
        ),
      ),
    );
  }
}

Future<void> _pickTime(BuildContext context, CleanerDashboardController ctrl, int dayIndex, int slotIndex, {required bool isStart}) async {
  final list = ctrl.weeklySchedule;
  if (dayIndex < 0 || dayIndex >= list.length) return;
  final slots = list[dayIndex].slots;
  if (slotIndex < 0 || slotIndex >= slots.length) return;
  final slot = slots[slotIndex];
  final initial = isStart ? slot.start : slot.end;
  /*final t = await showTimePicker(context: context, initialTime: initial);
  if (t == null || !context.mounted) return;
  ctrl.updateSlot(dayIndex, slotIndex, start: isStart ? t : null, end: isStart ? null : t);*/
  wheelTimePicker(context, dayIndex, slotIndex, ctrl, isStart: isStart, initial: initial);
}

Future<void> wheelTimePicker(
  BuildContext context,
  int dayIndex,
  int slotIndex,
  CleanerDashboardController ctrl, {
  required bool isStart,
  required TimeOfDay initial,
}) async {
  return Notifier.openSheet(
    context,
    top: true,
    showPrimaryButton: false,
    showSecondaryButton: false,
    showIcon: false,
    body: WheelPickerTime(
      onSelected: (selected) {
        ctrl.updateSlot(dayIndex, slotIndex, start: isStart ? selected : null, end: isStart ? null : selected);
      },
      initial: initial,
    ),
  );
}

Future<void> _pickBlockedDate(BuildContext context, CleanerDashboardController ctrl) async {
  DateTime? rangeStart;
  DateTime? rangeEnd;
  DateTime focusedDay = DateTime.now();

  final DateTimeRange? range = await showDialog<DateTimeRange>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          final scheme = context.colorScheme;
          return AlertDialog(
            contentPadding: EdgeInsets.zero,
            backgroundColor: scheme.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(UiConstants.radiusLarge)),
            content: SizedBox(
              width: 340,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TableCalendar(
                    firstDay: DateTime.now(),
                    lastDay: DateTime(2030, 12, 31),
                    focusedDay: focusedDay,
                    rangeStartDay: rangeStart,
                    rangeEndDay: rangeEnd,
                    rangeSelectionMode: RangeSelectionMode.toggledOn,
                    onRangeSelected: (start, end, focused) {
                      setState(() {
                        rangeStart = start;
                        rangeEnd = end;
                        focusedDay = focused;
                      });
                    },
                    headerStyle: const HeaderStyle(formatButtonVisible: false),
                    calendarStyle: CalendarStyle(
                      rangeHighlightColor: scheme.primary.withValues(alpha: 0.2),
                      rangeStartDecoration: BoxDecoration(color: scheme.primary, shape: BoxShape.circle),
                      rangeEndDecoration: BoxDecoration(color: scheme.primary, shape: BoxShape.circle),
                      todayDecoration: BoxDecoration(color: scheme.secondary, shape: BoxShape.circle),
                    ),
                  ).paddingAll(12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: CommonText.medium('Cancel', color: scheme.primary),
                      ),
                      TextButton(
                        onPressed: () {
                          if (rangeStart != null) {
                            Navigator.pop(context, DateTimeRange(start: rangeStart!, end: rangeEnd ?? rangeStart!));
                          } else {
                            Navigator.pop(context);
                          }
                        },
                        child: CommonText.medium('OK', color: scheme.primary),
                      ),
                    ],
                  ).paddingOnly(right: 16, bottom: 8),
                ],
              ),
            ),
          );
        },
      );
    },
  );

  if (range == null || !context.mounted) return;

  DateTime current = range.start;
  while (!current.isAfter(range.end)) {
    ctrl.addBlockedDay(current);
    current = current.add(const Duration(days: 1));
  }
}

Color _slotRowColor(ColorScheme scheme, int index) {
  return index.isEven ? scheme.primaryContainer.withValues(alpha: 0.5) : scheme.tertiaryContainer.withValues(alpha: 0.5);
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
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      borderWidth: 1,
      borderColor: scheme.outline.withValues(alpha: 0.12),
      color: scheme.surfaceContainerHighest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: CommonText.semiBold(dayName, size: 16, color: scheme.onSurface)),
              Switch.adaptive(
                value: day.enabled,
                onChanged: onEnabledChanged,
                activeTrackColor: scheme.primary.withValues(alpha: 0.3),
                thumbColor: WidgetStateProperty.resolveWith((_) => day.enabled ? scheme.primary : null),
              ).marginOnly(right: 6),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: day.enabled ? onAdd : null,
                  borderRadius: BorderRadius.circular(UiConstants.radiusMedium),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          IconsaxPlusLinear.add,
                          size: 16,
                          color: day.enabled ? scheme.primary : scheme.onSurfaceVariant.withValues(alpha: 0.5),
                        ).marginOnly(right: 6),
                        CommonText.medium('Add slot', size: 12, color: day.enabled ? scheme.primary : scheme.onSurfaceVariant.withValues(alpha: 0.5)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (day.enabled) ...[
            if (day.slots.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerLow.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(UiConstants.radiusDefault),
                  border: Border.all(
                    color: scheme.outline.withValues(alpha: 0.3),
                    width: 1.5,
                    strokeAlign: BorderSide.strokeAlignInside,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(IconsaxPlusLinear.clock, size: 18, color: scheme.onSurfaceVariant).marginOnly(right: 10),
                    CommonText.regular('Tap Add slot to set your hours.', size: 12, color: scheme.onSurfaceVariant),
                  ],
                ),
              ).marginOnly(top: 12)
            else
              ...day.slots.asMap().entries.map((e) {
                final i = e.key;
                final slot = e.value;
                final rowColor = _slotRowColor(scheme, i);
                return Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: _TimeChip(
                          time: CleanerAvailabilityView._formatTime(slot.start),
                          onTap: () => onStartTap(i),
                          backgroundColor: rowColor,
                          scheme: scheme,
                          label: 'From',
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: CommonText.regular('–', size: 14, color: scheme.onSurfaceVariant),
                      ),
                      Expanded(
                        child: _TimeChip(
                          time: CleanerAvailabilityView._formatTime(slot.end),
                          onTap: () => onEndTap(i),
                          backgroundColor: rowColor,
                          scheme: scheme,
                          label: 'To',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Semantics(
                        label: 'Remove slot',
                        button: true,
                        child: Material(
                          color: scheme.error,
                          elevation: 0,
                          shape: const CircleBorder(),
                          child: InkWell(
                            onTap: () => onRemoveSlot(i),
                            customBorder: const CircleBorder(),
                            child: SizedBox(width: 36, height: 36, child: Center(child: Icon(Icons.remove, size: 20, color: scheme.onError))),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ],
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({
    required this.time,
    required this.onTap,
    required this.backgroundColor,
    required this.scheme,
    this.label,
  });

  final String time;
  final VoidCallback onTap;
  final Color backgroundColor;
  final ColorScheme scheme;
  final String? label;

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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (label != null) ...[
                CommonText.regular(label!, size: 12, color: scheme.onSurfaceVariant).marginOnly(right: 8),
              ],
              CommonText.semiBold(time, size: 14, color: scheme.onSurface),
            ],
          ),
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
    return AppCard(
      borderWidth: 1,
      borderColor: scheme.error.withValues(alpha: 0.2),
      color: scheme.errorContainer.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(UiConstants.radiusDefault),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppCard(
                enableShadows: false,
                color: scheme.error.withValues(alpha: 0.04),
                radius: UiConstants.radiusSmall,
                child: Icon(IconsaxPlusLinear.calendar_remove, size: 16, color: scheme.error).paddingAll(6),
              ).marginOnly(right: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CommonText.regular('Blocked', size: 12, color: scheme.onErrorContainer.withValues(alpha: 0.9)).marginOnly(bottom: 1),
                  CommonText.semiBold(CcsDateUtils.shortWithWeekday(date), size: 12, color: scheme.onErrorContainer),
                ],
              ),
            ],
          ).paddingOnly(left: 12, top: 10, bottom: 10),
          IconButton(onPressed: onRemove, icon: Icon(IconsaxPlusLinear.close_circle, size: 20, color: scheme.onErrorContainer)),
        ],
      ),
    );
  }
}
