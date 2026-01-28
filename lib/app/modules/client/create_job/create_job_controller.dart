
import 'package:ccs_app/export.dart';
import '../../../model/create_job_request.dart';

class CreateJobController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final notesController = TextEditingController();

  final selectedPropertyId = Rxn<String>();
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

  @override
  void onInit() {
    super.onInit();
    notesController.addListener(() => notesLength.value = notesController.text.length);
  }

  @override
  void onClose() {
    notesController.dispose();
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

  void setJobStartDate(DateTime? d) => jobStartDate.value = d;
  void setStartTime(TimeOfDay? t) => startTime.value = t;
  void setEndTime(TimeOfDay? t) => endTime.value = t;

  void submit() {
    if (!formKey.currentState!.validate()) return;
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
      propertyId: selectedPropertyId.value,
      propertyLabel: selectedPropertyId.value == null ? null : 'Property',
      jobStartDate: jobStartDate.value,
      jobEndDate: jobStartDate.value,
      startTime: startTime.value != null ? '${startTime.value!.hour}:${startTime.value!.minute.toString().padLeft(2, '0')}' : null,
      endTime: endTime.value != null ? '${endTime.value!.hour}:${endTime.value!.minute.toString().padLeft(2, '0')}' : null,
      invoicePaymentSource: invoicePaymentSource.value.isEmpty ? null : invoicePaymentSource.value,
      cleanersNeeded: cleanersNeeded.value,
      staffPreference: staffPreference.value,
      accessToProperty: accessToProperty.value,
      hoover: hoover.value,
      provideCleaningProducts: provideCleaningProducts.value,
      provideWashingMachine: provideWashingMachine.value,
      provideDryer: provideDryer.value,
      additionalNotes: notesController.text.isEmpty ? null : notesController.text,
    );
    // Placeholder: replace with API call
    Notifier.success('Job created (API coming soon)');
    Get.back();
  }
}
