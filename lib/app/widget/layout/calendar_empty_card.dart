import 'package:ccs_app/export.dart';

/// Empty state for calendar "Upcoming": no jobs this month + My Jobs button.
/// Used in both client and cleaner calendar views.
class CalendarEmptyCard extends StatelessWidget {
  const CalendarEmptyCard({
    super.key,
    required this.scheme,
    required this.onMyJobsPressed,
  });

  final ColorScheme scheme;
  final VoidCallback onMyJobsPressed;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Icon(IconsaxPlusLinear.calendar, color: scheme.onSurfaceVariant, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText.regular('No jobs this month.', size: 13, color: scheme.onSurfaceVariant),
                const SizedBox(height: 2),
                CommonText.regular('Your assigned jobs will appear here.', size: 12, color: scheme.onSurfaceVariant),
              ],
            ),
          ),
          AppButton(
            label: 'My Jobs',
            type: ButtonType.outline,
            onPressed: onMyJobsPressed,
            btnVerticalPadding: 8,
            btnHorizontalPadding: 12,
            textSize: 12,
          ),
        ],
      ).paddingAll(14),
    );
  }
}
