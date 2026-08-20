import 'package:ccs_app/app/widget/layout/bottom_action_bar.dart';

import '../../../../../export.dart';
import '../../../../widget/layout/app_scaffold.dart';
import '../support_document_controller.dart';

class AddDocumentView extends GetView<SupportDocumentController> {
  const AddDocumentView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return AppScaffold(
        appBar: Header(title: controller.isEditingDocument.value ? 'Update Document' : "Add New Document"),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonDropDownField(
                  itemLabel: (value) => value.toString(),
                  hint: 'Select Document',
                  label: "Document Type *",
                  onChanged: (value) {
                    if (value != null) controller.document.value = value;
                  },
                  items: controller.documentTypeOptions,
                  value: controller.document.value,
                ).marginOnly(bottom: 18),
                CommonTextField(
                  controller: controller.documentCtrl,
                  label: 'Document Number *',
                  hint: 'Enter document number',
                  keyboardType: TextInputType.phone,
                ).marginOnly(bottom: 18),
                Obx(() => _DateField(
                      label: 'Expiry Date *',
                      value: controller.jobStartDate.value,
                      onTap: () => _pickDate(context, controller),
                      onClear: () => controller.setJobStartDate(null),
                      validator: (_) => controller.jobStartDate.value == null ? 'Expiry date is required' : null,
                      scheme: scheme,
                      ctrl: controller,
                    )).marginOnly(bottom: 18),
                InkWell(
                  onTap: () async {
                    showPicker(
                      primaryText: 'Choose from File Manager',
                      primarySubtitle: 'Select from your file manager',
                      galleryPicker: () => controller.getFiles(),
                      cameraPicker: () => controller.getImageFromCamera(),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Transform.rotate(angle: 74.8, child: const Icon(IconsaxPlusLinear.paperclip, color: Colors.black54)).marginOnly(right: 8),
                      CommonText.semiBold("Attach file *", size: 14, color: scheme.onSurface),
                    ],
                  ).marginSymmetric(vertical: 8).marginSymmetric(horizontal: 4),
                ),
                Obx(() {
                  return Visibility(
                    visible: controller.isEditingDocument.value || controller.pickedFiles.isNotEmpty,
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return AppCard(
                          onTap: null,
                          color: Colors.white,
                          radius: 8,
                          shadowColor: Colors.black.withValues(alpha: 0.1),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Row(
                                  children: [
                                    Icon(
                                      controller.pickedFiles.isEmpty && controller.isEditingDocument.value
                                          ? controller.getIcon(controller.selectedDocument.value?.documentUrl ?? '')
                                          : controller.getIcon(controller.pickedFiles[index].path),
                                      size: 18,
                                      color: Colors.grey,
                                    ).marginOnly(right: 6),
                                    Flexible(
                                      child: CommonText.regular(
                                        controller.pickedFiles.isEmpty && controller.isEditingDocument.value
                                            ? controller.selectedDocument.value?.documentUrl?.split('/').last ?? 'Dummy File'
                                            : controller.pickedFiles[index].path.toString().split('/').last,
                                        color: context.colorScheme.primary,
                                      ).paddingSymmetric(vertical: controller.pickedFiles.isEmpty ? 12 : 0),
                                    ),
                                  ],
                                ).paddingSymmetric(horizontal: 10),
                              ),
                              controller.pickedFiles.isEmpty
                                  ? SizedBox.shrink()
                                  : IconButton(
                                      onPressed: () {
                                        if (controller.pickedFiles.isNotEmpty) {
                                          controller.pickedFiles.removeAt(index);
                                        }
                                        log(runtimeType.toString(), "Delete File: ${controller.pickedFiles.length}");
                                      },
                                      highlightColor: Colors.red.withValues(alpha: 0.1),
                                      icon: const Icon(
                                        IconsaxPlusLinear.close_circle,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                    )
                            ],
                          ),
                        ).marginOnly(top: 8);
                      },
                      itemCount: 1,
                    ),
                  );
                }),
              ],
            ).paddingSymmetric(horizontal: 16, vertical: 8),
          ),
        ),
        bottomNavigationBar: SingleActionBottomBar(
          label: controller.isEditingDocument.value ? 'Update Document' : 'Upload Document',
          onPressed: controller.addDocument,
        ));
  }

  Future<void> _pickDate(BuildContext context, SupportDocumentController ctrl) async {
    final d = await showDatePicker(
      context: context,
      initialDate: ctrl.jobStartDate.value ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030, 12, 31),
    );
    if (d != null && context.mounted) ctrl.setJobStartDate(d);
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
    required this.ctrl,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onTap;
  final VoidCallback? onClear;
  final FormFieldValidator<String>? validator;
  final ColorScheme scheme;
  final SupportDocumentController ctrl;

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      validator: validator,
      initialValue: value != null ? CcsDateUtils.forInput(value!) : null,
      builder: (ff) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommonText.semiBold(label, size: 14, color: scheme.onSurface),
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
                            icon: const Icon(IconsaxPlusLinear.close_circle, size: 18),
                            onPressed: onClear,
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(4),
                          ),
                        Icon(IconsaxPlusLinear.calendar_1, size: 20, color: scheme.primary).marginOnly(right: 16),
                      ],
                    ),
                  ),
                  isEmpty: value == null,
                  child: CommonText.regular(value != null ? CcsDateUtils.forInput(value!) : '', size: 14, color: scheme.onSurface),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
