import 'dart:io';

import 'package:ccs_app/app/network/request/edit_profile_request.dart';
import 'package:ccs_app/app/network/response/profile_response.dart';
import 'package:ccs_app/export.dart';
import 'package:dio/dio.dart' as dio;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../network/repository/common_repository.dart';
import '../../../services/pref.dart';
import '../../../services/session_service.dart';
import '../dashboard/client_dashboard_controller.dart';

class ClientEditProfileController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final CommonRepository _commonRepository = CommonRepository();

  final firstNameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final postalCodeCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final dobCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final companyCtrl = TextEditingController();
  RxString profileText = "Profile Completion: 0%".obs;
  RxInt profileStatus = 0.obs;

  final gender = Rxn<String>();
  final enableReminders = false.obs;
  RxString imageUrl = "".obs;

  /// Picked profile image file, or null if none.
  final pickedImage = Rx<File?>(null);

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
      bool hasPermission = await requestCameraPermission();

      if (hasPermission) {
        final pickedFile = await _picker.pickImage(source: ImageSource.camera, imageQuality: 75, maxWidth: 512, maxHeight: 512);
        if (pickedFile != null) {
          pickedImage.value = File(pickedFile.path);
        }
      }
    } catch (e) {
      Notifier.info('Failed to pick image: $e');
    }
  }

  Future<bool> requestCameraPermission() async {
    var status = await Permission.camera.status;

    if (status.isDenied) {
      status = await Permission.camera.request();
    }

    if (status.isGranted) {
      return true;
    }
    if (status.isPermanentlyDenied) {
      await openAppSettings();
    }
    return false;
  }

  @override
  void onInit() {
    showProfileData();
    super.onInit();
  }

  @override
  void onReady() {
    getProfile();
    super.onReady();
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

    if (formKey.currentState?.validate() ?? false) {
      if (pickedImage.value != null) {
        Loader.show();

        List<dio.MultipartFile> files = [];

        var value = await dio.MultipartFile.fromFile(pickedImage.value!.path, filename: "image_${DateTime.now()}.jpg").then((value) {
          return value;
        });
        files.add(value);

        final data = <String, dynamic>{};
        data["files[]"] = files;
        data["mediaable_type"] = 'App\\Models\\User';
        data["mediaable_id"] = '1';
        data["media_type"] = 'profile';

        log(runtimeType.toString(), 'Media Upload Data => $data');

        var result = await _commonRepository.mediaUpload(data);
        result.handle(
          success: (value) {
            Loader.hide();

            if (value.data?.fileUrl?.isNotEmpty == true) {
              imageUrl.value = value.data?.fileUrl?.first ?? "";
            }
          },
          onError: (_) {
            Loader.hide();
          },
          contextTag: 'media-upload',
        );
      }

      Loader.show();

      try {
        var request = EditProfileRequest(
          firstName: firstNameCtrl.text.trim(),
          lastName: lastNameCtrl.text.trim(),
          phoneNumber: phoneCtrl.text.trim(),
          address: addressCtrl.text.isEmpty ? null : addressCtrl.text.trim(),
          city: cityCtrl.text.isEmpty ? null : cityCtrl.text.trim(),
          postalCode: postalCodeCtrl.text.isEmpty ? null : postalCodeCtrl.text.trim(),
          dob: dobCtrl.text.isEmpty ? null : formatDate(dobCtrl.text.trim(), inputFormat: 'dd/MM/yyyy', outputFormat: 'yyyy-MM-dd'),
          gender: gender.value,
          company: companyCtrl.text.isEmpty ? null : companyCtrl.text.trim(),
          enableReminder: enableReminders.value,
          imageUrl: imageUrl.value,
        );

        log(runtimeType.toString(), 'Request => ${request.toJson()}');

        final result = await _commonRepository.updateProfile(request);
        result.handle(
          success: (value) {
            Loader.hide();
            final prefs = Prefs();
            if (value.data?.user?.email != null && value.data?.user?.email?.isNotEmpty == true) prefs.putData(Prefs.email, value.data?.user?.email ?? "");
            if (value.data?.user?.phoneNumber != null) prefs.putData(Prefs.phoneNumber, value.data?.user?.phoneNumber ?? "");
            if (value.data?.user?.firstName != null && value.data?.user?.firstName?.isNotEmpty == true) {
              prefs.putData(Prefs.firstName, value.data?.user?.firstName ?? "");
            }
            if (value.data?.user?.lastName != null && value.data?.user?.lastName?.isNotEmpty == true) {
              prefs.putData(Prefs.lastName, value.data?.user?.lastName ?? "");
            }
            if (value.data?.user?.imageUrl != null && value.data?.user?.imageUrl?.isNotEmpty == true) {
              prefs.putData(Prefs.image, value.data?.user?.imageUrl ?? "");
            }

            bool isControllerRegistered = Get.isRegistered<ClientDashboardController>();
            if (isControllerRegistered) {
              ClientDashboardController ctrl = Get.find();

              ctrl.userDisplayName.value = Get.find<SessionService>().userDisplayName;
              ctrl.userDisplayImage.value = Get.find<SessionService>().userDisplayImage;
            }

            // Defer sheet to next frame so Loader.hide() from finally can close the loader first
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (Get.context == null) return;
              Notifier.openSheet(Get.context as BuildContext,
                  title: "Success",
                  type: SheetType.success,
                  message: value.message ?? 'Profile updated successfully',
                  isDismissable: false,
                  isShowCloseIcon: false,
                  showSecondaryButton: false, onPrimaryPressed: () {
                Get.back(result: true);
              });
            });
          },
          contextTag: 'edit-profile',
        );
      } catch (e) {
        Notifier.info('Failed to update profile: $e');
      } finally {
        Loader.hide();
      }
    }
  }

  void onDeleteAccount() {
    Notifier.info('Delete account (coming soon)');
  }

  void showProfileData({User? profile}) {
    log(runtimeType.toString(), 'First Name => ${Prefs().getData(Prefs.firstName)}');
    firstNameCtrl.text = Prefs().getData(Prefs.firstName);
    lastNameCtrl.text = Prefs().getData(Prefs.lastName);
    phoneCtrl.text = Prefs().getData(Prefs.phoneNumber);
    emailCtrl.text = Prefs().getData(Prefs.email);
    firstNameCtrl.text = Prefs().getData(Prefs.firstName);
    firstNameCtrl.text = Prefs().getData(Prefs.firstName);

    if (profile != null) {
      enableReminders.value = profile.enableReminder ?? false;
      gender.value = profile.gender;
      addressCtrl.text = profile.address ?? "";
      cityCtrl.text = profile.city ?? "";
      postalCodeCtrl.text = profile.postalCode ?? "";
      companyCtrl.text = profile.company ?? "";
      if (profile.dob != null) {
        dobCtrl.text = formatDate(profile.dob ?? "", inputFormat: 'yyyy-MM-dd', outputFormat: 'dd/MM/yyyy');
      }
    }
  }

  Future<void> getProfile() async {
    Loader.show();

    try {
      final result = await _commonRepository.getProfile();
      result.handle(
        success: (value) {
          Loader.hide();
          final prefs = Prefs();
          if (value.data?.user?.email != null && value.data?.user?.email?.isNotEmpty == true) prefs.putData(Prefs.email, value.data?.user?.email ?? "");
          if (value.data?.user?.phoneNumber != null) prefs.putData(Prefs.phoneNumber, value.data?.user?.phoneNumber ?? "");
          if (value.data?.user?.firstName != null && value.data?.user?.firstName?.isNotEmpty == true) {
            prefs.putData(Prefs.firstName, value.data?.user?.firstName ?? "");
          }
          if (value.data?.user?.lastName != null && value.data?.user?.lastName?.isNotEmpty == true) {
            prefs.putData(Prefs.lastName, value.data?.user?.lastName ?? "");
          }
          if (value.data?.user?.imageUrl != null && value.data?.user?.imageUrl?.isNotEmpty == true) {
            prefs.putData(Prefs.image, value.data?.user?.imageUrl ?? "");
            imageUrl.value = value.data?.user?.imageUrl ?? "";
          }

          profileText.value = 'Profile Completion: ${value.data?.profileCompletion?.toInt()}%';
          profileStatus.value = value.data?.profileCompletion?.toInt() ?? 0;

          showProfileData(profile: value.data?.user);
        },
        contextTag: 'get-profile',
      );
    } catch (e) {
      Notifier.info('Failed to update profile: $e');
    } finally {
      Loader.hide();
    }
  }
}
