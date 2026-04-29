import 'package:flutter/cupertino.dart';

import '../../../export.dart';

class WheelPickerTime extends StatelessWidget {
  const WheelPickerTime({super.key, this.title = 'Select Time', this.initial, required this.onSelected});

  final String title;
  final TimeOfDay? initial;
  final Function(TimeOfDay) onSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    var selected = TimeOfDay(
      hour: (initial ?? TimeOfDay.now()).hour,
      minute: (initial ?? TimeOfDay.now()).minute,
    );
    return StatefulBuilder(
      builder: (context, setState) =>
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              CommonText.semiBold(
                title,
                size: 16,
                color: scheme.onSurface,
              ).marginOnly(bottom: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.schedule_rounded, size: 18, color: scheme.primary),
                    const SizedBox(width: 8),
                    CommonText.medium(
                      selected.format(context),
                      size: 16,
                      color: scheme.primary,
                    ),
                  ],
                ),
              ).marginOnly(bottom: 10),
              Container(
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.7)),
                ),
                child: CupertinoTheme(
                  data: CupertinoThemeData(
                    brightness: Theme
                        .of(context)
                        .brightness,
                    primaryColor: scheme.primary,
                    textTheme: CupertinoTextThemeData(
                      dateTimePickerTextStyle: TextStyle(
                        color: scheme.onSurface,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  child: SizedBox(
                    height: 180,
                    width: double.infinity,
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.time,
                      use24hFormat: false,
                      backgroundColor: Colors.transparent,
                      initialDateTime: DateTime(
                        2025,
                        1,
                        1,
                        selected.hour,
                        selected.minute,
                      ),
                      onDateTimeChanged: (value) {
                        setState(
                              () =>
                          selected = TimeOfDay(
                            hour: value.hour,
                            minute: value.minute,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Cancel',
                      onPressed: Get.back,
                      type: ButtonType.tonal,
                    ).marginOnly(right: 8),
                  ),
                  Expanded(
                    child: AppButton(
                      label: 'Select',
                      onPressed: () {
                        onSelected(selected);
                        Get.back();
                      },
                    ).marginOnly(left: 8),
                  ),
                ],
              ),
            ],
          ),
    );
  }
}
