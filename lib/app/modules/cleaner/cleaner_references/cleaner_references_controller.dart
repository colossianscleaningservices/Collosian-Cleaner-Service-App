import '../../../../export.dart';

class CleanerReferencesController extends GetxController {
  //TODO: Implement CleanerReferencesController

  final count = 0.obs;

  final firstNameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final companyNameCtrl = TextEditingController();
  final relationship = Rxn<String>();
  List<String> relationshipOptions = ['Aunt', 'Boyfriend', 'Friend', 'Brother', 'Sister', 'Other'];

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void increment() => count.value++;

  Future<void> addReferences() async {
    Get.context!.hideKeyboard();
    if (firstNameCtrl.text.trim().isEmpty) {
      Notifier.info('First name is required');
      return;
    }
    if (lastNameCtrl.text.trim().isEmpty) {
      Notifier.info('Last name is required');
      return;
    }

    if (relationship.value?.isEmpty == true || relationship.value == null) {
      Notifier.info('Please select the relationship');
      return;
    }

    Loader.show();
    try {
      // TODO: Call API to update profile
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      Notifier.info('Profile updated successfully');
      Get.back(result: true);
    } catch (e) {
      Notifier.info('Failed to update profile: $e');
    } finally {
      Loader.hide();
    }
  }
}
