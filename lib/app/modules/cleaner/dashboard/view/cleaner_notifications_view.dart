import 'package:ccs_app/export.dart';

import '../cleaner_dashboard_controller.dart';

class CleanerNotificationsView extends GetView<CleanerDashboardController> {
  const CleanerNotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: UiConstants.padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommonText.semiBold('Notifications', size: 22),
            const SizedBox(height: 12),
            Expanded(
              child: Center(
                child: CommonText.regular(
                  'Cleaner notifications (coming soon)',
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
