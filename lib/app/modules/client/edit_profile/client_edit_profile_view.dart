import 'package:ccs_app/app/widget/layout/app_scaffold.dart';
import 'package:ccs_app/export.dart';

import 'client_edit_profile_controller.dart';

class ClientEditProfileView extends GetView<ClientEditProfileController> {
  const ClientEditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return AppScaffold(
      appBar: const Header(title: 'Edit profile', headerLogoIcon: false, hasBackIcon: true, titleCentered: false),
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            spacing: 18,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    AppCard(
                      borderColor: context.colorScheme.outline,
                      borderWidth: 2,
                      radius: 100,
                      color: context.colorScheme.primaryContainer,
                      child: Obx(() {
                        final file = controller.pickedImage.value;
                        if (file != null) {
                          return Image.file(file, width: 120, height: 120, fit: BoxFit.cover);
                        }
                        return SizedBox(width: 120, height: 120, child: Icon(IconsaxPlusLinear.user, size: 48, color: context.colorScheme.primary));
                      }),
                    ),
                    Positioned(
                      bottom: -12,
                      right: -12,
                      child: FloatingActionButton.small(
                        onPressed: () {
                          showPicker(galleryPicker: () => controller.pickGalleryImage(), cameraPicker: () => controller.pickCameraImage());
                        },
                        backgroundColor: colorScheme.secondaryContainer,
                        child: Icon(IconsaxPlusLinear.camera, color: colorScheme.onSecondary, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
              CommonTextField(controller: controller.firstNameCtrl, label: 'First Name', hint: 'Enter your first name'),
              CommonTextField(controller: controller.lastNameCtrl, label: 'Last Name', hint: 'Enter your last name'),
              CommonTextField(
                controller: controller.phoneCtrl,
                label: 'Phone Number',
                hint: 'Enter your phone number',
                keyboardType: TextInputType.phone,
              ),
              CommonTextField(
                controller: controller.emailCtrl,
                label: 'Email address',
                hint: 'Enter your email',
                keyboardType: TextInputType.emailAddress,
                isReadOnly: true,
              ),
              CommonTextField(controller: controller.addressCtrl, label: 'Address', hint: 'Enter your address'),
              CommonTextField(controller: controller.cityCtrl, label: 'City', hint: 'Enter your city'),
              CommonTextField(
                controller: controller.postalCodeCtrl,
                label: 'Postal Code',
                hint: 'Enter your postal code',
                keyboardType: TextInputType.numberWithOptions(),
              ),
              CommonDropDownField(
                itemLabel: (value) => value.toString(),
                hint: 'Select Gender',
                label: "Gender",
                onChanged: (value) {
                  if (value != null) controller.gender.value = value;
                },
                items: controller.genderOptions,
                value: controller.gender.value,
              ),
              CommonTextField(
                controller: controller.dobCtrl,
                label: 'Date of Birth',
                hint: 'MM-dd-yyyy',
                onTap: () => controller.pickDateOfBirth(context),
                suffixIcon: Icon(IconsaxPlusLinear.calendar_1, size: 20, color: colorScheme.primary),
              ),
              Obx(
                () => AppCheckBox(
                  title: 'Enable reminders via email / SMS',
                  value: controller.enableReminders.value,
                  onChange: (v) => controller.enableReminders.value = v ?? false,
                ),
              ),
              Obx(
                () => AppCheckBox(
                  title: 'Change my password',
                  value: controller.changePassword.value,
                  onChange: (v) => controller.changePassword.value = v ?? false,
                ),
              ),
              CommonTextField(controller: controller.companyCtrl, label: 'Company', hint: 'Enter your company'),
              const SizedBox(height: 32),
              Obx(
                () => AppButton(
                  label: 'Save changes',
                  onPressed: controller.saveProfile,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
