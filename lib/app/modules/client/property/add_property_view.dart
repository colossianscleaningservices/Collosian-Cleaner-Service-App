import 'package:ccs_app/app/network/response/property_sub_type_response.dart';
import 'package:ccs_app/app/widget/layout/app_scaffold.dart';
import 'package:ccs_app/app/widget/layout/bottom_action_bar.dart';
import 'package:ccs_app/export.dart';

import '../../../network/response/property_type_response.dart';
import 'property_controller.dart';

Widget _buildNumberField(TextEditingController controller, String label) {
  return CommonTextField(
    controller: controller,
    label: label,
    hint: '0',
    keyboardType: TextInputType.number,
    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
  );
}

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
        body: SafeArea(
          child: SingleChildScrollView(
            child: Form(
              key: controller.formKey,
              child: Column(
                spacing: 16,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppCard(
                    child: Column(
                      spacing: 16,
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
                          onChanged: (v) {
                            if (v != null) {
                              controller.getPropertyType(v.capitalize.toString());
                              controller.selectedPropertyType.value = null;
                              controller.clearHouseFields();
                              controller.businessType.value = v;
                            }
                          },
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
                          keyboardType: TextInputType.number,
                          validator: (v) => controller.validateRequired(v, 'Postal code'),
                          maxLength: 6,
                          prefixIcon: Icon(IconsaxPlusLinear.map_1, size: 20, color: scheme.onSurfaceVariant),
                        ),
                        Obx(() {
                          return CommonDropDownField<PropertyTypes>(
                            label: 'Type of Property',
                            hint: 'Select Property Type',
                            itemLabel: (v) => v.name ?? "",
                            value: controller.selectedPropertyType.value,
                            items: controller.propertyTypeOptions.value,
                            onChanged: (v) {
                              if (v != null) {
                                if (v.hasSubtypes == true) {
                                  controller.getPropertySubType(v.id?.toInt() ?? 0);
                                } else {
                                  controller.clearHouseFields();
                                }
                                controller.selectedPropertyType.value = v;
                              }
                            },
                            validator: (v) => v == null ? 'Type of property is required' : null,
                          );
                        }),
                        if (controller.selectedPropertyType.value?.hasSubtypes == true) ...[
                          Obx(() {
                            return CommonDropDownField<PropertySubtypes>(
                                label: 'Sub Type',
                                hint: 'Select',
                                items: controller.propertySubTypeOptions.value,
                                itemLabel: (v) => v.name ?? '',
                                value: controller.selectedPropertySubType.value,
                                onChanged: (v) => controller.selectedPropertySubType.value = v);
                          }),
                          _buildNumberField(controller.numberOfBedroomsCtrl, 'Number of Bedrooms'),
                          _buildNumberField(controller.numberOfBathroomsCtrl, 'Number of Bathrooms'),
                          _buildNumberField(controller.numberOfGuestToiletCtrl, 'Number of Separate/Guest Toilet'),
                          _buildNumberField(controller.livingRoomCtrl, 'Living Room'),
                          _buildNumberField(controller.officeCtrl, 'Office'),
                          _buildNumberField(controller.conservatoryCtrl, 'Conservatory'),
                          _buildNumberField(controller.diningRoomCtrl, 'Dining Room'),
                        ],
                      ],
                    ).paddingAll(16),
                  ).marginSymmetric(horizontal: 16, vertical: 8),
                  AppCard(
                    child: Column(
                      spacing: 16,
                      children: [
                        CommonDropDownField<String>(
                          label: 'Do you have a hoover?',
                          hint: 'Select',
                          items: PropertyController.hooverOptions,
                          itemLabel: (v) => v,
                          value: controller.hoover.value,
                          onChanged: (v) => v != null ? controller.hoover.value = v : null,
                        ),
                        AppCheckBox(
                          title: "Check this if you are going to provide cleaning products",
                          value: controller.provideCleaningProducts.value,
                          onChange: (v) => controller.provideCleaningProducts.value = v,
                        ),
                        AppCheckBox(
                          title: "Do you have a washing machine?",
                          value: controller.hasWashingMachine.value,
                          onChange: (v) => controller.hasWashingMachine.value = v,
                        ),
                        CommonDropDownField<String>(
                          label: 'Staff Preference',
                          hint: 'Select',
                          items: PropertyController.staffPreferenceOptions,
                          itemLabel: (v) => v,
                          value: controller.staffPreference.value,
                          onChanged: (v) => v != null ? controller.staffPreference.value = v : null,
                        ),
                        AppCheckBox(title: "Do you have a dryer?", value: controller.hasDryer.value, onChange: (v) => controller.hasDryer.value = v),
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
                      ],
                    ).paddingAll(16),
                  ).marginSymmetric(horizontal: 16, vertical: 8),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: SingleActionBottomBar(
            label: controller.isSaving.value ? (isEditing ? 'Saving...' : 'Adding...') : (isEditing ? 'Save changes' : 'Add Property'),
            onPressed: () => controller.isSaving.value ? null : controller.addUpdateProperty()),
      ),
    );
  }
}
