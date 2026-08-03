import 'dart:convert';

import 'package:ccs_app/app/modules/client/upcoming_job/upcoming_job_controller.dart';
import 'package:ccs_app/export.dart';

import '../../../network/repository/client_repository.dart';
import '../../../network/repository/common_repository.dart';
import '../../../network/request/create_job_request.dart';
import '../../../network/response/cleaning_type_response.dart';
import '../../../network/response/get_client_job_details_response.dart';
import '../../../network/response/property_list_response.dart';
import '../dashboard/client_dashboard_controller.dart';

class CreateJobController extends GetxController {
  final ClientRepository _clientRepository = ClientRepository();
  final CommonRepository _commonRepository = CommonRepository();
  final formKey = GlobalKey<FormState>();
  final notesController = TextEditingController();

  // final jobTitleController = TextEditingController();
  final dateDisplayController = TextEditingController();
  final startTimeDisplayController = TextEditingController();
  final endTimeDisplayController = TextEditingController();
  final cleanersNeededController = TextEditingController();
  final cleaningTypeCtrl = TextEditingController();

  final selectedProperty = Rxn<String>();
  final jobStartDate = Rxn<DateTime>();
  final startTime = Rxn<TimeOfDay>();
  final endTime = Rxn<TimeOfDay>();
  final invoicePaymentSource = ''.obs;
  final cleanersNeeded = 1.obs;
  final staffPreference = 'Male'.obs;
  final accessToProperty = 'Client Will Open'.obs;
  final hoover = 'No'.obs;
  final provideCleaningProducts = false.obs;
  final provideWashingMachine = false.obs;
  final provideDryer = false.obs;
  final notesLength = 0.obs;

  static const List<String> hooverOptions = ['No', 'Yes', 'I will get one'];
  static const List<String> staffPreferenceOptions = ['Male', 'Female', 'No Preference'];
  static const List<String> accessOptions = ['Client Will Open', 'Reception/Concierge', 'Key', 'Other'];

  /// Match API string to a known option (case-insensitive); else [fallback].
  static String pickOption(String? raw, List<String> options, String fallback) {
    if (raw == null || raw.trim().isEmpty) return fallback;
    final match = options.firstWhereOrNull((o) => o.toLowerCase() == raw.trim().toLowerCase());
    return match ?? fallback;
  }

  void applyPropertyDefaults(PropertyModel? property) {
    staffPreference.value = pickOption(property?.staffPreference, staffPreferenceOptions, 'Male');
    accessToProperty.value = pickOption(property?.accessToProperty, accessOptions, 'Client Will Open');
    hoover.value = pickOption(property?.hoover, hooverOptions, 'No');
    provideCleaningProducts.value = property?.provideCleaningProducts ?? false;
    provideWashingMachine.value = property?.provideWashingMachine ?? false;
    provideDryer.value = property?.provideDryer ?? false;
  }

  static const maxNotesLength = 100;

  final properties = <PropertyModel>[].obs;
  final cleaningTypeList = <CleaningTypeModel>[].obs;
  final mainCleaningTypeList = <CleaningTypeModel>[].obs;
  var isEdit = false;
  ClientJobDetails? jobDetails;
  var isLoading = false.obs;
  var isLoadingCleaningType = false.obs;
  var searchFocus = FocusNode();
  var searchController = TextEditingController();
  var searchTerm = ''.obs;
  var prevSearch = '';

  @override
  void onInit() {
    super.onInit();
    notesController.addListener(() => notesLength.value = notesController.text.length);
    cleanersNeededController.text = '1';

    final arg = Get.arguments;
    if (arg is ClientJobDetails) {
      jobDetails = arg;
      isEdit = true;
      log(runtimeType.toString(), 'JOB DETAILS ${jobDetails?.toJson()}');
      initForm();
    }

    _loadProperties();
    _loadCleaningType(isFromInit: true);

    searchController.addListener(() {
      if (searchController.text.trim().length > 2) {
        if (searchController.text.isNotEmpty) {
          if (prevSearch == searchController.text.trim()) return;
        }
        _loadCleaningType(isFromSearch: true);
      } else if (searchController.text.isEmpty) {
        if (mainCleaningTypeList.isNotEmpty) {
          cleaningTypeList.clear();
          cleaningTypeList.addAll(mainCleaningTypeList);
        }
      }
    });
  }

