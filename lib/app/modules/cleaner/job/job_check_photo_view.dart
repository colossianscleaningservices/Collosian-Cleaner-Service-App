import 'dart:io';

import 'package:ccs_app/app/widget/layout/app_scaffold.dart';
import 'package:ccs_app/export.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:image_picker/image_picker.dart';

import '../../../widget/common/wheel_picker_time.dart';
import 'job_check_photo_controller.dart';

class JobCheckPhotoView extends GetView<JobCheckPhotoController> {
  const JobCheckPhotoView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return AppScaffold(
      appBar: Header(
        title: controller.pageTitle,
        subtitle: controller.pageSubtitle,
        hasBackIcon: true,
        titleCentered: false,
      ),
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                  padding: UiConstants.padding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Obx(() {
                        return CommonTextField(
                          controller: controller.dateDisplayController,
                          label: controller. dateLabel,
                          hint: '-- / -- / ----',
                          isReadOnly: true,
                          onTap: () => _pickDate(context, controller),
                          validator: (_) => controller.scheduleValidFrom.value == null ? 'Job Start Date is required' : null,
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (controller.scheduleValidFrom.value != null)
                                IconButton(
                                  icon: const Icon(Icons.close, size: 18),
                                  onPressed: () => controller.scheduleValidFrom(null),
                                  constraints: const BoxConstraints(),
                                  padding: const EdgeInsets.all(4),
                                ),
                              Icon(Icons.calendar_today, size: 20, color: scheme.primary).marginOnly(right: 12),
                            ],
                          ),
                        );
                      }).marginOnly(bottom: 16),
                       CommonTextField(
                          controller: controller.startTimeDisplayController,
                          label: controller.timeLabel,
                          hint: '--:--',
                          isReadOnly: true,
                          onTap: () => wheelTimePicker(context, controller),
                          suffixIcon: Icon(Icons.access_time, size: 20, color: scheme.primary),
                        ).marginOnly(bottom: 16),
                      Obx(() {
                        if (controller.photos.isEmpty) {
                          return GestureDetector(
                            onTap: () => controller.showPhotoSourceSheet(context),
                            child: Container(
                              height: 160,
                              decoration: BoxDecoration(
                                color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(UiConstants.radiusLarge),
                                border: Border.all(color: scheme.outline.withValues(alpha: 0.5)),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(IconsaxPlusLinear.gallery_add, size: 48, color: scheme.primary),
                                  const SizedBox(height: 8),
                                  CommonText.regular('Tap to add photos', size: 14, color: scheme.onSurfaceVariant),
                                ],
                              ),
                            ),
                          );
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CommonText.semiBold('Photos (${controller.photos.length})', size: 14, color: scheme.onSurfaceVariant),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                ...List.generate(
                                    controller.photos.length, (i) => _PhotoThumbnail(file: controller.photos[i], onRemove: () => controller.removePhoto(i))),
                                _AddPhotoChip(onTap: () => controller.showPhotoSourceSheet(context), scheme: scheme),
                              ],
                            ),
                          ],
                        );
                      }),
                    ],
                  )

              ),
            ),
            Padding(
              padding: UiConstants.padding,
              child: AppButton(
                label: controller.submitLabel,
                onPressed: controller.submit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoThumbnail extends StatelessWidget {
  const _PhotoThumbnail({required this.file, required this.onRemove});

  final XFile file;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return SizedBox(
      width: 96,
      height: 96,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(UiConstants.radiusMedium),
            child: GestureDetector(
              onTap: () {
                var multiImageProvider = MultiImageProvider(
                  [FileImage(File(file.path))].toList(),
                  initialIndex: 0,
                );
                showImageViewerPager(
                  context,
                  useSafeArea: true,
                  multiImageProvider,
                  swipeDismissible: true,
                  backgroundColor: context.colorScheme.surface,
                  closeButtonColor: context.colorScheme.secondary,
                  doubleTapZoomable: true,
                );
              },
              child: Image.file(
                File(file.path),
                key: ValueKey(file.path),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: scheme.surfaceContainerHighest,
                  alignment: Alignment.center,
                  child: Icon(Icons.broken_image_outlined, color: scheme.onSurfaceVariant),
                ),
              ),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onRemove,
              child: CircleAvatar(
                radius: 14,
                backgroundColor: scheme.error,
                child: Icon(Icons.close, size: 18, color: scheme.onError),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddPhotoChip extends StatelessWidget {
  const _AddPhotoChip({required this.onTap, required this.scheme});

  final VoidCallback onTap;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 96,
        height: 96,
        decoration: BoxDecoration(
          color: scheme.primaryContainer.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(UiConstants.radiusMedium),
          border: Border.all(color: scheme.primary.withValues(alpha: 0.5)),
        ),
        child: Icon(IconsaxPlusLinear.add, size: 32, color: scheme.primary),
      ),
    );
  }
}

Future<void> _pickDate(BuildContext context, JobCheckPhotoController ctrl) async {
  final d = await showDatePicker(
    context: context,
    initialDate: ctrl.scheduleValidFrom.value?.isBefore(DateTime.now()) == true ? DateTime.now() : ctrl.scheduleValidFrom.value ?? DateTime.now(),
    firstDate: DateTime.now(),
    lastDate: DateTime(DateTime.now().year + 5, 12, 31),
  );
  if (d != null && context.mounted) ctrl.setScheduleValidFrom(d);
}

/*Future<void> _pickTime(BuildContext context, JobCheckPhotoController ctrl) async {
  final t = await showTimePicker(
    context: context,
    initialTime: const TimeOfDay(hour: 9, minute: 0),
  );

  ctrl.setStartTime(t);
}*/

Future<void> wheelTimePicker(
    BuildContext context,
    JobCheckPhotoController ctrl,) async {
  return Notifier.openSheet(
    context,
    top: true,
    showPrimaryButton: false,
    showSecondaryButton: false,
    showIcon: false,
    body: WheelPickerTime(
      onSelected: (selected) {
        ctrl.setStartTime(selected);
      },
    ),
  );
}