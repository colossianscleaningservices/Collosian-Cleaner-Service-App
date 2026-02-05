import 'package:ccs_app/app/widget/layout/app_scaffold.dart';
import 'package:ccs_app/export.dart';

import '../../gen/assets.gen.dart';
import 'auth_controller.dart';

class RoleSelectionView extends GetView<AuthController> {
  const RoleSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;

    return AppScaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: UiConstants.defaultPadding),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 32, bottom: 24),
                      child: Assets.imagesAppLogo.image(
                        height: 120,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 32),
                      child: AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            CommonText.bold('Continue as', size: 28),
                            const SizedBox(height: 8),
                            CommonText.regular(
                              'Choose how you want to use CCS',
                              color: scheme.onSurfaceVariant,
                              size: 18,
                            ),
                            const SizedBox(height: 32),
                            AppButton(
                              label: 'I am a Client',
                              onPressed: () {
                                controller.selectRole(AppRole.client);
                                controller.goToSignup();
                              },
                            ),
                            const SizedBox(height: UiConstants.gap),
                            AppButton(
                              label: 'I am a Cleaner',
                              type: ButtonType.tonal,
                              onPressed: () {
                                controller.selectRole(AppRole.cleaner);
                                controller.goToSignup();
                              },
                            ),
                            const SizedBox(height: 32),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CommonText.regular('Already have an account? ', color: scheme.onSurfaceVariant),
                                CommonText.regular('Sign in', color: scheme.primary, onTap: controller.goToLogin),
                              ],
                            ),
                          ],
                        ).paddingSymmetric(horizontal: 24, vertical: 18),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
