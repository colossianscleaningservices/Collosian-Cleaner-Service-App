import 'package:ccs_app/app/network/repository/client_repository.dart';
import 'package:ccs_app/app/network/response/get_preferred_staff_response.dart';
import 'package:ccs_app/app/network/response/get_staff_detail_response.dart';
import 'package:get/get.dart';

import '../../../network/utils/network_result_extensions.dart';
import '../../../routes/app_pages.dart';
import '../../../utils/custom_loader.dart';
import '../../../utils/notifier.dart';

class PreferredStaffController extends GetxController {

  final ClientRepository _clientRepository = ClientRepository();

  RxList<PreferredStaff> preferredStaff = <PreferredStaff>[].obs;

  final staffDetail = Rxn<Staff>();


  final count = 0.obs;
  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {

    final args = Get.arguments;

    final type = args['type'];

    if(type == 'staffDetail'){
      final staffId = args['id'];
      loadStaffDetail(staffId);
    }else{
      loadPreferredStaff();
    }

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

  Future<void> loadStaffDetail(int staffId) async {
    Loader.show();
    try {
      final result = await _clientRepository.getStaffDetail(staffId: staffId);
      result.handle(
        success: (value) {
          staffDetail.value = value.data?.staff;
        },
        contextTag: 'get_preferredStaffDetail',
      );
    } catch (e) {
      Notifier.error('Failed to load staffDetail');
    } finally {
      Loader.hide();
    }
  }


  Future<void> refreshNewsletters() async {
    await loadPreferredStaff();
  }

  void goToPreferredStaffDetail(int staffId) {

    loadStaffDetail(staffId);

    Get.toNamed(Routes.ADD_PROPERTY);
  }

}
