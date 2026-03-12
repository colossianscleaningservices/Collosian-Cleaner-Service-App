import 'package:ccs_app/app/network/response/get_references_response.dart';

import '../../../../export.dart';
import '../../../network/repository/cleaner_repository.dart';

class CleanerReferencesController extends GetxController {
  final CleanerRepository _cleanerRepository = CleanerRepository();

  final count = 0.obs;

  final firstNameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final companyNameCtrl = TextEditingController();
  final relationship = Rxn<String>();
  List<String> relationshipOptions = ['Aunt', 'Boyfriend', 'Friend', 'Brother', 'Sister', 'Other'];

  final references = <References>[].obs;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    getCleanerReference();
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

    if (emailCtrl.text.trim().isEmpty) {
      Notifier.info('Email is required');
      return;
    }

    if (phoneCtrl.text.trim().isEmpty) {
      Notifier.info('Phone Number is required');
      return;
    }

    if (companyNameCtrl.text.trim().isEmpty) {
      Notifier.info('Phone Number is required');
      return;
    }

    if (relationship.value?.isEmpty == true || relationship.value == null) {
      Notifier.info('Please select the relationship');
      return;
    }

    Loader.show();

    final data = <String, dynamic>{};

    data["first_name"] = firstNameCtrl.text;
    data["last_name"] = lastNameCtrl.text;
    data["email"] = emailCtrl.text;
    data["phone_number"] = phoneCtrl.text;
    data["company_name"] = companyNameCtrl.text;
    data["relationship"] = relationship.value;

    var result = await _cleanerRepository.addReference(data);

    result.handle(
      success: (value) {
        Loader.hide();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (Get.context == null) return;
          Notifier.openSheet(Get.context as BuildContext, title: "Success", message: "${value.message}", isDismissable: false, isShowCloseIcon: false, showSecondaryButton: false, onPrimaryPressed: () {
            clearForm();
            getCleanerReference();
            Get.back(result: true);
          });
        });
      },
      onError: (_) {
        Loader.hide();
      },
      contextTag: 'media-upload',
    );
  }

  Future<void> getCleanerReference() async {
    Loader.show();
    try {
      final result = await _cleanerRepository.getReferences();
      result.handle(
        success: (response) {
          Loader.hide();
          references.clear();
          response.data?.references?.forEach((item) {
            references.add(item);
          });
          references.refresh();
        },
      );
    } finally {
      Loader.hide();
    }

  }

}
