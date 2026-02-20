import 'dart:io';

import 'package:ccs_app/app/modules/cleaner/dashboard/cleaner_dashboard_controller.dart';
import 'package:ccs_app/app/network/repository/cleaner_repository.dart';
import 'package:ccs_app/app/services/pref.dart';
import 'package:ccs_app/export.dart';
import 'package:dio/dio.dart' as dio;
import 'package:image_picker/image_picker.dart';

import '../../../network/repository/common_repository.dart';
import '../../../network/request/staff_edit_profile_request.dart';
import '../../../network/response/get_cleaning_service_response.dart';
import '../../../network/response/get_immigrations_response.dart';
import '../../../network/response/profile_response.dart';
import '../../../services/onesignal_service.dart';
import '../../../services/session_service.dart';

class CleanerEditProfileController extends GetxController {
  final CommonRepository _commonRepository = CommonRepository();
  final pickedImage = Rx<File?>(null);
  final firstNameCtrl = TextEditingController();
  final localWorkingAreaCtrl = TextEditingController();
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

  final nationalInsuranceNumberCtrl = TextEditingController();
  final shareCodeCtrl = TextEditingController();

  final gender = Rxn<String>();
  final relationship = Rxn<String>();
  final driver = Rxn<String>();
  final children = Rxn<String>();
  final immigrationStatus = Rxn<String>();
  final enableReminders = false.obs;
  final isStudent = false.obs;
  final scheduleValidFrom = Rx<DateTime>(DateTime.now());

  List<String> genderOptions = ['Male', 'Female', 'Other', 'Prefer not to say'];
  List<String> relationshipOptions = ['Aunt', 'Boyfriend', 'Friend', 'Brother', 'Sister', 'Other'];
  List<String> childrenOptions = ['No', '1', '2', '3', '4', '5+'];
  List<String> driverOptions = ['Yes, I have a car', "Yes, but I don't have a car", 'No'];

  final CleanerRepository _cleanerRepository = CleanerRepository();
  RxList<Services> cleaningServices = <Services>[].obs;
  RxList<ImmigrationsModel> immigrationList = <ImmigrationsModel>[].obs;
  var isCleaningServicesFetching = false.obs;
  var isImmigrationsFetching = false.obs;
  RxString imageUrl = "".obs;

  User? profile;

  @override
  Future<void> onInit() async {
    super.onInit();
    await getCleaningServices();
    await getImmigrations();
    showProfileData();
  }

  @override
  void onReady() {
    getProfile();
    super.onReady();
  }

