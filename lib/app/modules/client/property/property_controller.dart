import 'package:ccs_app/app/network/repository/client_repository.dart';
import 'package:ccs_app/export.dart';

/// Minimal model for property list items.
class PropertyListItem {
  const PropertyListItem({
    required this.id,
    required this.name,
    required this.addressLine,
    this.propertyType,
    this.city,
    this.postalCode,
  });

  final String id;
  final String name;
  final String addressLine;
  final String? propertyType;
  final String? city;
  final String? postalCode;
}

class PropertyController extends GetxController {
  final ClientRepository _clientRepository = ClientRepository();
  final formKey = GlobalKey<FormState>();

  /// List of properties (from API; fallback to empty until response model is defined).
  final properties = <PropertyListItem>[].obs;
  final isLoadingProperties = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadProperties();
  }

  Future<void> _loadProperties() async {
    isLoadingProperties.value = true;
    try {
      final result = await _clientRepository.listProperties();
      result.when(
        success: (response) {
          final raw = response.data;
          List? list;
          if (raw is Map) {
            list = raw['properties'] ?? raw['data'];
            if (list is! List) list = null;
          } else if (raw is List) {
            list = raw;
          }
          if (list != null && list.isNotEmpty) {
            properties.assignAll(_parsePropertyList(list));
          }
        },
        error: (_) {},
      );
    } finally {
      isLoadingProperties.value = false;
    }
  }

  List<PropertyListItem> _parsePropertyList(dynamic list) {
    final out = <PropertyListItem>[];
    for (final e in list as List) {
      if (e is! Map) continue;
      final id = e['id']?.toString() ?? '';
      if (id.isEmpty) continue;
      final name = e['name']?.toString() ?? '';
      final address = e['address']?.toString() ?? '';
      final city = e['city']?.toString();
      final postalCode = e['postal_code']?.toString();
      final type = e['property_type']?.toString();
      final line = [address, city, postalCode].whereType<String>().where((x) => x.isNotEmpty).join(', ');
      out.add(PropertyListItem(
        id: id,
        name: name.isNotEmpty ? name : 'Property',
        addressLine: line.isNotEmpty ? line : address,
        propertyType: type,
        city: city,
        postalCode: postalCode,
      ));
    }
    return out;
  }

  /// When set, we're on Add Property screen in edit mode.
  final editingProperty = Rxn<PropertyListItem>();

  void goToAddProperty() {
    clearEditing();
    Get.toNamed(Routes.ADD_PROPERTY);
  }

  void goToEditProperty(PropertyListItem property) {
    editingProperty.value = property;
    propertyNameCtrl.text = property.name;
    addressCtrl.text = property.addressLine;
    cityCtrl.text = property.city ?? '';
    postalCodeCtrl.text = property.postalCode ?? '';
    propertyType.value = property.propertyType;
    Get.toNamed(Routes.ADD_PROPERTY);
  }

  void clearHouseFields() {
    subType.value = null;
    numberOfBedroomsCtrl.text = '0';
    numberOfBathroomsCtrl.text = '0';
    numberOfGuestToiletCtrl.text = '0';
    livingRoomCtrl.text = '0';
    officeCtrl.text = '0';
    conservatoryCtrl.text = '0';
    diningRoomCtrl.text = '0';
  }

  void clearEditing() {
    editingProperty.value = null;
    propertyNameCtrl.clear();
    addressCtrl.clear();
    cityCtrl.clear();
    postalCodeCtrl.clear();
    businessType.value = 'Residential';
    propertyType.value = null;
    clearHouseFields();
    hoover.value = 'No';
    staffPreference.value = 'Male';
    accessToProperty.value = 'Client Will Open';
    animals.value = 'No';
    provideCleaningProducts.value = false;
    hasWashingMachine.value = false;
    hasDryer.value = false;
  }

  void confirmDeleteProperty(BuildContext context) {
    final property = editingProperty.value;
    if (property == null) return;
    Notifier.openSheet(
      context,
      type: SheetType.error,
      title: 'Delete property?',
      icon: IconsaxPlusLinear.trash,
      message: 'This will remove "${property.name}" from your properties. This action cannot be undone.',
      primaryButtonLabel: 'Delete',
      secondaryButtonLabel: 'Cancel',
      showPrimaryButton: true,
      showSecondaryButton: true,
      onPrimaryPressed: () => deleteProperty(),
    );
  }

  Future<void> deleteProperty() async {
    final id = editingProperty.value?.id;
    if (id == null) return;
    final jobId = int.tryParse(id);
    if (jobId == null) {
      properties.removeWhere((p) => p.id == id);
      clearEditing();
      Get.back();
      return;
    }
    final result = await _clientRepository.deleteProperty(jobId);
    result.when(
      success: (_) {
        properties.removeWhere((p) => p.id == id);
        clearEditing();
        Get.back();
      },
      error: (e) async => await Notifier.apiError(e, contextTag: 'delete_property'),
    );
  }

  final propertyNameCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final postalCodeCtrl = TextEditingController();

  /// House-specific field controllers (only relevant when propertyType == 'House').
  final numberOfBedroomsCtrl = TextEditingController(text: '0');
  final numberOfBathroomsCtrl = TextEditingController(text: '0');
  final numberOfGuestToiletCtrl = TextEditingController(text: '0');
  final livingRoomCtrl = TextEditingController(text: '0');
  final officeCtrl = TextEditingController(text: '0');
  final conservatoryCtrl = TextEditingController(text: '0');
  final diningRoomCtrl = TextEditingController(text: '0');

  final businessType = 'Residential'.obs;
  final propertyType = Rxn<String>();
  final subType = Rxn<String>();
  final hoover = 'No'.obs;
  final staffPreference = 'Male'.obs;
  final accessToProperty = 'Client Will Open'.obs;
  final animals = 'No'.obs;

  final provideCleaningProducts = false.obs;
  final hasWashingMachine = false.obs;
  final hasDryer = false.obs;

  final isSaving = false.obs;

  static const List<String> businessTypeOptions = ['Residential', 'Commercial'];
  static const List<String> propertyTypeOptions = [
    'House',
    'Flat',
    'Semi-detached',
    'Detached',
    'Bungalow',
    'Other',
  ];
  static const List<String> houseSubTypeOptions = [
    'Flat',
    'Terrace',
    'Detached',
    'Semi-detached',
    'Bungalow',
    'Other',
  ];
  static const List<String> hooverOptions = ['No', 'Yes', 'I will get one'];
  static const List<String> staffPreferenceOptions = ['Male', 'Female', 'No preference'];
  static const List<String> accessOptions = ['Client Will Open', 'Reception/Concierge', 'Key', 'Other'];
  static const List<String> animalsOptions = ['No', 'Yes'];

  String? validateRequired(String? value, String fieldName) {
    return Validator.requiredField(value, fieldName: fieldName);
  }

  Future<void> addProperty() async {

    log(runtimeType.toString(), "Validator : ${formKey.currentState?.validate()}");

    if (formKey.currentState?.validate() != true) return;

    if (isSaving.value) return;
    isSaving.value = true;
    try {
      final name = propertyNameCtrl.text.trim();
      final address = addressCtrl.text.trim();
      final city = cityCtrl.text.trim();
      final code = postalCodeCtrl.text.trim();
      final type = propertyType.value ?? 'Residential';
      final editing = editingProperty.value;
      if (editing != null) {
        final id = int.tryParse(editing.id);
        if (id != null) {
          final result = await _clientRepository.updateProperty(
            id: id,
            name: name.isNotEmpty ? name : null,
            address: address.isNotEmpty ? address : null,
            city: city.isNotEmpty ? city : null,
            postalCode: code.isNotEmpty ? code : null,
            propertyType: type,
            staffPreference: staffPreference.value != 'Male' ? staffPreference.value : null,
          );
          result.when(
            success: (_) async {
              await _loadProperties();
              clearEditing();
              Get.back();
            },
            error: (e) async => await Notifier.apiError(e, contextTag: 'update_property'),
          );
          return;
        }
      }
      final result = await _clientRepository.createProperty(
        name: name.isNotEmpty ? name : 'Property',
        address: address,
        city: city,
        postalCode: code,
        propertyType: type,
        staffPreference: staffPreference.value != 'Male' ? staffPreference.value : null,
      );
      result.when(
        success: (_) async {
          await _loadProperties();
          clearEditing();
          Get.back();
        },
        error: (e) async => await Notifier.apiError(e, contextTag: 'create_property'),
      );
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    propertyNameCtrl.dispose();
    addressCtrl.dispose();
    cityCtrl.dispose();
    postalCodeCtrl.dispose();
    numberOfBedroomsCtrl.dispose();
    numberOfBathroomsCtrl.dispose();
    numberOfGuestToiletCtrl.dispose();
    livingRoomCtrl.dispose();
    officeCtrl.dispose();
    conservatoryCtrl.dispose();
    diningRoomCtrl.dispose();
    super.onClose();
  }
}
