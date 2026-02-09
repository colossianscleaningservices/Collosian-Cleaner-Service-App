import 'package:ccs_app/app/services/auth_service.dart';
import 'package:ccs_app/app/services/pref.dart';
import 'package:ccs_app/export.dart';

class SplashController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  @override
  void onReady() {
    super.onReady();
    _route();
  }

  Future<void> _route() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));

    if (!_authService.hasToken) {
      Get.offAllNamed(Routes.LOGIN);
      return;
    }

    final roleIdStr = Prefs().getData(Prefs.roleId);
    final roleId = int.tryParse(roleIdStr);
    if (RoleConstants.isClient(roleId)) {
      Get.offAllNamed(Routes.CLIENT_DASHBOARD);
    } else {
      Get.offAllNamed(Routes.CLEANER_DASHBOARD);
    }
  }
}

