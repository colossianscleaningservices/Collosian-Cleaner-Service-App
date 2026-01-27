import 'package:ccs_app/app/modules/client/property/property_controller.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

class DetailPropertyView extends GetView<PropertyController> {
  const DetailPropertyView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DetailPropertyView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'DetailPropertyView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