  void initForm() {
    if (jobDetails?.date != null) setJobStartDate(DateTime.parse(jobDetails?.date ?? ""));
    if (jobDetails?.startTime != null) setStartTime(CcsDateUtils.parseTimeOfDay(jobDetails?.startTime ?? ""));
    if (jobDetails?.endTime != null) setEndTime(CcsDateUtils.parseTimeOfDay(jobDetails?.endTime ?? ""));
    invoicePaymentSource.value = jobDetails?.jobType?.capitalizeFirst ?? '';
    cleanersNeededController.text = "${jobDetails?.numberOfCleaners.toString()}";
    cleanersNeeded.value = jobDetails?.numberOfCleaners?.toInt() ?? 1;
    staffPreference.value = pickOption(jobDetails?.staffPreference, staffPreferenceOptions, 'Male');
    accessToProperty.value = pickOption(jobDetails?.accessToProperty, accessOptions, 'Client Will Open');
    hoover.value = pickOption(jobDetails?.hoover, hooverOptions, 'No');
    provideCleaningProducts.value = jobDetails?.provideCleaningProducts ?? false;
    provideWashingMachine.value = jobDetails?.provideWashingMachine ?? false;
    provideDryer.value = jobDetails?.provideDryer ?? false;
    notesController.text = jobDetails?.additionalDetails ?? '';
    notesLength.value = notesController.text.length;
  }

  @override
  void onClose() {
    notesController.dispose();
    dateDisplayController.dispose();
    startTimeDisplayController.dispose();
    endTimeDisplayController.dispose();
    cleanersNeededController.dispose();
    super.onClose();
  }

  String? validateProperty(String? v) {
    if (v == null || v.isEmpty || v == 'Select') return 'Select a property';
    return null;
  }

  String? validateRequired(String? v, [String name = 'This field']) {
    if (v == null || v.isEmpty) return '$name is required';
    return null;
  }

  String? validateNotes(String? v) {
    if (v != null && v.length > maxNotesLength) return 'Max $maxNotesLength characters';
    return null;
  }

  void setJobStartDate(DateTime? d) {
    jobStartDate.value = d;
    dateDisplayController.text = d != null ? CcsDateUtils.forInput(d) : '';
  }

  void setStartTime(TimeOfDay? t) {
    startTime.value = t;
    startTimeDisplayController.text = t != null ? _formatTimeWithAmPm(t) : '';
  }

  void setEndTime(TimeOfDay? t) {
    endTime.value = t;
    endTimeDisplayController.text = t != null ? _formatTimeWithAmPm(t) : '';
  }

  String _formatTimeWithAmPm(TimeOfDay time) {
    final period = time.hour >= 12 ? 'PM' : 'AM';
    final hour12 = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour12:$minute $period';
  }

  String? validateCleanersNeeded(String? v) {
    if (v == null || v.isEmpty) return 'Cleaner(s) needed is required';
    final n = int.tryParse(v);
    if (n == null || n < 1 || n > 20) return 'Enter a number between 1 and 20';
    return null;
  }

  void onCleanersNeededChanged(String v) {
    final n = int.tryParse(v);
    if (n != null) {
      final clamped = n.clamp(1, 20);
      cleanersNeeded.value = clamped;
      if (v != '$clamped') cleanersNeededController.text = '$clamped';
    }
  }

