import 'package:ccs_app/app/network/repository/client_repository.dart';
import 'package:ccs_app/app/network/response/property_list_response.dart';
import 'package:ccs_app/app/network/response/property_sub_type_response.dart';
import 'package:ccs_app/app/network/response/property_type_response.dart';
import 'package:ccs_app/export.dart';

import '../dashboard/client_dashboard_controller.dart';

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
  final newPropertyTypeCtrl = TextEditingController();

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
  final hasDishwasher = false.obs;
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
  var from = '';

  ScrollController jobScrollController = ScrollController();
  var propertyCurrentPage = 1;
  var propertyTotalPage = 1;
  RxBool isPropertyMoreLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      if (Get.arguments['from'] != null) from = Get.arguments['from'];
      if (Get.arguments['property'] != null) editingProperty.value = Get.arguments['property'];
    }
    _loadProperties();

    jobScrollController.addListener(() {
      if (_isScrollBottom) {
        if (propertyCurrentPage <= propertyTotalPage && !isPropertyMoreLoading.value) {
          isPropertyMoreLoading.value = true;
          _loadProperties();
        }
      }
    });
  }

  bool get _isScrollBottom {
    if (!jobScrollController.hasClients) return false;
    final maxScroll = jobScrollController.position.maxScrollExtent;
    final currentScroll = jobScrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
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
  Future<void> onReady() async {
    await getPropertyType(businessType.value);

    if (from == 'dash') {
      _loadEditPropertyData();
    }

    super.onReady();
  }

  String? validateRequired(String? value, String fieldName) => Validator.requiredField(value, fieldName: fieldName);

  Future<void> _loadProperties() async {
    if (from == 'dash') return;
    try {
      final result = await _clientRepository.listProperties(page: propertyCurrentPage);
      result.handle(
        success: (response) {
          isPropertyMoreLoading.value = false;
          final raw = response.data;
          if (propertyCurrentPage == 1) properties.clear();
          if (raw != null && raw.properties?.isNotEmpty == true) {
            properties.addAll(raw.properties as Iterable<PropertyModel>);
          }

          propertyTotalPage = (response.data?.pagination?.totalPages ?? 1).toInt();

          if (propertyCurrentPage <= propertyTotalPage) {
            propertyCurrentPage++;
          }
        },
      );
    } catch (_) {
      isPropertyMoreLoading.value = false;
    }
  }

  Future<void> getPropertyType(String businessType, {bool showLoader = true}) async {
    if (showLoader) Loader.show();
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
      if (showLoader) Loader.hide();
    }
  }

  Future<void> getPropertySubType(int propertyId, {bool showLoader = true}) async {
    if (showLoader) Loader.show();
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
      if (showLoader) Loader.hide();
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
              animalProperty: animals.value != 'No',
              customPropertyType: selectedPropertyType.value?.name?.toLowerCase() == 'others' ? newPropertyTypeCtrl.text.trim() : null,
              provideDishwasher: hasDishwasher.value);
          result.handle(
            success: (value) async {
              Notifier.success(value.message ?? "Property updated Successfully!");
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                propertyCurrentPage = 1;
                await _loadProperties();
                resetForm();
                Get.back();
                updateDashContent();
              });
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
          customPropertyType: selectedPropertyType.value?.name?.toLowerCase() == 'others' ? newPropertyTypeCtrl.text.trim() : null,
          provideDishwasher: hasDishwasher.value);

      result.handle(
        success: (value) async {
          Notifier.success(value.message ?? "Property created Successfully!");
          propertyCurrentPage = 1;
          await _loadProperties();
          resetForm();
          Get.back();
          updateDashContent();
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

  void goToEditProperty(int index) {
    if (index < 0 || index >= properties.length) return;
    final property = properties[index];
    editingProperty.value = property;
    Get.toNamed(Routes.ADD_PROPERTY);
    // Load edit data on the detail page after navigation (loader shown there)
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadEditPropertyData());
  }

  /// Called on the detail page after navigating to edit: shows loader and fetches property types, sub-types, then fills form.
  Future<void> _loadEditPropertyData() async {
    final property = editingProperty.value;
    if (property == null) return;

    Loader.show();
    try {
      resetForm();
      editingProperty.value = property;
      businessType.value = property.businessType?.capitalizeFirst ?? "Residential";

      await getPropertyType(businessType.value, showLoader: false);

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
      hasDishwasher.value = property.provideDishwasher ?? false;
      staffPreference.value = property.staffPreference ?? 'Male';
      accessToProperty.value = property.accessToProperty ?? 'Client Will Open';
      animals.value = property.animalProperty == '1' ? 'Yes' : 'No';

      final item = propertyTypeOptions.firstWhereOrNull((item) => item.name == propertyType.value);
      final subId = item?.id;

      if (item?.hasSubtypes == true) {
        numberOfBedroomsCtrl.text = "${property.bedrooms}";
        numberOfBathroomsCtrl.text = "${property.bathrooms}";
        numberOfGuestToiletCtrl.text = "${property.separateGuestToilet}";
        livingRoomCtrl.text = "${property.livingRooms}";
        officeCtrl.text = "${property.office}";
        conservatoryCtrl.text = "${property.conservatory}";
        diningRoomCtrl.text = "${property.diningRoom}";

        if (subId != null) {
          await getPropertySubType(subId.toInt(), showLoader: false);
          if (propertyTypeOptions.isNotEmpty) {
            selectedPropertySubType.value = propertySubTypeOptions.firstWhereOrNull((item) => item.name?.toLowerCase() == property.subType?.toLowerCase());
          }
        }
      }
    } catch (e) {
      await Notifier.apiError(e, contextTag: 'load_edit_property');
    } finally {
      Loader.hide();
    }
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
    if (from == 'dash') return;
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
    newPropertyTypeCtrl.clear();
    hasDishwasher.value = false;
  }

  void clearHouseFields() {
    selectedPropertySubType.value = null;
    numberOfBedroomsCtrl.clear();
    numberOfBathroomsCtrl.clear();
    numberOfGuestToiletCtrl.clear();
    livingRoomCtrl.clear();
    officeCtrl.clear();
    conservatoryCtrl.clear();
    diningRoomCtrl.clear();
  }

  void updateDashContent() {
    bool isControllerRegistered = Get.isRegistered<ClientDashboardController>();
    if (isControllerRegistered) {
      ClientDashboardController ctrl = Get.find();
      ctrl.getClientDash(isLoaderShown: false);
    }
  }
}
