import 'package:ccs_app/export.dart';

/// Empty state for calendar "Upcoming". Used in both client and cleaner calendar views.
/// Provide [title] and [subtitle] to customise the message for the current context
/// (e.g. "No jobs on this day." vs "No jobs this month.").
class CalendarEmptyCard extends StatelessWidget {
  const CalendarEmptyCard({
    super.key,
    required this.scheme,
    required this.onMyJobsPressed,
    this.title,
    this.subtitle,
  });

  final ColorScheme scheme;
  final VoidCallback onMyJobsPressed;

  /// Primary line. Defaults to "No jobs on this day."
  final String? title;

  /// Secondary line. Defaults to "Your assigned jobs will appear here."
  final String? subtitle;

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
                CommonText.regular(
                  title ?? 'No jobs on this day.',
                  size: 13,
                  color: scheme.onSurfaceVariant,
                ),
                const SizedBox(height: 2),
                CommonText.regular(
                  subtitle ?? 'Your assigned jobs will appear here.',
                  size: 12,
                  color: scheme.onSurfaceVariant,
                ),
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
