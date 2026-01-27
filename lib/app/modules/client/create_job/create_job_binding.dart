import 'package:ccs_app/export.dart';

import 'create_job_controller.dart';

class CreateJobBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreateJobController>(() => CreateJobController());
  }
}
