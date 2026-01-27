import 'package:ccs_app/export.dart';

import 'client_edit_profile_controller.dart';

class ClientEditProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ClientEditProfileController>(() => ClientEditProfileController());
  }
}
