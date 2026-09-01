import 'dart:convert';

import 'package:ccs_app/app/modules/client/upcoming_job/upcoming_job_controller.dart';
import 'package:ccs_app/export.dart';

import '../../../network/repository/client_repository.dart';
import '../../../network/repository/common_repository.dart';
import '../../../network/request/create_job_request.dart';
import '../../../network/response/cleaning_type_response.dart';
import '../../../network/response/end_of_tenancy_bands_response.dart';
import '../../../network/response/get_client_job_details_response.dart';
import '../../../network/response/property_list_response.dart';
import '../dashboard/client_dashboard_controller.dart';

class EotCustomExtraEntry {
  EotCustomExtraEntry();

  final TextEditingController labelController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  void dispose() {
    labelController.dispose();
    noteController.dispose();
  }
}

class CreateJobController extends GetxController {
  final ClientRepository _clientRepository = ClientRepository();
  final CommonRepository _commonRepository = CommonRepository();
  final formKey = GlobalKey<FormState>();
  final notesController = TextEditingController();

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

  final isEndOfTenancy = false.obs;
  final eotBands = <EndOfTenancyBand>[].obs;
  final selectedBand = Rxn<EndOfTenancyBand>();
  final isLoadingEotBands = false.obs;
  final selectedAddOnIds = <num>[].obs;
  final customExtras = <EotCustomExtraEntry>[].obs;
  final wasBandMatchedFromProperty = false.obs;

  static const List<String> hooverOptions = ['No', 'Yes', 'I will get one'];
  static const List<String> staffPreferenceOptions = ['Male', 'Female', 'No Preference'];
  static const List<String> accessOptions = ['Client Will Open', 'Reception/Concierge', 'Key', 'Other'];

  /// Match API string to a known option (case-insensitive); else [fallback].
  static String pickOption(String? raw, List<String> options, String fallback) {
    if (raw == null || raw.trim().isEmpty) return fallback;
    final match = options.firstWhereOrNull((o) => o.toLowerCase() == raw.trim().toLowerCase());
    return match ?? fallback;
  }

  PropertyModel? get selectedPropertyModel => properties.firstWhereOrNull((item) => item.propertyName?.toLowerCase() == selectedProperty.value?.toLowerCase());

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
  var _eotBandsRequestId = 0;

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
    cleaningTypeCtrl.dispose();
    _disposeCustomExtras();
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

  String? validateEotBand(EndOfTenancyBand? v) {
    if (!isEndOfTenancy.value) return null;
    if (v == null) return 'Select a property size';
    return null;
  }

