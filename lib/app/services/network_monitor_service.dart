import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class NetworkMonitorService extends GetxService {
  final Connectivity _connectivity = Connectivity();
  final isOnline = true.obs;

  @override
  void onInit() {
    super.onInit();
    _connectivity.onConnectivityChanged.listen((result) {
      // connectivity_plus emits `List<ConnectivityResult>` (v6+)
      isOnline.value = !result.contains(ConnectivityResult.none);
    });
  }
}
