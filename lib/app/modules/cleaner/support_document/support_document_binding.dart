import 'package:get/get.dart';

import 'support_document_controller.dart';

class SupportDocumentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SupportDocumentController>(
      () => SupportDocumentController(),
    );
  }
}
