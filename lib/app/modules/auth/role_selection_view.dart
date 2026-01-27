import 'package:ccs_app/export.dart';

import 'auth_controller.dart';

class RoleSelectionView extends GetView<AuthController> {
  const RoleSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select role')),
      body: Padding(
        padding: UiConstants.padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CommonText.bold('Continue as', size: 18),
            const SizedBox(height: 16),
            AppButton(
              label: 'I am a Client',
              onPressed: () {
                controller.selectRole(AppRole.client);
                controller.goToSignup();
              },
            ),
            const SizedBox(height: 12),
            AppButton(
              label: 'I am a Cleaner',
              type: ButtonType.tonal,
              onPressed: () {
                controller.selectRole(AppRole.cleaner);
                controller.goToSignup();
              },
            ),
          ],
        ),
      ),
    );
  }
}

