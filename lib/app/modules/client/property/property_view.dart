import 'package:ccs_app/export.dart';
import 'property_controller.dart';

class PropertyView extends GetView<PropertyController> {
  const PropertyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(title: "My Properties"),
      body: SingleChildScrollView(
        child: Column(
          children: [
            AppGrid(
              maxExtent: 160,
              controller: ScrollController(keepScrollOffset: false),
              //physics: const NeverScrollableScrollPhysics(),
              phoneCount: 1,
              tabletCount: 2,
              landscapeCount: 3,
              axisSpacing: 0,
              child: [],
            ).marginOnly(bottom: 16),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(Routes.ADD_PROPERTY),
        icon: const Icon(Icons.add),
        label: const Text('Create Property'),
      ),
    );
  }
}