  String? validateEndTime(String? v) {
    if (isEndOfTenancy.value) return null;
    if (endTime.value == null || v == null || v.trim().isEmpty) return 'End Time is required';
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

  void onPropertySelected(String? v) {
    selectedProperty.value = v;
    applyPropertyDefaults(selectedPropertyModel);
    if (isEndOfTenancy.value) {
      loadEotBands();
    }
  }

  void selectCleaningType(CleaningTypeModel item) {
    cleaningTypeCtrl.text = item.name ?? '';
    for (var cl in cleaningTypeList) {
      cl.isSelect = false;
    }
    for (var cl in mainCleaningTypeList) {
      cl.isSelect = false;
    }
    mainCleaningTypeList.firstWhereOrNull((element) => element.name == item.name)?.isSelect = true;
    item.isSelect = true;
    cleaningTypeList.refresh();

    final wasEot = isEndOfTenancy.value;
    isEndOfTenancy.value = item.isEndOfTenancyType;
    if (isEndOfTenancy.value) {
      loadEotBands(restoreFromJob: isEdit && wasEot == false);
    } else if (wasEot) {
      clearEotState();
    }
  }

  Future<void> loadEotBands({bool restoreFromJob = false}) async {
    final propertyId = selectedPropertyModel?.id;
    if (propertyId == null) {
      eotBands.clear();
      selectedBand.value = null;
      selectedAddOnIds.clear();
      wasBandMatchedFromProperty.value = false;
      return;
    }

    final requestId = ++_eotBandsRequestId;
    isLoadingEotBands.value = true;
    try {
      final result = await _clientRepository.getEndOfTenancyBands(propertyId: propertyId);
      if (requestId != _eotBandsRequestId) return;
      result.handle(
        success: (response) {
          eotBands.assignAll(response.data?.bands ?? []);
          final suggestedId = response.data?.suggestedBandId;
          EndOfTenancyBand? match;
          if (restoreFromJob && jobDetails?.endOfTenancyRuleId != null) {
            match = eotBands.firstWhereOrNull((b) => b.id == jobDetails?.endOfTenancyRuleId);
          }
          match ??= eotBands.firstWhereOrNull((b) => b.id == suggestedId);
          wasBandMatchedFromProperty.value = suggestedId != null && match?.id == suggestedId;
          selectBand(match, applyStaffCount: !restoreFromJob);
          if (restoreFromJob) _restoreEotExtras();
        },
        contextTag: 'eot-bands',
      );
    } finally {
      if (requestId == _eotBandsRequestId) {
        isLoadingEotBands.value = false;
      }
    }
  }

  void selectBand(EndOfTenancyBand? band, {bool applyStaffCount = true}) {
    selectedBand.value = band;
    selectedAddOnIds.clear();
    if (applyStaffCount) applyStaffCountFromBand(band);
  }

  void onBandChanged(EndOfTenancyBand? band) {
    wasBandMatchedFromProperty.value = false;
    selectBand(band, applyStaffCount: true);
  }

  void applyStaffCountFromBand(EndOfTenancyBand? band) {
    if (band == null) return;
    final value = band.staffCountValue?.toInt() ?? 1;
    var count = value < 1 ? 1 : value;
    if (band.staffCountMode == 'max_of_value_and_bedrooms') {
      final bedrooms = selectedPropertyModel?.bedrooms?.toInt() ?? 0;
      if (bedrooms > count) count = bedrooms;
    }
    count = count.clamp(1, 20);
    cleanersNeeded.value = count;
    cleanersNeededController.text = '$count';
  }

  void toggleListedAddOn(num? id) {
    if (id == null) return;
    if (selectedAddOnIds.contains(id)) {
      selectedAddOnIds.remove(id);
    } else {
      selectedAddOnIds.add(id);
    }
  }

  bool isListedAddOnSelected(num? id) => id != null && selectedAddOnIds.contains(id);

  void addCustomExtra() {
    customExtras.add(EotCustomExtraEntry());
  }

  void removeCustomExtra(EotCustomExtraEntry extra) {
    customExtras.remove(extra);
    extra.dispose();
  }

  void clearEotState() {
    eotBands.clear();
    selectedBand.value = null;
    selectedAddOnIds.clear();
    wasBandMatchedFromProperty.value = false;
    _disposeCustomExtras();
  }

  void _disposeCustomExtras() {
    for (final extra in customExtras) {
      extra.dispose();
    }
    customExtras.clear();
  }

  void _restoreEotExtras() {
    selectedAddOnIds.assignAll(
      (jobDetails?.addOns ?? []).where((addon) => addon.id != null).map((addon) => addon.id!),
    );

    _disposeCustomExtras();
    for (final extra in jobDetails?.customAddOns ?? []) {
      final entry = EotCustomExtraEntry();
      entry.labelController.text = extra.label ?? '';
      entry.noteController.text = extra.note ?? '';
      customExtras.add(entry);
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

      if (!isEndOfTenancy.value && endTime.value == null) {
        Notifier.info('End Time is required');
        return;
      }

      if (isEndOfTenancy.value && selectedBand.value == null) {
        Notifier.info('Select a property size for End of Tenancy');
        return;
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
          final isEot = isEndOfTenancy.value;
          final req = CreateJobRequest(
            propertyId: selectedPropertyModel?.id,
            date: jobStartDate.value?.toDisplayDate('yyyy-MM-dd'),
            startTime:
                startTime.value != null ? (isEot ? CcsDateTimeX.formatTimeOfDay(startTime.value!) : CcsDateTimeX.formatTimeOfDayShort(startTime.value!)) : null,
            endTime: isEot ? null : (endTime.value != null ? CcsDateTimeX.formatTimeOfDayShort(endTime.value!) : null),
            omitEndTime: isEot,
            jobType: invoicePaymentSource.value.isEmpty ? null : invoicePaymentSource.value,
            numberOfCleaners: cleanersNeeded.value,
            staffPreference: staffPreference.value,
            accessToProperty: accessToProperty.value,
            hoover: hoover.value,
            provideCleaningProducts: provideCleaningProducts.value,
            provideWashingMachine: provideWashingMachine.value,
            provideDryer: provideDryer.value,
            additionalDetails: notesController.text.isEmpty ? null : notesController.text,
            cleaningType: cleaningTypeList.firstWhereOrNull((item) => item.name == cleaningTypeCtrl.text)?.id ??
                mainCleaningTypeList.firstWhereOrNull((item) => item.name == cleaningTypeCtrl.text)?.id,
            endOfTenancyRuleId: isEot ? selectedBand.value?.id : null,
            customAddOns: isEot
                ? customExtras
                    .where((e) => e.labelController.text.trim().isNotEmpty)
                    .map(
                      (e) => JobCustomAddOnRequest(
                        label: e.labelController.text.trim(),
                        note: e.noteController.text.trim().isEmpty ? null : e.noteController.text.trim(),
                      ),
                    )
                    .toList()
                : null,
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
              if (isEndOfTenancy.value || jobDetails?.hasEndOfTenancyDetails == true) {
                isEndOfTenancy.value = true;
                loadEotBands(restoreFromJob: true);
              }
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
              isEndOfTenancy.value = item.isEndOfTenancyType;
              if (isEndOfTenancy.value && selectedPropertyModel != null) {
                loadEotBands(restoreFromJob: true);
              }
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
