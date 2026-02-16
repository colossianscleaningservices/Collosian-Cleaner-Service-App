import 'package:ccs_app/app/modules/client/dashboard/client_dashboard_controller.dart';
import 'package:ccs_app/app/widget/quick_action.dart';
import 'package:ccs_app/export.dart';

/// Dashboard content (the actual dashboard UI, not the shell).
class ClientDashboardContent extends GetView<ClientDashboardController> {
  const ClientDashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return SafeArea(
      child: SingleChildScrollView(
        padding: UiConstants.padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
            AppCard(
              color: scheme.primary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 16,
                children: [
                  Row(
                    children: [
                      CommonText.semiBold(
                        "Today",
                        size: 16,
                        color: scheme.onPrimary,
                      ),
                      Spacer(),
                      AppCard(
                        color: scheme.primaryContainer.withValues(alpha: 0.2),
                        onTap: () => controller.setTab(2),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CommonText.medium('View all', size: 13, color: scheme.onPrimary),
                            const SizedBox(width: 4),
                            Icon(IconsaxPlusLinear.arrow_right_2, size: 14, color: scheme.onPrimary),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      AppCard(
                        color: scheme.primaryContainer.withValues(alpha: 0.2),
                        padding: const EdgeInsets.all(12),
                        child: Icon(IconsaxPlusLinear.calendar, size: 24, color: scheme.onPrimary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CommonText.semiBold(
                              'No jobs found for today.',
                              size: 14,
                              color: scheme.onPrimary,
                            ),
                            const SizedBox(height: 2),
                            CommonText.regular(
                              'Your next booking will appear here.',
                              size: 12,
                              color: scheme.onPrimary.withValues(alpha: 0.6),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ).paddingAll(18),
            ),
            _CardSection(
              title: 'Upcoming Pre-Bookings',
              trailing: CommonText.medium(
                'View all',
                size: 13,
                color: scheme.secondary,
                onTap: () {
                  Notifier.info('Upcoming bookings (coming soon)');
                },
              ),
              child: CommonText.regular(
                'No upcoming bookings available.',
                size: 13,
                color: scheme.onSurfaceVariant,
              ),
            ),
            /*CommonText.semiBold('Quick Actions', size: 16, color: scheme.onSurface),
            Row(
              children: [
                Expanded(
                  child: QuickActionChip(
                    icon: IconsaxPlusLinear.additem,
                    label: 'Create Job',
                    subtitle: 'Add a new Job',
                    onTap: () => controller.setTab(3),
                    scheme: scheme,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: QuickActionChip(
                    icon: IconsaxPlusLinear.home_hashtag,
                    label: 'Property',
                    subtitle: 'Add a new property',
                    onTap: () => controller.setTab(4),
                    scheme: scheme,
                  ),
                ),
              ],
            ),*/
          ],
        ),
      ),
    );
  }
}

class _CardSection extends StatelessWidget {
  const _CardSection({
    required this.title,
    required this.child,
    this.trailing,
  });

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: CommonText.semiBold(
                    title,
                    size: 14,
                    color: scheme.onSurface,
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}
