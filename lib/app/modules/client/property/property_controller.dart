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
  final formKey = GlobalKey<FormState>();

  /// List of properties (replace with API later).
  final properties = <PropertyListItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadProperties();
  }

  void _loadProperties() {
    // TODO: load from API. Dummy property for now.
    properties.assignAll([
      const PropertyListItem(
        id: 'dummy-1',
        name: '12 Maple St',
        addressLine: '12 Maple St, London SW1A 1AA',
        propertyType: 'House',
      ),
    ]);
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

  void clearEditing() {
    editingProperty.value = null;
    propertyNameCtrl.clear();
    addressCtrl.clear();
    cityCtrl.clear();
    postalCodeCtrl.clear();
    businessType.value = 'Residential';
    propertyType.value = null;
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
      type: SheetType.info,
      title: 'Delete property?',
      message: 'This will remove "${property.name}" from your properties. This action cannot be undone.',
      primaryButtonLabel: 'Delete',
      secondaryButtonLabel: 'Cancel',
      showPrimaryButton: true,
      showSecondaryButton: true,
      onPrimaryPressed: () {
        deleteProperty();
      },
      onSecondaryPressed: () {},
    );
  }

  void deleteProperty() {
    final id = editingProperty.value?.id;
    if (id != null) {
      properties.removeWhere((p) => p.id == id);
      clearEditing();
      Get.back();
    }
  }

  final propertyNameCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final postalCodeCtrl = TextEditingController();

  final businessType = 'Residential'.obs;
  final propertyType = Rxn<String>();
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
  static const List<String> hooverOptions = ['No', 'Yes', 'I will get one'];
  static const List<String> staffPreferenceOptions = ['Male', 'Female', 'No preference'];
  static const List<String> accessOptions = ['Client Will Open', 'Reception/Concierge', 'Key', 'Other'];
  static const List<String> animalsOptions = ['No', 'Yes'];

  String? validateRequired(String? value, String fieldName) {
    return Validator.requiredField(value, fieldName: fieldName);
  }

  Future<void> addProperty() async {
    if (formKey.currentState?.validate() != true) return;
    if (isSaving.value) return;
    isSaving.value = true;
    try {
      // TODO: call API to create/update property
      await Future<void>.delayed(const Duration(milliseconds: 600));
      final name = propertyNameCtrl.text.trim();
      final address = addressCtrl.text.trim();
      final city = cityCtrl.text.trim();
      final code = postalCodeCtrl.text.trim();
      final line = [address, city, code].where((e) => e.isNotEmpty).join(', ');
      final item = PropertyListItem(
        id: editingProperty.value?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: name.isNotEmpty ? name : 'Property',
        addressLine: line.isNotEmpty ? line : 'No address',
        propertyType: propertyType.value,
        city: city.isNotEmpty ? city : null,
        postalCode: code.isNotEmpty ? code : null,
      );
      if (editingProperty.value != null) {
        final i = properties.indexWhere((p) => p.id == item.id);
        if (i >= 0) properties[i] = item;
        clearEditing();
      } else {
        properties.add(item);
      }
      Get.back();
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
    super.onClose();
  }
}
