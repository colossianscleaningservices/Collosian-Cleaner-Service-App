import 'package:ccs_app/app/network/response/get_references_response.dart';

import '../../../../export.dart';
import '../../../network/repository/cleaner_repository.dart';

class CleanerReferencesController extends GetxController {
  final CleanerRepository _cleanerRepository = CleanerRepository();

  final firstNameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final companyNameCtrl = TextEditingController();
  final relationship = Rxn<String>();
  List<String> relationshipOptions = ['Aunt', 'Boyfriend', 'Friend', 'Brother', 'Sister', 'Other'];

  final references = <References>[].obs;

  var isEditingReference = false.obs;
  final selectedReference = Rxn<References>();

  @override
  void onReady() {
    getCleanerReference();
    super.onReady();
  }

  void clearForm() {
    isEditingReference.value = false;
    selectedReference.value = null;
    firstNameCtrl.clear();
    lastNameCtrl.clear();
    emailCtrl.clear();
    phoneCtrl.clear();
    companyNameCtrl.clear();
    relationship.value = null;
  }

  void setEditingData(References ref) {
    isEditingReference.value = true;
    selectedReference.value = ref;
    firstNameCtrl.text = ref.firstName ?? '';
    lastNameCtrl.text = ref.lastName ?? '';
    emailCtrl.text = ref.email ?? '';

    var phoneNumber = ref.phoneNumber ?? '';

    if (phoneNumber.isNotEmpty && phoneNumber.contains('-')) {
      if (phoneNumber.contains('-')) {
        phoneNumber = phoneNumber.replaceAll('-', '');
      }

      if (phoneNumber.contains('(')) {
        phoneNumber = phoneNumber.replaceAll('(', '');
      }

      if (phoneNumber.contains(')')) {
        phoneNumber = phoneNumber.replaceAll(')', '');
      }

      if (phoneNumber.contains(' ')) {
        phoneNumber = phoneNumber.replaceAll(' ', '');
      }
    }

    phoneCtrl.text = phoneNumber;
    companyNameCtrl.text = ref.companyName ?? '';
    relationship.value = ref.relationship;
    refresh();
  }

  void onEditReference(References ref) {
    setEditingData(ref);
    Get.toNamed(Routes.ADD_REFERENCES)?.then((result) {
      if (result == true) refreshReferences();
    });
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

    isEditingReference.value ? _updateReference(data) : _createReference(data);
  }

  Future<void> _createReference(Map<String, dynamic> data) async {
    var result = await _cleanerRepository.addReference(data);

    result.handle(
      success: (value) {
        Loader.hide();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (Get.context == null) return;
          Notifier.openSheet(Get.context as BuildContext,
              type: SheetType.success,
              title: "Success",
              message: "${value.message}",
              isDismissable: false,
              isShowCloseIcon: false,
              showSecondaryButton: false, onPrimaryPressed: () {
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

  Future<void> _updateReference(Map<String, dynamic> data) async {
    var result = await _cleanerRepository.updateReference(
      selectedReference.value?.id?.toInt() ?? 0,
      data,
    );

    result.handle(
      success: (value) {
        Loader.hide();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (Get.context == null) return;
          Notifier.openSheet(Get.context as BuildContext,
              type: SheetType.success,
              title: "Success",
              message: "${value.message}",
              isDismissable: false,
              isShowCloseIcon: false,
              showSecondaryButton: false, onPrimaryPressed: () {
            clearForm();
            Get.back(result: true);
            getCleanerReference();
          });
        });
      },
      onError: (_) {
        Loader.hide();
      },
      contextTag: 'media-upload',
    );
  }

  Future<void> refreshReferences() => getCleanerReference();

  void onDeleteReference(References ref) {
    confirmDeleteReference(Get.context!, ref.id?.toInt() ?? 0);
  }

  void confirmDeleteReference(BuildContext context, int id) {
    Notifier.openSheet(
      context,
      type: SheetType.error,
      title: 'Delete Reference?',
      message: 'Are you sure you want to delete this reference?',
      primaryButtonLabel: 'Yes',
      secondaryButtonLabel: 'No',
      showPrimaryButton: true,
      showSecondaryButton: true,
      onPrimaryPressed: () => deleteReference(id),
      onSecondaryPressed: () {},
    );
  }

  Future<void> deleteReference(int id) async {
    Loader.show();
    try {
      final result = await _cleanerRepository.deleteReference(id);
      result.handle(
        success: (_) => getCleanerReference(),
      );
    } finally {
      Loader.hide();
    }
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
