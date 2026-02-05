import '../../../../../export.dart';
import '../../../../widget/layout/app_scaffold.dart';
import '../../../../widget/layout/bottom_action_bar.dart';
import '../cleaner_references_controller.dart';

class AddReferenceView extends GetView<CleanerReferencesController> {
  const AddReferenceView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: Header(title: "Add Reference"),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonTextField(controller: controller.firstNameCtrl, label: 'First Name', hint: 'Enter your first name').marginOnly(bottom: 18),
              CommonTextField(controller: controller.lastNameCtrl, label: 'Last Name', hint: 'Enter your last name').marginOnly(bottom: 18),
              CommonTextField(
                controller: controller.emailCtrl,
                label: 'Email',
                hint: 'Enter your email',
                keyboardType: TextInputType.emailAddress,
              ).marginOnly(bottom: 18),
              CommonTextField(
                controller: controller.phoneCtrl,
                label: 'Phone Number',
                hint: 'Enter your phone number',
                keyboardType: TextInputType.phone,
              ).marginOnly(bottom: 18),
              CommonTextField(controller: controller.companyNameCtrl, label: 'Company Name', hint: 'Enter your company name').marginOnly(bottom: 18),
              CommonDropDownField(
                itemLabel: (value) => value.toString(),
                hint: 'Select Relationship',
                label: "Relationship*",
                onChanged: (value) {
                  if (value != null) controller.relationship.value = value;
                },
                items: controller.relationshipOptions,
                value: controller.relationship.value,
              ).marginOnly(bottom: 18),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Obx(() {
        return SingleActionBottomBar(
          label: controller.isSaving.value ? 'Saving...' : 'Add Reference',
          onPressed: () => controller.isSaving.value ? null : controller.addReferences,
        );
      }),
    );
  }
}
