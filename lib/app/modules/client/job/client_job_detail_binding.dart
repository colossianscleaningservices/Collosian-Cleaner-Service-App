import 'package:ccs_app/export.dart';
import 'client_job_detail_controller.dart';

class ClientJobDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ClientJobDetailController>(() => ClientJobDetailController());
  }
}
