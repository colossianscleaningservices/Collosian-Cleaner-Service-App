import 'package:ccs_app/app/widget/layout/app_scaffold.dart';
import 'package:ccs_app/app/widget/layout/bottom_action_bar.dart';
import 'package:ccs_app/export.dart';
import 'package:linear_progress_bar/linear_progress_bar.dart';

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
          padding: const EdgeInsets.only(left: 24,right: 24,bottom: 24,top: 8),
          child: Form(
            key: controller.formKey,
            child: Column(
              spacing: 18,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonText.semiBold(
                        controller.profileText.value,
                        size: 16,
                      ).marginOnly(bottom: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: LinearProgressBar(
                              maxSteps: 100,
                              progressType: ProgressType.linear,
                              currentStep: controller.profileStatus.value,
                              progressColor: context.colorScheme.secondary,
                              backgroundColor: context.colorScheme.secondary.withValues(alpha: 0.12),
                              animateProgress: true,
                              borderRadius: BorderRadius.circular(10),
                              minHeight: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }),
                Center(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Obx(() {
                        return AppCard(
                          borderColor: context.colorScheme.outline,
                          borderWidth: (controller.pickedImage.value == null && controller.imageUrl.value.isEmpty) ? 2 : 0,
                          radius: 100,
                          color: context.colorScheme.primaryContainer,
                          child: Obx(() {
                            final file = controller.pickedImage.value;
                            if (file != null) {
                              return Image.file(file, width: 120, height: 120, fit: BoxFit.cover);
                            }

                            if (controller.imageUrl.value.isNotEmpty) {
                              return Image.network(
                                height: 120,
                                width: 120,
                                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                                  if (wasSynchronouslyLoaded) return child;
                                  return frame == null ? const Center(child: CircularProgressIndicator()) : child;
                                },
                                controller.imageUrl.value,
                                fit: BoxFit.cover,
                              );
                            }
                            return SizedBox(width: 120, height: 120, child: Icon(IconsaxPlusLinear.user, size: 48, color: context.colorScheme.primary));
                          }),
                        );
                      }),
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
                CommonTextField(
                  controller: controller.firstNameCtrl,
                  label: 'First Name',
                  hint: 'Enter your first name',
                  validator: (v) => Validator.requiredField(v),
                ),
                CommonTextField(
                  controller: controller.lastNameCtrl,
                  label: 'Last Name',
                  hint: 'Enter your last name',
                  validator: (v) => Validator.requiredField(v),
                ),
                CommonTextField(
                  controller: controller.phoneCtrl,
                  label: 'Phone Number',
                  hint: 'Enter your phone number',
                  maxLength: 10,
                  keyboardType: TextInputType.phone,
                  validator: (v) => Validator.minLength(v, 10, fieldName: 'Phone'),
                ),
                CommonTextField(
                  controller: controller.emailCtrl,
                  label: 'Email address',
                  hint: 'Enter your email',
                  keyboardType: TextInputType.emailAddress,
                  isReadOnly: true,
                ),
                CommonTextField(
                  controller: controller.addressCtrl,
                  label: 'Address',
                  hint: 'Enter your address',
                ),
                CommonTextField(
                  controller: controller.cityCtrl,
                  label: 'City',
                  hint: 'Enter your city',
                ),
                CommonTextField(
                  controller: controller.postalCodeCtrl,
                  label: 'Postal Code',
                  hint: 'Enter your postal code',
                  maxLength: 6,
                  keyboardType: TextInputType.numberWithOptions(),
                ),
                Obx(() {
                  return CommonDropDownField(
                    itemLabel: (value) => value.toString(),
                    hint: 'Select Gender',
                    label: "Gender",
                    onChanged: (value) {
                      if (value != null) controller.gender.value = value;
                    },
                    items: controller.genderOptions,
                    value: controller.gender.value,
                  );
                }),
                CommonTextField(
                  controller: controller.dobCtrl,
                  label: 'Date of Birth',
                  hint: 'dd/MM/yyyy',
                  onTap: () => controller.pickDateOfBirth(context),
                  suffixIcon: Icon(IconsaxPlusLinear.calendar_1, size: 20, color: colorScheme.primary),
                ),
                Obx(
                  () => AppCheckBox(
                    title: 'Enable reminders via email / SMS',
                    value: controller.enableReminders.value,
                    onChange: (v) => controller.enableReminders.value = v,
                  ),
                ),
                CommonTextField(
                  controller: controller.companyCtrl,
                  label: 'Company',
                  hint: 'Enter your company',
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SingleActionBottomBar(label: 'Save changes', onPressed: controller.saveProfile),
    );
  }
}