  Future<void> submit(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;

    try {
      final end = endTime.value;
      final start = startTime.value;
      if (start != null && end != null) {
        final startM = start.hour * 60 + start.minute;
        final endM = end.hour * 60 + end.minute;
        if (endM <= startM) {
          Notifier.info('End time must be after start time');
          return;
        }
      }

      if (jobStartDate.value != null && start != null) {
        // Combine selected date + TimeOfDay into DateTime
        DateTime startDateTime = DateTime(
          jobStartDate.value!.year,
          jobStartDate.value!.month,
          jobStartDate.value!.day,
          start.hour,
          start.minute,
        );
        DateTime now = DateTime.now();
        DateTime minAllowedTime = now.add(Duration(hours: 24));

        if (startDateTime.isAfter(minAllowedTime)) {
          // Valid (after 24 hours)
          final req = CreateJobRequest(
            propertyId: properties.firstWhereOrNull((item) => item.propertyName?.toLowerCase() == selectedProperty.value?.toLowerCase())?.id,
            date: jobStartDate.value?.toDisplayDate('yyyy-MM-dd'),
            startTime:
                startTime.value != null ? '${startTime.value!.hour.toString().padLeft(2, '0')}:${startTime.value!.minute.toString().padLeft(2, '0')}' : null,
            endTime: endTime.value != null ? '${endTime.value!.hour.toString().padLeft(2, '0')}:${endTime.value!.minute.toString().padLeft(2, '0')}' : null,
            jobType: invoicePaymentSource.value.isEmpty ? null : invoicePaymentSource.value,
            numberOfCleaners: cleanersNeeded.value,
            staffPreference: staffPreference.value,
            accessToProperty: accessToProperty.value,
            hoover: hoover.value,
            provideCleaningProducts: provideCleaningProducts.value,
            provideWashingMachine: provideWashingMachine.value,
            provideDryer: provideDryer.value,
            additionalDetails: notesController.text.isEmpty ? null : notesController.text,
            cleaningType: cleaningTypeList.firstWhereOrNull((item) => item.name == cleaningTypeCtrl.text)?.id,
          );
          log(runtimeType.toString(), jsonEncode(req));
          Loader.show();
          (Get.context as BuildContext).hideKeyboard();

          if (isEdit) {
            final result = await _clientRepository.updateJob(req, jobDetails?.id?.toInt());
            result.handle(
              success: (value) {
                Loader.hide();
                // Defer sheet to next frame so Loader.hide() from finally can close the loader first
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (Get.context == null) return;
                  Notifier.openSheet(Get.context as BuildContext,
                      title: "Success",
                      type: SheetType.success,
                      message: "${value.message}",
                      isDismissable: false,
                      isShowCloseIcon: false,
                      showSecondaryButton: false, onPrimaryPressed: () {
                    Get.back(result: {'isUpdate': true});
                  });
                });
                updateDashContent();
                updateUpcomingContent();
              },
              contextTag: 'update-job',
            );
          } else {
            final result = await _clientRepository.createJob(req);
            result.handle(
              success: (value) {
                Loader.hide();
                // Defer sheet to next frame so Loader.hide() from finally can close the loader first
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (Get.context == null) return;
                  Notifier.openSheet(Get.context as BuildContext,
                      title: "Success",
                      type: SheetType.success,
                      message: "${value.message}",
                      isDismissable: false,
                      isShowCloseIcon: false,
                      showSecondaryButton: false, onPrimaryPressed: () {
                    Get.back(result: {'isUpdate': true});
                  });
                });
                updateDashContent();
              },
              contextTag: 'create-job',
            );
          }
        } else {
          // Invalid (less than 24 hours) SHOW POP UP
          Notifier.openSheet(context,
              showSecondaryButton: false,
              primaryButtonLabel: 'Okay',
              message: 'Jobs can only be scheduled 24 hours in advance. Please pick a time that’s at least a day from now.');
        }
      }
    } finally {
      Loader.hide();
    }
  }

  Future<void> _loadProperties() async {
    isLoading.value = true;
    try {
      final result = await _clientRepository.listProperties(withPagination: false);
      result.handle(
        success: (response) {
          final raw = response.data;
          if (raw != null && raw.properties?.isNotEmpty == true) {
            properties.assignAll(raw.properties as Iterable<PropertyModel>);
          }

          if (properties.isNotEmpty) {
            if (isEdit) {
              selectedProperty.value = jobDetails?.property?.propertyName;
            }
          }
        },
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadCleaningType({bool isFromSearch = false, bool isFromInit = false}) async {
    isLoadingCleaningType.value = true;
    try {
      final result = await _commonRepository.getCleaningTypes(search: searchController.text);
      result.handle(
        success: (response) {
          final raw = response.data;
          cleaningTypeList.clear();
          if (!isFromSearch) {
            mainCleaningTypeList.clear();
          } else {
            prevSearch = searchController.text.trim();
          }
          if (raw != null && raw.isNotEmpty) {
            cleaningTypeList.assignAll(raw);
            if (!isFromSearch) {
              mainCleaningTypeList.assignAll(cleaningTypeList);
            }
          }

          if (searchController.text.isEmpty) {
            cleaningTypeList.clear();
            cleaningTypeList.addAll(mainCleaningTypeList);
          }

          if (isEdit && isFromInit) {
            var item = cleaningTypeList.firstWhereOrNull((item) => item.name == (jobDetails?.cleaningType?.name ?? ''));
            if (item != null) {
              cleaningTypeCtrl.text = item.name ?? '';
              var index = cleaningTypeList.indexOf(item);
              cleaningTypeList[index].isSelect = true;
              if (cleaningTypeList.length == mainCleaningTypeList.length) mainCleaningTypeList[index].isSelect = true;
            }
          }
        },
      );
    } finally {
      isLoadingCleaningType.value = false;
    }
  }

  void updateDashContent() {
    bool isControllerRegistered = Get.isRegistered<ClientDashboardController>();
    if (isControllerRegistered) {
      ClientDashboardController ctrl = Get.find();
      ctrl.getClientDash(isLoaderShown: false);
    }
  }

  void updateUpcomingContent() {
    bool isControllerRegistered = Get.isRegistered<UpcomingJobController>();
    if (isControllerRegistered) {
      UpcomingJobController ctrl = Get.find();
      ctrl.jobCurrentPage = 1;
      ctrl.fetchJobs(isLoaderShown: false);
    }
  }
}
