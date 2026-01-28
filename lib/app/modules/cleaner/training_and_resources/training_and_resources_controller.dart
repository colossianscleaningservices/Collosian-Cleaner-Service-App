import 'package:ccs_app/app/model/common_model.dart';

import '../../../../export.dart';

class TrainingAndResourcesController extends GetxController {
  //TODO: Implement TrainingAndResourcesController

  final count = 0.obs;

  var groupSearchFocus = FocusNode();
  var groupSearchController = TextEditingController();
  var searchTerm = ''.obs;
  RxList<CommonModel> filter = <CommonModel>[].obs;
  RxList<CommonModel> training = <CommonModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    initList();
  }

  void initList() {
    filter.clear();
    filter.add(CommonModel(type: "All", isSelected: true));
    filter.add(CommonModel(type: "Video"));
    filter.add(CommonModel(type: "Flyer"));

    training.clear();
    training.add(CommonModel());
    training.add(CommonModel());
    training.add(CommonModel());
    training.add(CommonModel());
    training.add(CommonModel());
    training.add(CommonModel());
    training.add(CommonModel());
    training.add(CommonModel());

  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void increment() => count.value++;
}
