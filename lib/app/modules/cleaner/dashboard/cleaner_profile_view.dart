import 'package:ccs_app/export.dart';
import '../../../services/session_service.dart';
import 'cleaner_dashboard_controller.dart';

class CleanerProfileView extends GetView<CleanerDashboardController> {
  const CleanerProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return SafeArea(
      child: Padding(
        padding: UiConstants.padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommonText.semiBold('Profile', size: 22, color: scheme.onSurface),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText.semiBold('Account', size: 14),
                    const SizedBox(height: 8),
                    CommonText.regular(
                      'Profile management (coming soon)',
                      color: scheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      label: 'Logout',
                      type: ButtonType.outline,
                      icon: IconsaxPlusLinear.logout,
                      onPressed: () => Get.find<SessionService>().logout(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

