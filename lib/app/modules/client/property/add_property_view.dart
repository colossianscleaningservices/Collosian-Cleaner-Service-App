import 'package:ccs_app/app/modules/client/property/property_controller.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

class AddPropertyView extends GetView<PropertyController> {
  const AddPropertyView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AddPropertyView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'AddPropertyView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
