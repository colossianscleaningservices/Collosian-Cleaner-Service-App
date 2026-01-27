/// Request payload for creating a cleaning job (client booking).
/// Maps to the "Create a Cleaning Job" form.
class CreateJobRequest {
  CreateJobRequest({
    this.propertyId,
    this.propertyLabel,
    this.jobStartDate,
    this.jobEndDate,
    this.startTime,
    this.endTime,
    this.invoicePaymentSource,
    this.cleanersNeeded = 1,
    this.staffPreference,
    this.accessToProperty,
    this.hoover,
    this.provideCleaningProducts = false,
    this.provideWashingMachine = false,
    this.provideDryer = false,
    this.additionalNotes,
  });

  final String? propertyId;
  final String? propertyLabel;
  final DateTime? jobStartDate;
  final DateTime? jobEndDate;
  final String? startTime; // "HH:mm" or TimeOfDay serialized
  final String? endTime;
  final String? invoicePaymentSource; // e.g. "residential", "commercial"
  final int cleanersNeeded;
  final String? staffPreference; // e.g. "Male", "Female"
  final String? accessToProperty; // e.g. "Client Will Open", "Reception/Concierge"
  final String? hoover; // e.g. "No", "Yes", "I will get one"
  final bool provideCleaningProducts;
  final bool provideWashingMachine;
  final bool provideDryer;
  final String? additionalNotes;
}
