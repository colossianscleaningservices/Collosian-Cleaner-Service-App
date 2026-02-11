import 'dart:io';

import 'package:ccs_app/app/model/common_model.dart';
import 'package:ccs_app/app/services/pref.dart';
import 'package:ccs_app/export.dart';
import 'package:image_picker/image_picker.dart';

class CleanerEditProfileController extends GetxController {
  final pickedImage = Rx<File?>(null);
  final firstNameCtrl = TextEditingController();
  final bankNameCtrl = TextEditingController();
  final yourNameCtrl = TextEditingController();
  final accountNumberCtrl = TextEditingController();
  final sortCodeCtrl = TextEditingController();
  final fullNameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final contactCtrl = TextEditingController();
  final postalCodeCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final hobbiesCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final dobCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final companyCtrl = TextEditingController();

  final nationalInsuranceNumberCtrl = TextEditingController();
  final shareCodeCtrl = TextEditingController();

  final gender = Rxn<String>();
  final relationship = Rxn<String>();
  final driver = Rxn<String>();
  final children = Rxn<String>();
  final immigrationStatus = Rxn<String>();
  final enableReminders = false.obs;
  final scheduleValidFrom = Rx<DateTime>(DateTime.now());

  List<String> genderOptions = ['Male', 'Female', 'Other', 'Prefer not to say'];
  List<String> relationshipOptions = ['Aunt', 'Boyfriend', 'Friend', 'Brother', 'Sister', 'Other'];
  List<String> childrenOptions = ['No', '1', '2', '3', '4', '5+'];
  List<String> driverOptions = ['Yes, I have a car', "Yes, but I don't have a car", 'No'];
  List<String> immigrationStatusOptions = ['British Citizen / Right of Adobe', 'Settled Status', 'Other'];

  final isSaving = false.obs;
  final deleteAccount = false.obs;

  RxList<CommonModel> kitchenList = <CommonModel>[].obs;
  RxList<CommonModel> bathroomList = <CommonModel>[].obs;
  RxList<CommonModel> bedroomList = <CommonModel>[].obs;
  RxList<CommonModel> ignoringList = <CommonModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    initList();

    showProfileData();

  }

  void initList() {
    kitchenList.clear();
    kitchenList.add(CommonModel(type: "Remove cobwebs"));
    kitchenList.add(CommonModel(type: "Clear Rubbish: empty plastic containers, out of date food"));
    kitchenList.add(CommonModel(type: "Wash all cupboards inside/outside"));
    kitchenList.add(CommonModel(type: "Wipe fridge inside/outside"));

    bathroomList.clear();
    bathroomList.add(CommonModel(type: "Remove cobwebs"));
    bathroomList.add(CommonModel(type: "Clear rubbish"));
    bathroomList.add(CommonModel(type: "Wash sink"));
    bathroomList.add(CommonModel(type: "Wash tiled wall"));

    bedroomList.clear();
    bedroomList.add(CommonModel(type: "Remove cobwebs"));
    bedroomList.add(CommonModel(type: "Wash doors front and back with frames"));

    ignoringList.clear();
    ignoringList.add(CommonModel(type: "Ironing shirts"));
    ignoringList.add(CommonModel(type: "Iron bedlinens"));
    ignoringList.add(CommonModel(type: "Iron clothing items"));

  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

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

  Future<void> pickDateOfBirth(BuildContext context) async {
    final date = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(1900), lastDate: DateTime.now());
    if (date != null && context.mounted) dobCtrl.text = formatDateOnly(date);
  }

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

  void setScheduleValidFrom(DateTime d) {
    scheduleValidFrom.value = DateTime(d.year, d.month, d.day);
  }

  void showProfileData() {
    log(runtimeType.toString(), 'First Name => ${Prefs().getData(Prefs.firstName)}');

    firstNameCtrl.text = Prefs().getData(Prefs.firstName);
    lastNameCtrl.text = Prefs().getData(Prefs.lastName);
    phoneCtrl.text = Prefs().getData(Prefs.phoneNumber);
    emailCtrl.text = Prefs().getData(Prefs.email);
    firstNameCtrl.text = Prefs().getData(Prefs.firstName);
    firstNameCtrl.text = Prefs().getData(Prefs.firstName);
  }

}
