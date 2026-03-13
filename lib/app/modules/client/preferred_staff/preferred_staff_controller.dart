import 'package:ccs_app/app/network/repository/client_repository.dart';
import 'package:ccs_app/app/network/response/get_preferred_staff_response.dart';
import 'package:ccs_app/app/network/response/get_staff_detail_response.dart';

import '../../../../export.dart';

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

    var type = '';
    if (args != null && args['type'] != null) {
      type = args['type'];
    }

    if (type == 'staffDetail') {
      final staffId = args['id'];
      loadStaffDetail(staffId);
    } else {
      loadPreferredStaff();
    }

    super.onReady();
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
    Get.toNamed(Routes.STAFF_DETAILS);
    loadStaffDetail(staffId);
  }

  Future<void> markStaffPreferred(int? staffId) async {
    if (staffId == null) return;
    Loader.show();
    try {
      final result = await _clientRepository.markStaffPreferred(staffId: staffId);
      result.handle(
        success: (value) {
          Loader.hide();
          // Defer sheet to next frame so Loader.hide() from finally can close the loader first
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (Get.context == null) return;
            Notifier.openSheet(Get.context as BuildContext,
                title: "Success",
                type: SheetType.success,
                message: value.message ?? "Staff Mark as Preferred",
                isDismissable: false,
                isShowCloseIcon: false,
                showSecondaryButton: false, onPrimaryPressed: () {
              Get.back(result: {'isUpdate': true});
            });
          });
        },
        contextTag: 'mark_staff_preferred',
      );
    } catch (e) {
      Notifier.error('Failed to Mark Staff Preferred');
    } finally {
      Loader.hide();
    }
  }

  Future<void> unmarkStaffPreferred(int? staffId) async {
    if (staffId == null) return;
    Loader.show();
    try {
      final result = await _clientRepository.unmarkStaffPreferred(staffId: staffId);
      result.handle(
        success: (value) {
          Loader.hide();
          // Defer sheet to next frame so Loader.hide() from finally can close the loader first
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (Get.context == null) return;
            Notifier.openSheet(Get.context as BuildContext,
                title: "Success",
                type: SheetType.success,
                message: value.message ?? "Staff Unmarked as Preferred",
                isDismissable: false,
                isShowCloseIcon: false,
                showSecondaryButton: false, onPrimaryPressed: () {
              Get.back(result: {'isUpdate': true});
              loadPreferredStaff();
            });
          });
        },
        contextTag: 'unmark_staff_preferred',
      );
    } catch (e) {
      Notifier.error('Failed to Unmark Staff Preferred');
    } finally {
      Loader.hide();
    }
  }
}
