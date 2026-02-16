import 'dart:convert';

import 'package:ccs_app/export.dart';

import '../../../network/repository/client_repository.dart';
import '../../../network/request/create_job_request.dart';
import '../../../network/response/property_list_response.dart';

class CreateJobController extends GetxController {
  final ClientRepository _clientRepository = ClientRepository();
  final formKey = GlobalKey<FormState>();
  final notesController = TextEditingController();
  final dateDisplayController = TextEditingController();
  final startTimeDisplayController = TextEditingController();
  final endTimeDisplayController = TextEditingController();
  final cleanersNeededController = TextEditingController();

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

  static const maxNotesLength = 100;

  final isLoadingProperties = false.obs;
  final properties = <PropertyModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    notesController.addListener(() => notesLength.value = notesController.text.length);
    cleanersNeededController.text = '1';
    _loadProperties();
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
    startTimeDisplayController.text = t != null ? '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}' : '';
  }

  void setEndTime(TimeOfDay? t) {
    endTime.value = t;
    endTimeDisplayController.text = t != null ? '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}' : '';
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

  final isSaving = false.obs;

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;

    if (isSaving.value) return;
    isSaving.value = true;

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
      final req = CreateJobRequest(
        propertyId: properties.firstWhereOrNull((item) => item.propertyName?.toLowerCase() == selectedProperty.value?.toLowerCase())?.id,
        date: jobStartDate.value?.toDisplayDate('yyyy-MM-dd'),
        startTime: startTime.value != null ? '${startTime.value!.hour.toString().padLeft(2, '0')}:${startTime.value!.minute.toString().padLeft(2, '0')}' : null,
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
      );
      log(runtimeType.toString(), jsonEncode(req));

      (Get.context as BuildContext).hideKeyboard();

      final result = await _clientRepository.createJob(req);
      result.handle(
        success: (value) async {
          Notifier.openSheet(Get.context as BuildContext, title: "Success", message: "${value.message}", isDismissable: false, isShowCloseIcon: false,
              showSecondaryButton: false,
              onPrimaryPressed: () {
            Get.back(result: {'isUpdate': true});
          });
        },
        contextTag: 'create-job',
      );
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> _loadProperties() async {
    isLoadingProperties.value = true;
    try {
      final result = await _clientRepository.listProperties();
      result.handle(
        success: (response) {
          final raw = response.data;
          if (raw != null && raw.isNotEmpty) {
            properties.assignAll(raw);
          }
        },
      );
    } finally {
      isLoadingProperties.value = false;
    }
  }
}
