/// Client-facing job for listing (small set) and detail (full fields).
/// Aligns with CreateJobRequest and website job detail specs.
class ClientJob {
  const ClientJob({
    required this.id,
    required this.clientName,
    required this.jobType,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.propertyOneLine,
    this.recurrence,
    this.jobEndDate,
    this.propertyLabel,
    this.accessToProperty,
    this.address,
    this.city,
    this.postalCode,
    this.propertyType,
    this.propertySubtype,
    this.animals,
    this.staffPreference,
    this.hoover,
    this.provideCleaningProducts = false,
    this.provideWashingMachine = false,
    this.provideDryer = false,
    this.invoicePaymentSource,
    this.cleanersNeeded = 1,
    this.additionalNotes,
    this.cleaners = const [],
  });

  final String id;
  final String clientName;
  final String jobType;
  final DateTime date;
  final String startTime; // "HH:mm"
  final String endTime;
  final String status; // e.g. "Scheduled", "Completed", "Cancelled"
  final String propertyOneLine;
  final String? recurrence; // e.g. "Weekly", "One-off"
  final DateTime? jobEndDate;
  final String? propertyLabel;
  final String? accessToProperty;
  final String? address;
  final String? city;
  final String? postalCode;
  final String? propertyType;
  final String? propertySubtype;
  final String? animals;
  final String? staffPreference;
  final String? hoover;
  final bool provideCleaningProducts;
  final bool provideWashingMachine;
  final bool provideDryer;
  final String? invoicePaymentSource;
  final int cleanersNeeded;
  final String? additionalNotes;
  final List<ClientJobCleaner> cleaners;

  /// Placeholder list for listing + detail until API is connected.
  static List<ClientJob> get demoJobs => [
        ClientJob(
          id: '1',
          clientName: 'Jane Smith',
          jobType: 'Deep clean',
          date: DateTime.now().add(const Duration(days: 2)),
          startTime: '09:00',
          endTime: '12:00',
          status: 'Scheduled',
          propertyOneLine: '12 Maple St, London',
          recurrence: 'One-off',
          jobEndDate: DateTime.now().add(const Duration(days: 2)),
          propertyLabel: '12 Maple St',
          accessToProperty: 'Client Will Open',
          address: '12 Maple St',
          city: 'London',
          postalCode: 'SW1A 1AA',
          propertyType: 'House',
          propertySubtype: 'Semi-detached',
          animals: 'None',
          staffPreference: 'No preference',
          hoover: 'Yes',
          provideCleaningProducts: true,
          provideWashingMachine: true,
          provideDryer: false,
          invoicePaymentSource: 'Residential',
          cleanersNeeded: 1,
          additionalNotes: 'Please use the side door.',
          cleaners: [
            ClientJobCleaner(name: 'Alex Cleaner', status: 'Assigned', avatarUrl: null),
          ],
        ),
        ClientJob(
          id: '2',
          clientName: 'Office Co',
          jobType: 'Regular clean',
          date: DateTime.now().add(const Duration(days: 5)),
          startTime: '08:00',
          endTime: '10:00',
          status: 'Scheduled',
          propertyOneLine: '45 Business Park, Reading',
          recurrence: 'Weekly',
          propertyLabel: '45 Business Park',
          accessToProperty: 'Reception/Concierge',
          staffPreference: 'Female',
          hoover: 'No',
          provideCleaningProducts: false,
          invoicePaymentSource: 'Commercial',
          cleanersNeeded: 2,
          cleaners: const [],
        ),
        ClientJob(
          id: '3',
          clientName: 'John Doe',
          jobType: 'End of tenancy',
          date: DateTime.now().subtract(const Duration(days: 3)),
          startTime: '10:00',
          endTime: '16:00',
          status: 'Completed',
          propertyOneLine: '7 Oak Lane, Birmingham',
        ),
      ];

  static ClientJob? byId(String id) {
    try {
      return demoJobs.firstWhere((j) => j.id == id);
    } catch (_) {
      return null;
    }
  }
}

class ClientJobCleaner {
  const ClientJobCleaner({
    required this.name,
    required this.status,
    this.avatarUrl,
  });

  final String name;
  final String status; // e.g. "Assigned", "Confirmed"
  final String? avatarUrl;
}
