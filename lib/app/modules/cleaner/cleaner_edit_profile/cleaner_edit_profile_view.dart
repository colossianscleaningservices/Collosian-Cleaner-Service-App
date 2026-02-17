import 'package:ccs_app/app/widget/layout/bottom_action_bar.dart';
import 'package:ccs_app/export.dart';

import '../../../widget/layout/app_scaffold.dart';
import 'cleaner_edit_profile_controller.dart';

class CleanerEditProfileView extends GetView<CleanerEditProfileController> {
  const CleanerEditProfileView({super.key});

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
              ).marginOnly(bottom: 18),
              CommonTextField(controller: controller.firstNameCtrl, label: 'First Name', hint: 'Enter your first name').marginOnly(bottom: 18),
              CommonTextField(controller: controller.lastNameCtrl, label: 'Last Name', hint: 'Enter your last name').marginOnly(bottom: 18),
              CommonTextField(
                controller: controller.phoneCtrl,
                label: 'Phone Number',
                hint: 'Enter your phone number',
                keyboardType: TextInputType.phone,
              ).marginOnly(bottom: 18),
              CommonTextField(
                controller: controller.emailCtrl,
                label: 'Email address',
                hint: 'Enter your email',
                keyboardType: TextInputType.emailAddress,
                isReadOnly: true,
              ).marginOnly(bottom: 18),
              CommonTextField(controller: controller.addressCtrl, label: 'Address', hint: 'Enter your address').marginOnly(bottom: 18),
              CommonTextField(controller: controller.cityCtrl, label: 'City', hint: 'Enter your city').marginOnly(bottom: 18),
              CommonTextField(
                controller: controller.postalCodeCtrl,
                label: 'Postal Code',
                hint: 'Enter your postal code',
                keyboardType: TextInputType.numberWithOptions(),
              ).marginOnly(bottom: 18),
              CommonDropDownField(
                itemLabel: (value) => value.toString(),
                hint: 'Select Gender',
                label: "Gender",
                onChanged: (value) {
                  if (value != null) controller.gender.value = value;
                },
                items: controller.genderOptions,
                value: controller.gender.value,
              ).marginOnly(bottom: 18),
              CommonTextField(
                controller: controller.dobCtrl,
                label: 'Date of Birth',
                hint: 'MM-dd-yyyy',
                onTap: () => controller.pickDateOfBirth(context),
                suffixIcon: Icon(IconsaxPlusLinear.calendar_1, size: 20, color: colorScheme.primary),
              ).marginOnly(bottom: 18),
              Obx(
                () => CheckboxListTile(
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  title: CommonText.regular('Enable reminders via email / SMS', size: 14, color: colorScheme.onSurface),
                  value: controller.enableReminders.value,
                  onChanged: (v) => controller.enableReminders.value = v ?? false,
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ).marginOnly(bottom: 16),
              ),

              CommonTextField(controller: controller.companyCtrl, label: 'Company', hint: 'Enter your company').marginOnly(bottom: 24),

              //PERSONAL INFO
              CommonText.bold(
                'Personal Info',
                size: 20,
              ).marginOnly(bottom: 18),
              CommonDropDownField(
                itemLabel: (value) => value.toString(),
                hint: 'Select your immigration status',
                label: "Immigration status",
                onChanged: (value) {
                  if (value != null) controller.immigrationStatus.value = value;
                },
                items: controller.immigrationStatusOptions,
                value: controller.immigrationStatus.value,
              ).marginOnly(bottom: 18),

              CommonText.semiBold(
                'National Insurance Number / Share Code *',
              ).marginOnly(bottom: 6),
              Row(
                children: [
                  Expanded(
                    child: CommonTextField(
                      controller: controller.nationalInsuranceNumberCtrl,
                      hint: 'National Insurance Number',
                      keyboardType: TextInputType.numberWithOptions(),
                    ),
                  ),
                  CommonText.regular(
                    'OR',
                    size: 18,
                  ).marginSymmetric(horizontal: 8),
                  Expanded(
                    child: CommonTextField(
                      controller: controller.shareCodeCtrl,
                      hint: 'Share Code (if no NIN)',
                      keyboardType: TextInputType.numberWithOptions(),
                    ),
                  ),
                ],
              ).marginOnly(bottom: 6),

              RichText(
                softWrap: true,
                text: TextSpan(
                  text: 'Fill either ',
                  style: TextStyle(fontWeight: FontWeight.w400, fontSize: 14, color: context.colorScheme.onSurface),
                  children: <TextSpan>[
                    TextSpan(
                        text: "National Insurance Number (preferred)",
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: context.colorScheme.onSurface)),
                    TextSpan(
                      text: " — it’s composed of ",
                      style: TextStyle(fontWeight: FontWeight.w400, fontSize: 14, color: context.colorScheme.onSurface),
                    ),
                    TextSpan(
                        text: "2 letters + 6 digits + 1 letter ",
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: context.colorScheme.onSurface)),
                    TextSpan(
                      text: "(e.g. ",
                      style: TextStyle(fontWeight: FontWeight.w400, fontSize: 14, color: context.colorScheme.onSurface),
                    ),
                    TextSpan(
                      text: "AB123456C",
                      style: TextStyle(fontWeight: FontWeight.w400, fontSize: 14, color: context.colorScheme.error.withValues(alpha: 0.6)),
                    ),
                    TextSpan(
                      text: ") — or provide your ",
                      style: TextStyle(fontWeight: FontWeight.w400, fontSize: 14, color: context.colorScheme.onSurface),
                    ),
                    TextSpan(
                      text: "Share Code",
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: context.colorScheme.onSurface),
                    ),
                    TextSpan(
                      text: ". Only one will be submitted.",
                      style: TextStyle(fontWeight: FontWeight.w400, fontSize: 14, color: context.colorScheme.onSurface),
                    ),
                  ],
                ),
              ).marginOnly(bottom: 18),

              CommonTextField(
                controller: controller.hobbiesCtrl,
                label: 'Hobbies',
                hint: 'Enter your hobbies and interests',
                keyboardType: TextInputType.text,
                isReadOnly: true,
                minLines: 4,
                maxLines: 8,
              ).marginOnly(bottom: 24),

              //Your next of kin
              CommonText.bold(
                'Your next of kin',
                size: 20,
              ).marginOnly(bottom: 18),

              CommonTextField(controller: controller.fullNameCtrl, label: 'Full Name', hint: 'Enter your full name').marginOnly(bottom: 18),

              CommonDropDownField(
                itemLabel: (value) => value.toString(),
                hint: 'Select Relationship',
                label: "Relationship",
                onChanged: (value) {
                  if (value != null) controller.relationship.value = value;
                },
                items: controller.relationshipOptions,
                value: controller.relationship.value,
              ).marginOnly(bottom: 18),

              CommonTextField(
                controller: controller.contactCtrl,
                label: 'Contact/Mobile Number',
                hint: 'Enter your contact number',
                keyboardType: TextInputType.phone,
              ).marginOnly(bottom: 24),

              //Work Details
              CommonText.bold(
                'Work Details',
                size: 20,
              ).marginOnly(bottom: 18),

              CommonDropDownField(
                itemLabel: (value) => value.toString(),
                hint: 'Select',
                label: "Do you drive?",
                onChanged: (value) {
                  if (value != null) controller.driver.value = value;
                },
                items: controller.driverOptions,
                value: controller.driver.value,
              ).marginOnly(bottom: 18),

              CommonTextField(controller: controller.firstNameCtrl, label: 'Local working areas', hint: 'Enter your local working areas')
                  .marginOnly(bottom: 18),

              CommonDropDownField(
                itemLabel: (value) => value.toString(),
                hint: 'Select',
                label: "Do you have children?",
                onChanged: (value) {
                  if (value != null) controller.children.value = value;
                },
                items: controller.childrenOptions,
                value: controller.children.value,
              ).marginOnly(bottom: 18),

              CommonText.semiBold(
                'Employment Start Date',
              ).marginOnly(bottom: 6),

              Obx(() {
                return _DateField(
                  value: controller.scheduleValidFrom.value,
                  onTap: () => _pickDate(context, controller, isFrom: true),
                  scheme: colorScheme,
                ).marginOnly(bottom: 24);
              }),

              //Work Details
              CommonText.bold(
                'Cleaning Services',
                size: 20,
              ).marginOnly(bottom: 18),

              CommonText.semiBold(
                'KITCHEN AREA',
                size: 16,
              ).marginOnly(bottom: 6),

              Obx(() {
                return ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: controller.kitchenList.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      var item = controller.kitchenList[index];
                      return CheckboxListTile(
                        dense: true,
                        visualDensity: VisualDensity.compact,
                        title: CommonText.regular(item.type, size: 14, color: colorScheme.onSurface),
                        value: item.isSelected,
                        onChanged: (v) {
                          item.isSelected = v ?? false;
                          controller.kitchenList.refresh();
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      );
                    }).marginOnly(bottom: 12);
              }),

              CommonText.semiBold(
                'BATHROOM / TOILET',
                size: 16,
              ).marginOnly(bottom: 6),

              Obx(() {
                return ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: controller.bathroomList.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      var item = controller.bathroomList[index];
                      return CheckboxListTile(
                        dense: true,
                        visualDensity: VisualDensity.compact,
                        title: CommonText.regular(item.type, size: 14, color: colorScheme.onSurface),
                        value: item.isSelected,
                        onChanged: (v) {
                          item.isSelected = v ?? false;
                          controller.bathroomList.refresh();
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      );
                    }).marginOnly(bottom: 12);
              }),

              CommonText.semiBold(
                'BEDROOM / LIVING ROOM AREA',
                size: 16,
              ).marginOnly(bottom: 6),

              Obx(() {
                return ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: controller.bedroomList.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      var item = controller.bedroomList[index];
                      return CheckboxListTile(
                        dense: true,
                        visualDensity: VisualDensity.compact,
                        title: CommonText.regular(item.type, size: 14, color: colorScheme.onSurface),
                        value: item.isSelected,
                        onChanged: (v) {
                          item.isSelected = v ?? false;
                          controller.bedroomList.refresh();
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      );
                    }).marginOnly(bottom: 12);
              }),

              CommonText.semiBold(
                'IRONING SERVICES',
                size: 16,
              ).marginOnly(bottom: 6),

              Obx(() {
                return ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: controller.ignoringList.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      var item = controller.ignoringList[index];
                      return CheckboxListTile(
                        dense: true,
                        visualDensity: VisualDensity.compact,
                        title: CommonText.regular(item.type, size: 14, color: colorScheme.onSurface),
                        value: item.isSelected,
                        onChanged: (v) {
                          item.isSelected = v ?? false;
                          controller.ignoringList.refresh();
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      );
                    }).marginOnly(bottom: 18);
              }),

              //Bank Details
              CommonText.bold(
                'Bank Details',
                size: 20,
              ).marginOnly(bottom: 18),

              CommonTextField(controller: controller.bankNameCtrl, label: 'Bank Name', hint: 'Enter your bank name').marginOnly(bottom: 18),
              CommonTextField(controller: controller.yourNameCtrl, label: 'Your Name', hint: 'Enter your name').marginOnly(bottom: 18),
              CommonTextField(
                      controller: controller.accountNumberCtrl, label: 'Account Number', hint: 'Enter your account Number', keyboardType: TextInputType.number)
                  .marginOnly(bottom: 18),
              CommonTextField(controller: controller.sortCodeCtrl, label: 'Sort Code', hint: 'Enter your sort Code').marginOnly(bottom: 18),

              Obx(() {
                return CheckboxListTile(
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  title: CommonText.regular('Delete My Account', size: 14, color: colorScheme.error),
                  value: controller.deleteAccount.value,
                  onChanged: (v) {
                    controller.deleteAccount.value = v ?? false;
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                );
              }),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Obx(() {
        return SingleActionBottomBar(label: 'Save changes', onPressed: controller.saveProfile);
      }),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({required this.value, required this.onTap, required this.scheme});

  final DateTime value;
  final VoidCallback onTap;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: scheme.surfaceTint.withValues(alpha: 0.04),
      borderRadius: BorderRadius.circular(UiConstants.radiusDefault),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(UiConstants.radiusDefault),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Expanded(child: CommonText.medium(CcsDateUtils.forInput(value), size: 14, color: scheme.onSurface)),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: scheme.surfaceTint.withValues(alpha: 0.04), shape: BoxShape.circle),
                child: Icon(IconsaxPlusLinear.calendar_1, size: 18, color: scheme.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _pickDate(BuildContext context, CleanerEditProfileController ctrl, {required bool isFrom}) async {
  final initial = ctrl.scheduleValidFrom.value;
  final d = await showDatePicker(context: context, initialDate: initial, firstDate: DateTime(2020, 1, 1), lastDate: DateTime(2030, 12, 31));
  if (d == null || !context.mounted) return;
  if (isFrom) {
    ctrl.setScheduleValidFrom(d);
  }
}
