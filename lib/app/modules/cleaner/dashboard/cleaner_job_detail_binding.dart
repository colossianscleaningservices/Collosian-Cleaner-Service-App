import 'package:ccs_app/export.dart';
import 'cleaner_job_detail_controller.dart';

class CleanerJobDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CleanerJobDetailController>(() => CleanerJobDetailController());
  }
}
