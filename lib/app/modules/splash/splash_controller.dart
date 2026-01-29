import 'package:ccs_app/export.dart';

import '../../services/auth_service.dart';

class SplashController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  @override
  void onReady() {
    super.onReady();
    _route();
    // Get.offAllNamed(Routes.LOGIN);
  }

  Future<void> _route() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));

    if (!_authService.hasToken) {
      Get.offAllNamed(Routes.LOGIN);
      return;
    }

    Get.offAllNamed(Routes.LOGIN);
  }
}
