import 'package:ccs_app/app/widget/common/header.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'training_and_resources_controller.dart';

class TrainingAndResourcesView extends GetView<TrainingAndResourcesController> {
  const TrainingAndResourcesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(title: "Training & Resources"),
      body: Container(),
    );
  }
}
