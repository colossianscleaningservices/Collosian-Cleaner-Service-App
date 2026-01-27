import 'package:ccs_app/export.dart';
import 'package:ccs_app/app/routes/app_pages.dart';

/// Dashboard content (the actual dashboard UI, not the shell).
class ClientDashboardContent extends StatelessWidget {
  const ClientDashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return SafeArea(
      child: SingleChildScrollView(
        padding: UiConstants.padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CardSection(
              title: 'Today',
              child: Row(
                children: [
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: scheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(UiConstants.radiusDefault),
                    ),
                    child: Icon(IconsaxPlusLinear.calendar, color: scheme.secondary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonText.semiBold(
                          'No jobs found for today.',
                          size: 14,
                          color: scheme.onSurface,
                        ),
                        const SizedBox(height: 2),
                        CommonText.regular(
                          'Your next booking will appear here.',
                          size: 12,
                          color: scheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

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
            const SizedBox(height: 16),

            CommonText.semiBold('Quick Actions', size: 16, color: scheme.onSurface),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Create job',
                    icon: IconsaxPlusLinear.add,
                    onPressed: () => Get.toNamed(Routes.CLIENT_CREATE_JOB),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AppButton(
                    label: 'Add Property',
                    type: ButtonType.tonal,
                    icon: IconsaxPlusLinear.home_hashtag,
                    onPressed: () {
                      Notifier.info('Add Property (coming soon)');
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            _CardSection(
              title: 'Notifications',
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: CommonText.semiBold('0', size: 12, color: scheme.primary),
              ),
              child: CommonText.regular(
                'No new notifications.',
                size: 13,
                color: scheme.onSurfaceVariant,
              ),
            ),
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

