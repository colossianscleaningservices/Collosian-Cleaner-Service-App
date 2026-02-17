import 'package:ccs_app/app/network/repository/client_repository.dart';
import 'package:ccs_app/app/network/response/property_list_response.dart';
import 'package:ccs_app/app/network/response/property_sub_type_response.dart';
import 'package:ccs_app/app/network/response/property_type_response.dart';
import 'package:ccs_app/export.dart';

class PropertyController extends GetxController {
  final ClientRepository _clientRepository = ClientRepository();
  final formKey = GlobalKey<FormState>();

  /// List of properties (from API; fallback to empty until response model is defined).
  final properties = <PropertyModel>[].obs;

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
  final selectedPropertyType = Rxn<PropertyTypes>();
  final selectedPropertySubType = Rxn<PropertySubtypes>();
  final subType = Rxn<String>();
  final hoover = 'No'.obs;
  final staffPreference = 'Male'.obs;
  final accessToProperty = 'Client Will Open'.obs;
  final animals = 'No'.obs;

  final provideCleaningProducts = false.obs;
  final hasWashingMachine = false.obs;
  final hasDryer = false.obs;

  static const List<String> businessTypeOptions = ['Residential', 'Commercial'];
  final RxList<PropertyTypes> propertyTypeOptions = <PropertyTypes>[].obs;
  final RxList<PropertySubtypes> propertySubTypeOptions = <PropertySubtypes>[].obs;

  static const List<String> hooverOptions = ['No', 'Yes', 'I will get one'];
  static const List<String> staffPreferenceOptions = ['Male', 'Female', 'No Preference'];
  static const List<String> accessOptions = ['Client Will Open', 'Reception/Concierge', 'Key', 'Other'];
  static const List<String> animalsOptions = ['No', 'Yes'];

  /// When set, we're on Add Property screen in edit mode.
  final editingProperty = Rxn<PropertyModel>();

  @override
  void onInit() {
    super.onInit();
    _loadProperties();
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

  @override
  void onReady() {
    getPropertyType(businessType.value);
    super.onReady();
  }

  String? validateRequired(String? value, String fieldName) {
    return Validator.requiredField(value, fieldName: fieldName);
  }

  Future<void> _loadProperties() async {
    Loader.show();
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
      Loader.hide();
    }
  }

  Future<void> getPropertyType(String businessType) async {
    Loader.show();
    try {
      final result = await _clientRepository.getPropertyType(businessType: businessType.toUpperCase());
      result.handle(
        success: (value) {
          final data = value.data?.propertyTypes;
          propertyTypeOptions.clear();
          if (data != null) propertyTypeOptions.addAll(data);
          propertyTypeOptions.refresh();
        },
        contextTag: 'get-property-type',
      );
    } catch (e) {
      await Notifier.apiError(e, contextTag: 'get-property-type');
    } finally {
      Loader.hide();
    }
  }

  Future<void> getPropertySubType(int propertyId) async {
    Loader.show();
    try {
      final result = await _clientRepository.getPropertySubTypes(propertyId: propertyId);
      result.handle(
        success: (value) {
          final data = value.data?.propertySubtypes;
          if (data != null) propertySubTypeOptions.addAll(data);
          propertySubTypeOptions.refresh();
        },
        contextTag: 'get-property-type',
      );
    } catch (e) {
      await Notifier.apiError(e, contextTag: 'get-property-type');
    } finally {
      Loader.hide();
    }
  }

  Future<void> addUpdateProperty() async {
    if (formKey.currentState?.validate() != true) return;

    Loader.show();
    try {
      final name = propertyNameCtrl.text.trim();
      final address = addressCtrl.text.trim();
      final city = cityCtrl.text.trim();
      final code = postalCodeCtrl.text.trim();
      final editing = editingProperty.value;
      if (editing != null) {
        final id = editing.id?.toInt();
        if (id != null) {
          final result = await _clientRepository.updateProperty(
            id: id,
            name: name.isNotEmpty ? name : '',
            businessType: businessType.value.toUpperCase(),
            address: address,
            city: city,
            postalCode: code,
            propertyType: selectedPropertyType.value?.name ?? "",
            propertySubType: selectedPropertySubType.value?.name ?? '',
            noOfBedrooms: numberOfBedroomsCtrl.text.toInt(),
            noOfBathrooms: numberOfBathroomsCtrl.text.toInt(),
            noOfGuestToilet: numberOfGuestToiletCtrl.text.toInt(),
            livingRoom: livingRoomCtrl.text.toInt(),
            office: officeCtrl.text.toInt(),
            conservatory: conservatoryCtrl.text.toInt(),
            diningRoom: diningRoomCtrl.text.toInt(),
            haveHoover: hoover.value,
            provideCleaningProduct: provideCleaningProducts.value,
            haveWashingMachine: hasWashingMachine.value,
            staffPreference: staffPreference.value != 'Male' ? staffPreference.value : null,
            haveDryer: hasDryer.value,
            accessProperty: accessToProperty.value,
            animalProperty: animals.value,
          );
          result.handle(
            success: (value) async {
              Notifier.success(value.message ?? "Property updated Successfully!");
              await _loadProperties();
              resetForm();
              Get.back();
            },
            contextTag: 'update_property',
          );
          return;
        }
      }

      final result = await _clientRepository.createProperty(
        name: name.isNotEmpty ? name : '',
        businessType: businessType.value.toUpperCase(),
        address: address,
        city: city,
        postalCode: code,
        propertyType: selectedPropertyType.value?.name ?? "",
        propertySubType: selectedPropertySubType.value?.name ?? '',
        noOfBedrooms: numberOfBedroomsCtrl.text.toInt(),
        noOfBathrooms: numberOfBathroomsCtrl.text.toInt(),
        noOfGuestToilet: numberOfGuestToiletCtrl.text.toInt(),
        livingRoom: livingRoomCtrl.text.toInt(),
        office: officeCtrl.text.toInt(),
        conservatory: conservatoryCtrl.text.toInt(),
        diningRoom: diningRoomCtrl.text.toInt(),
        haveHoover: hoover.value,
        provideCleaningProduct: provideCleaningProducts.value,
        haveWashingMachine: hasWashingMachine.value,
        staffPreference: staffPreference.value != 'Male' ? staffPreference.value : null,
        haveDryer: hasDryer.value,
        accessProperty: accessToProperty.value,
        animalProperty: animals.value != 'No',
      );

      result.handle(
        success: (value) async {
          Notifier.success(value.message ?? "Property created Successfully!");
          await _loadProperties();
          resetForm();
          Get.back();
        },
        contextTag: 'create-property',
      );
    } finally {
      Loader.hide();
    }
  }

