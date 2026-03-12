import '../../../../export.dart';
import '../../../model/reference_item.dart';

class CleanerReferencesController extends GetxController {
  final count = 0.obs;

  final firstNameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final companyNameCtrl = TextEditingController();
  final relationship = Rxn<String>();
  List<String> relationshipOptions = ['Aunt', 'Boyfriend', 'Friend', 'Brother', 'Sister', 'Other'];

  final references = <ReferenceItem>[].obs;

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

  void clearForm() {
    firstNameCtrl.clear();
    lastNameCtrl.clear();
    emailCtrl.clear();
    phoneCtrl.clear();
    companyNameCtrl.clear();
    relationship.value = null;
  }

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
      // TODO: Call API to save reference
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      final item = ReferenceItem(
        firstName: firstNameCtrl.text.trim(),
        lastName: lastNameCtrl.text.trim(),
        email: emailCtrl.text.trim().isEmpty ? null : emailCtrl.text.trim(),
        phone: phoneCtrl.text.trim().isEmpty ? null : phoneCtrl.text.trim(),
        companyName: companyNameCtrl.text.trim().isEmpty ? null : companyNameCtrl.text.trim(),
        relationship: relationship.value,
      );
      references.add(item);
      clearForm();
      Notifier.info('Reference added successfully');
      Get.back(result: true);
    } catch (e) {
      Notifier.info('Failed to add reference: $e');
    } finally {
      Loader.hide();
    }
  }
}
