import 'dart:io';

import 'package:ccs_app/export.dart';
import 'package:image_picker/image_picker.dart';

class ClientEditProfileController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final firstNameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final postalCodeCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final dobCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final companyCtrl = TextEditingController();

  final gender = Rxn<String>();
  final enableReminders = false.obs;
  final changePassword = false.obs;

  /// Picked profile image file, or null if none.
  final pickedImage = Rx<File?>(null);

  final isSaving = false.obs;

  List<String> genderOptions = ['Male', 'Female', 'Other', 'Prefer not to say'];

  final _picker = ImagePicker();

  Future<void> pickGalleryImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 75, maxWidth: 512, maxHeight: 512);
      if (pickedFile != null) {
        pickedImage.value = File(pickedFile.path);
      }
    } catch (e) {
      Notifier.info('Failed to pick image: $e');
    }
  }

  Future<void> pickCameraImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.camera, imageQuality: 75, maxWidth: 512, maxHeight: 512);
      if (pickedFile != null) {
        pickedImage.value = File(pickedFile.path);
      }
    } catch (e) {
      Notifier.info('Failed to pick image: $e');
    }
  }

  @override
  void onClose() {
    firstNameCtrl.dispose();
    lastNameCtrl.dispose();
    phoneCtrl.dispose();
    postalCodeCtrl.dispose();
    emailCtrl.dispose();
    cityCtrl.dispose();
    addressCtrl.dispose();
    companyCtrl.dispose();
    super.onClose();
  }

  Future<void> pickDateOfBirth(BuildContext context) async {
    final date = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(1900), lastDate: DateTime.now());
    if (date != null && context.mounted) dobCtrl.text = formatDateOnly(date);
  }

  void setGender(String? v) => gender.value = v;

  Future<void> saveProfile() async {
    Get.context!.hideKeyboard();
    if (firstNameCtrl.text.trim().isEmpty) {
      Notifier.info('First name is required');
      return;
    }
    if (lastNameCtrl.text.trim().isEmpty) {
      Notifier.info('Last name is required');
      return;
    }

    isSaving.value = true;

    try {
      // TODO: Call API to update profile
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      Notifier.info('Profile updated successfully');
      Get.back(result: true);
    } catch (e) {
      Notifier.info('Failed to update profile: $e');
    } finally {
      isSaving.value = false;
    }
  }

  void onDeleteAccount() {
    Notifier.info('Delete account (coming soon)');
  }
}
