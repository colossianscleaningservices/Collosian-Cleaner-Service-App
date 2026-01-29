import 'package:ccs_app/app/widget/layout/app_scaffold.dart';
import 'package:ccs_app/export.dart';

import 'property_controller.dart';

class AddPropertyView extends GetView<PropertyController> {
  const AddPropertyView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final isEditing = controller.editingProperty.value != null;

    return Obx(
      () => AppScaffold(
        appBar: Header(
          title: isEditing ? 'Edit Property' : 'Add Property',
          headerLogoIcon: false,
          hasBackIcon: true,
          titleCentered: false,
          actions: isEditing
              ? [
                  IconButton(
                    icon: Icon(IconsaxPlusLinear.trash, size: 22, color: scheme.error),
                    tooltip: 'Delete property',
                    onPressed: () => controller.confirmDeleteProperty(context),
                  ),
                ]
              : null,
        ),
        backgroundColor: scheme.surface,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: UiConstants.padding,
            child: Form(
              key: controller.formKey,
              child: Column(
                spacing: 16,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CommonTextField(
                    controller: controller.propertyNameCtrl,
                    label: 'Property Name',
                    hint: 'Enter property name',
                    validator: (v) => controller.validateRequired(v, 'Property name'),
                    prefixIcon: Icon(IconsaxPlusLinear.home_2, size: 20, color: scheme.onSurfaceVariant),
                  ),
                  CommonDropDownField<String>(
                    label: 'Business Type',
                    hint: 'Select',
                    items: PropertyController.businessTypeOptions,
                    itemLabel: (v) => v,
                    value: controller.businessType.value,
                    onChanged: (v) => v != null ? controller.businessType.value = v : null,
                  ),
                  CommonTextField(
                    controller: controller.addressCtrl,
                    label: 'Address',
                    hint: 'Enter address',
                    validator: (v) => controller.validateRequired(v, 'Address'),
                    prefixIcon: Icon(IconsaxPlusLinear.location, size: 20, color: scheme.onSurfaceVariant),
                  ),
                  CommonTextField(
                    controller: controller.cityCtrl,
                    label: 'City',
                    hint: 'Enter city',
                    validator: (v) => controller.validateRequired(v, 'City'),
                    prefixIcon: Icon(IconsaxPlusLinear.building_4, size: 20, color: scheme.onSurfaceVariant),
                  ),
                  CommonTextField(
                    controller: controller.postalCodeCtrl,
                    label: 'Postal Code',
                    hint: 'Enter postal code',
                    keyboardType: TextInputType.text,
                    validator: (v) => controller.validateRequired(v, 'Postal code'),
                    prefixIcon: Icon(IconsaxPlusLinear.map_1, size: 20, color: scheme.onSurfaceVariant),
                  ),
                  CommonDropDownField<String>(
                    label: 'Type of Property',
                    hint: 'Select Property Type',
                    items: PropertyController.propertyTypeOptions,
                    itemLabel: (v) => v,
                    value: controller.propertyType.value,
                    onChanged: (v) => controller.propertyType.value = v,
                    validator: (v) => v == null ? 'Type of property is required' : null,
                  ),
                  CommonDropDownField<String>(
                    label: 'Do you have a hoover?',
                    hint: 'Select',
                    items: PropertyController.hooverOptions,
                    itemLabel: (v) => v,
                    value: controller.hoover.value,
                    onChanged: (v) => v != null ? controller.hoover.value = v : null,
                  ),
                  CheckboxListTile(
                    title: CommonText.regular(
                      'Check this if you are going to provide cleaning products',
                      size: 14,
                      color: scheme.onSurface,
                    ),
                    value: controller.provideCleaningProducts.value,
                    onChanged: (v) => controller.provideCleaningProducts.value = v ?? false,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                  CheckboxListTile(
                    title: CommonText.regular(
                      'Do you have a washing machine?',
                      size: 14,
                      color: scheme.onSurface,
                    ),
                    value: controller.hasWashingMachine.value,
                    onChanged: (v) => controller.hasWashingMachine.value = v ?? false,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                  CommonDropDownField<String>(
                    label: 'Staff Preference',
                    hint: 'Select',
                    items: PropertyController.staffPreferenceOptions,
                    itemLabel: (v) => v,
                    value: controller.staffPreference.value,
                    onChanged: (v) => v != null ? controller.staffPreference.value = v : null,
                  ),
                  CheckboxListTile(
                    title: CommonText.regular(
                      'Do you have a dryer?',
                      size: 14,
                      color: scheme.onSurface,
                    ),
                    value: controller.hasDryer.value,
                    onChanged: (v) => controller.hasDryer.value = v ?? false,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                  CommonDropDownField<String>(
                    label: 'Access to Property',
                    hint: 'Select',
                    items: PropertyController.accessOptions,
                    itemLabel: (v) => v,
                    value: controller.accessToProperty.value,
                    onChanged: (v) => v != null ? controller.accessToProperty.value = v : null,
                  ),
                  CommonDropDownField<String>(
                    label: 'Do you have animals?',
                    hint: 'Select',
                    items: PropertyController.animalsOptions,
                    itemLabel: (v) => v,
                    value: controller.animals.value,
                    onChanged: (v) => v != null ? controller.animals.value = v : null,
                  ),
                  AppButton(
                    label: controller.isSaving.value ? (isEditing ? 'Saving...' : 'Adding...') : (isEditing ? 'Save changes' : 'Add Property'),
                    onPressed: controller.isSaving.value ? null : controller.addProperty,
                  ),
                ],
              ).paddingSymmetric(horizontal: 4, vertical: 8),
            ),
          ),
        ),
      ),
    );
  }
}
