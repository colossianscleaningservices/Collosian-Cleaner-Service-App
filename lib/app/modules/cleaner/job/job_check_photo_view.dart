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
                        controller.scheduleValidFrom.value;
                        return CommonTextField(
                          controller: controller.dateDisplayController,
                          label: controller.dateLabel,
                          hint: '-- / -- / ----',
                          isReadOnly: true,
                          /*onTap: () => _pickDate(context, controller),*/
                          validator: (_) => controller.scheduleValidFrom.value == null ? 'Job Start Date is required' : null,
                          suffixIcon: Icon(IconsaxPlusLinear.calendar_1, size: 20, color: scheme.primary),
                        );
                      }).marginOnly(bottom: 16),
                      CommonTextField(
                        controller: controller.startTimeDisplayController,
                        label: controller.timeLabel,
                        hint: '--:--',
                        isReadOnly: true,
                        /*onTap: () => wheelTimePicker(context, controller),*/
                        suffixIcon: Icon(IconsaxPlusLinear.clock, size: 20, color: scheme.primary),
                      ).marginOnly(bottom: 16),
                      Obx(() {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CommonText.semiBold('Photos (${controller.photos.length})', size: 14, color: scheme.onSurfaceVariant),
                            const SizedBox(height: 8),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 1.0,
                              ),
                              itemCount: controller.photos.length + 1,
                              itemBuilder: (context, index) {
                                if (index == 0) {
                                  return _AddPhotoChip(
                                    onTap: () => controller.pickCameraImage(),
                                    scheme: scheme,
                                  );
                                }
                                final photoIndex = index - 1;
                                return _PhotoThumbnail(
                                  file: controller.photos[photoIndex],
                                  onRemove: () => controller.removePhoto(photoIndex),
                                );
                              },
                            ),
                          ],
                        );
                      }),
                    ],
                  )),
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(UiConstants.radiusMedium),
      child: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
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
                child: Icon(IconsaxPlusLinear.image, color: scheme.onSurfaceVariant),
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
                child: Icon(IconsaxPlusLinear.close_circle, size: 18, color: scheme.onError),
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
        decoration: BoxDecoration(
          color: scheme.primaryContainer.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(UiConstants.radiusMedium),
          border: Border.all(color: scheme.primary.withValues(alpha: 0.5)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(IconsaxPlusLinear.add, size: 32, color: scheme.primary),
            const SizedBox(height: 4),
            CommonText.regular('Add Photo', size: 12, color: scheme.primary),
          ],
        ),
      ),
    );
  }
}

Future<void> wheelTimePicker(
  BuildContext context,
  JobCheckPhotoController ctrl,
) async {
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
