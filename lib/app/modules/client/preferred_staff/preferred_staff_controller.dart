import 'package:ccs_app/app/network/repository/client_repository.dart';
import 'package:ccs_app/app/network/response/get_preferred_staff_response.dart';
import 'package:get/get.dart';

import '../../../network/utils/network_result_extensions.dart';
import '../../../utils/custom_loader.dart';
import '../../../utils/notifier.dart';

class PreferredStaffController extends GetxController {

  final ClientRepository _clientRepository = ClientRepository();

  RxList<PreferredStaff> preferredStaff = <PreferredStaff>[].obs;

  final count = 0.obs;
  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    loadPreferredStaff();
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<void> loadPreferredStaff() async {
    Loader.show();
    try {
      final result = await _clientRepository.getPreferredStaff();
      result.handle(
        success: (value) {
          preferredStaff.clear();
          preferredStaff.addAll(value.data?.preferredStaff ?? []);
        },
        contextTag: 'get_preferredStaff',
      );
    } catch (e) {
      Notifier.error('Failed to load newsletters');
    } finally {
      Loader.hide();
    }
  }

  Future<void> refreshNewsletters() async {
    await loadPreferredStaff();
  }

  // void goToPreferredStaffDetail(int index) {
  //   if (index < 0 || index >= preferredStaff.length) return;
  //   final staff = preferredStaff[index];
  //   editingProperty.value = property;
  //   Get.toNamed(Routes.ADD_PROPERTY);
  //   // Load edit data on the detail page after navigation (loader shown there)
  //   WidgetsBinding.instance.addPostFrameCallback((_) => _loadEditPropertyData());
  // }

}