  @override
  void onClose() {
    firstNameCtrl.dispose();
    localWorkingAreaCtrl.dispose();
    bankNameCtrl.dispose();
    yourNameCtrl.dispose();
    accountNumberCtrl.dispose();
    sortCodeCtrl.dispose();
    fullNameCtrl.dispose();
    lastNameCtrl.dispose();
    phoneCtrl.dispose();
    contactCtrl.dispose();
    postalCodeCtrl.dispose();
    emailCtrl.dispose();
    hobbiesCtrl.dispose();
    cityCtrl.dispose();
    dobCtrl.dispose();
    addressCtrl.dispose();
    nationalInsuranceNumberCtrl.dispose();
    shareCodeCtrl.dispose();

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
    if (addressCtrl.text.trim().isEmpty) {
      Notifier.info('Address is required');
      return;
    }
    if (cityCtrl.text.trim().isEmpty) {
      Notifier.info('City is required');
      return;
    }

    if (pickedImage.value != null) {
      Loader.show();

      var value = await dio.MultipartFile.fromFile(pickedImage.value!.path, filename: "image_${DateTime.now()}.jpg").then((value) {
        return value;
      });

      final data = <String, dynamic>{};
      data["file"] = value;
      data["mediaable_type"] = 'App\\Models\\User';
      data["mediaable_id"] = '1';
      data["media_type"] = 'profile';

      log(runtimeType.toString(), 'Media Upload Data => $data');

      var result = await _commonRepository.mediaUpload(data);
      result.handle(
        success: (value) {
          Loader.hide();
          imageUrl.value = value.data?.fileUrl ?? "";
        },
        onError: (_) {
          Loader.hide();
        },
        contextTag: 'media-upload',
      );
    }

    Loader.show();

    try {
      List<num> cleaningServicesId = [];

      for (var item in cleaningServices) {
        item.options?.forEach((option) {
          if (option.isSelected == true && option.id != null) cleaningServicesId.add(option.id!);
        });
      }

      var request = StaffEditProfileRequest(
        imageUrl: imageUrl.value,
        firstName: firstNameCtrl.text.trim(),
        lastName: lastNameCtrl.text.trim(),
        phoneNumber: phoneCtrl.text.trim(),
        address: addressCtrl.text.isEmpty ? null : addressCtrl.text.trim(),
        city: cityCtrl.text.isEmpty ? null : cityCtrl.text.trim(),
        postalCode: postalCodeCtrl.text.isEmpty ? null : postalCodeCtrl.text.trim(),
        dob: dobCtrl.text.isEmpty ? null : formatDate(dobCtrl.text.trim(), inputFormat: 'dd/MM/yyyy', outputFormat: 'yyyy-MM-dd'),
        gender: gender.value,
        enableReminder: enableReminders.value,
        immigrationStatus: immigrationList.firstWhereOrNull((item) => item.name == immigrationStatus.value)?.id,
        nationalInsuranceNumber: nationalInsuranceNumberCtrl.text.isEmpty ? null : nationalInsuranceNumberCtrl.text.trim(),
        shareCode: shareCodeCtrl.text.isEmpty ? null : shareCodeCtrl.text.trim(),
        hobbies: hobbiesCtrl.text.isEmpty ? null : hobbiesCtrl.text.trim(),
        nextOfKinName: fullNameCtrl.text.isEmpty ? null : fullNameCtrl.text.trim(),
        nextOfKinRelationship: relationship.value?.isEmpty == true ? null : relationship.value,
        nextOfKinContact: contactCtrl.text.isEmpty ? null : contactCtrl.text.trim(),
        drives: driver.value,
        localAreas: localWorkingAreaCtrl.text.isEmpty ? null : localWorkingAreaCtrl.text.trim(),
        hasChildren: children.value,
        preferredStartDate: scheduleValidFrom.value.toDisplayDate('yyyy-MM-dd'),
        cleaningServices: cleaningServicesId.isEmpty ? null : cleaningServicesId,
        bankName: bankNameCtrl.text.isEmpty ? null : bankNameCtrl.text.trim(),
        accountHolderName: yourNameCtrl.text.isEmpty ? null : yourNameCtrl.text.trim(),
        accountNumber: accountNumberCtrl.text.isEmpty ? null : accountNumberCtrl.text.trim(),
        sortCode: sortCodeCtrl.text.isEmpty ? null : sortCodeCtrl.text.trim(),
        email: emailCtrl.text.isEmpty ? null : emailCtrl.text.trim(),
        isStudent: isStudent.value,
      );

      log(runtimeType.toString(), 'Request => ${request.toJson()}');

      final result = await _cleanerRepository.updateProfile(request);
      result.handle(
        success: (value) {
          Loader.hide();
          final prefs = Prefs();
          if (value.data?.email != null && value.data?.email?.isNotEmpty == true) prefs.putData(Prefs.email, value.data?.email ?? "");
          if (value.data?.phoneNumber != null) prefs.putData(Prefs.phoneNumber, value.data?.phoneNumber ?? "");
          if (value.data?.firstName != null && value.data?.firstName?.isNotEmpty == true) {
            prefs.putData(Prefs.firstName, value.data?.firstName ?? "");
          }
          if (value.data?.lastName != null && value.data?.lastName?.isNotEmpty == true) {
            prefs.putData(Prefs.lastName, value.data?.lastName ?? "");
          }
          if (value.data?.imageUrl != null && value.data?.imageUrl?.isNotEmpty == true) {
            prefs.putData(Prefs.image, value.data?.imageUrl ?? "");
          }

          bool isControllerRegistered = Get.isRegistered<CleanerDashboardController>();
          if (isControllerRegistered) {
            CleanerDashboardController ctrl = Get.find();
            ctrl.userDisplayName.value = Get.find<SessionService>().userDisplayName;
            ctrl.userDisplayImage.value = Get.find<SessionService>().userDisplayImage;
          }

          // Defer sheet to next frame so Loader.hide() from finally can close the loader first
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (Get.context == null) return;
            Notifier.openSheet(Get.context as BuildContext,
                title: "Success",
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

  void setScheduleValidFrom(DateTime d) {
    scheduleValidFrom.value = DateTime(d.year, d.month, d.day);
  }

  void showProfileData() {
    log(runtimeType.toString(), 'First Name => ${Prefs().getData(Prefs.firstName)}');
    firstNameCtrl.text = Prefs().getData(Prefs.firstName);
    lastNameCtrl.text = Prefs().getData(Prefs.lastName);
    phoneCtrl.text = Prefs().getData(Prefs.phoneNumber);
    emailCtrl.text = Prefs().getData(Prefs.email);

    if (profile != null) {
      enableReminders.value = profile?.enableReminder ?? false;
      gender.value = profile?.gender;
      addressCtrl.text = profile?.address ?? "";
      cityCtrl.text = profile?.city ?? "";
      postalCodeCtrl.text = profile?.postalCode ?? "";
      gender.value = profile?.gender;
      if (profile?.dob != null) {
        dobCtrl.text = formatDate(profile?.dob ?? "", inputFormat: 'yyyy-MM-dd', outputFormat: 'dd/MM/yyyy');
      }
      if (profile?.immigration != null) {
        immigrationStatus.value = profile?.immigration?.name;
      }
      hobbiesCtrl.text = profile?.hobbies ?? "";
      isStudent.value = profile?.isStudent ?? false;

      if (profile?.cleaningServices != null) {
        if (cleaningServices.isNotEmpty) {
          profile?.cleaningServices?.forEach((item) {
            item.options?.forEach((op) {
              for (var cl in cleaningServices) {
                cl.options?.forEach((inner) {
                  if (inner.id == op.id) {
                    inner.isSelected = true;
                  }
                });
              }
            });
          });
          cleaningServices.refresh();
        }
      }

      shareCodeCtrl.text = profile?.shareCode ?? "";

      nationalInsuranceNumberCtrl.text = profile?.nationalInsuranceNumber ?? "";

      fullNameCtrl.text = profile?.nextOfKinName ?? "";
      relationship.value = profile?.nextOfKinRelationship;
      contactCtrl.text = profile?.nextOfKinContact ?? "";
      localWorkingAreaCtrl.text = profile?.localAreas ?? "";
      children.value = profile?.hasChildren;
      driver.value = profile?.drives;

      if (profile?.preferredStartDate != null) {
        setScheduleValidFrom(DateTime.parse(profile?.preferredStartDate ?? ""));
      }
      bankNameCtrl.text = profile?.bankName ?? "";
      yourNameCtrl.text = profile?.accountHolderName ?? "";
      accountNumberCtrl.text = profile?.accountNumber ?? "";
      sortCodeCtrl.text = profile?.sortCode ?? "";
    }
  }

  Future<void> getCleaningServices() async {
    isCleaningServicesFetching.value = true;
    try {
      final result = await _cleanerRepository.getCleaningServices();
      result.handle(
        success: (value) {
          isCleaningServicesFetching.value = false;
          cleaningServices.clear();
          cleaningServices.addAll(value.data?.services as Iterable<Services>);
        },
        contextTag: 'get-cleaning-services',
      );
    } catch (e) {
      await Notifier.apiError(e, contextTag: 'get-cleaning-services');
    } finally {
      isCleaningServicesFetching.value = false;
    }
  }

  Future<void> getImmigrations() async {
    isImmigrationsFetching.value = true;
    try {
      final result = await _cleanerRepository.getImmigrations();
      result.handle(
        success: (value) {
          isImmigrationsFetching.value = false;
          immigrationList.clear();
          immigrationList.addAll(value.data as Iterable<ImmigrationsModel>);
        },
        contextTag: 'get-immigrations',
      );
    } catch (e) {
      await Notifier.apiError(e, contextTag: 'get-immigrations');
    } finally {
      isImmigrationsFetching.value = false;
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

          profile = value.data?.user;
          showProfileData();
        },
        contextTag: 'get-profile',
      );
    } catch (e) {
      Notifier.info('Failed to update profile: $e');
    } finally {
      Loader.hide();
    }
  }

  Future<void> deleteProfile() async {
    Loader.show();

    try {
      final result = await _commonRepository.deleteProfile();
      result.handle(
        success: (value) async {
          OneSignalService.logout();
          await Prefs().clearAll();
          Loader.hide();

          WidgetsBinding.instance.addPostFrameCallback((_) {
            Notifier.success(value.message ?? "Account deleted successfully!");
            Get.offAllNamed(Routes.LOGIN);
          });
        },
        contextTag: 'delete-profile',
      );
    } catch (e) {
      Notifier.info('Failed to delete profile: $e');
    } finally {
      Loader.hide();
    }
  }
}