  void goToAddProperty() {
    resetForm();
    Get.toNamed(Routes.ADD_PROPERTY);
  }

  Future<void> goToEditProperty(PropertyModel property) async {
    resetForm();
    editingProperty.value = property;
    businessType.value = property.businessType?.capitalizeFirst ?? "Residential";

    await getPropertyType(businessType.value);

    propertyNameCtrl.text = property.propertyName ?? "";
    addressCtrl.text = property.address ?? "";
    cityCtrl.text = property.city ?? '';
    postalCodeCtrl.text = property.postalCode ?? '';
    propertyType.value = property.propertyType;
    selectedPropertyType.value = propertyTypeOptions.firstWhereOrNull((e) => e.name == property.propertyType);
    hasDryer.value = property.provideDryer ?? false;
    hoover.value = property.hoover ?? "No";
    provideCleaningProducts.value = property.provideCleaningProducts ?? false;
    hasWashingMachine.value = property.provideWashingMachine ?? false;
    staffPreference.value = property.staffPreference ?? 'Male';
    accessToProperty.value = property.accessToProperty ?? 'Client Will Open';
    animals.value = property.animalProperty == '1' ? 'Yes' : 'No';

    var item = propertyTypeOptions.firstWhereOrNull((item) => item.name == propertyType.value);
    var subId = item?.id;

    if (item?.hasSubtypes == true) {
      numberOfBedroomsCtrl.text = "${property.bedrooms}";
      numberOfBathroomsCtrl.text = "${property.bathrooms}";
      numberOfGuestToiletCtrl.text = "${property.separateGuestToilet}";
      livingRoomCtrl.text = "${property.livingRooms}";
      officeCtrl.text = "${property.office}";
      conservatoryCtrl.text = "${property.conservatory}";
      diningRoomCtrl.text = "${property.diningRoom}";

      if (subId != null) {
        await getPropertySubType(subId.toInt());
        if (propertyTypeOptions.isNotEmpty) {
          selectedPropertySubType.value = propertySubTypeOptions.firstWhereOrNull((item) => item.name?.toLowerCase() == property.subType?.toLowerCase());
        }
      }
    }

    await Future<void>.delayed(const Duration(milliseconds: 200));

    Get.toNamed(Routes.ADD_PROPERTY);
  }

  void confirmDeleteProperty(BuildContext context) {
    final property = editingProperty.value;
    if (property == null) return;
    Notifier.openSheet(
      context,
      type: SheetType.error,
      title: 'Delete property?',
      icon: IconsaxPlusLinear.trash,
      message: 'This will remove "${property.propertyName}" from your properties. This action cannot be undone.',
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
    final jobId = id.toInt();
    Get.back();
    Loader.show();
    try {
      final result = await _clientRepository.deleteProperty(jobId);
      result.handle(
        success: (value) async {
          properties.removeWhere((p) => p.id == id);
          resetForm();
          Get.back();
          Notifier.success(value.message ?? "Property deleted Successfully!");
        },
        contextTag: 'delete_property',
      );
    } finally {
      Loader.hide();
    }
  }

  void resetForm() {
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
    selectedPropertyType.value = null;
  }

  void clearHouseFields() {
    selectedPropertySubType.value = null;
    numberOfBedroomsCtrl.text = '0';
    numberOfBathroomsCtrl.text = '0';
    numberOfGuestToiletCtrl.text = '0';
    livingRoomCtrl.text = '0';
    officeCtrl.text = '0';
    conservatoryCtrl.text = '0';
    diningRoomCtrl.text = '0';
  }
}
