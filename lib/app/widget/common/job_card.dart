import 'package:ccs_app/export.dart';

/// Common job card: vertical status-colored line, title, subtitle, date/time, property, recurrence, status chip.
/// Use the primary constructor only; pass the same layout fields everywhere.
class JobCard extends StatelessWidget {
  const JobCard({
    required this.title,
    required this.dateTime,
    required this.status,
    super.key,
    this.subtitle,
    this.property,
    this.recurrence,
    this.onTap,
  });

  final String title;
  final String dateTime;
  final String status;
  final String? subtitle;
  final String? property;
  final String? recurrence;
  final VoidCallback? onTap;

  /// Returns the status color for the vertical line (and chip): error for cancelled, tertiary for complete, primary otherwise.
  static Color statusLineColor(String status, ColorScheme scheme) {
    final lower = status.toLowerCase();
    if (lower.contains('cancel')) return scheme.error;
    if (lower.contains('complete') || lower.contains('done')) return scheme.tertiary;
    return scheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final lineColor = statusLineColor(status, scheme);

    return AppCard(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 4,
            decoration: BoxDecoration(
              color: lineColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CommonText.semiBold(title, size: 16, color: scheme.onSurface),
                          if (subtitle != null && subtitle!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            CommonText.regular(subtitle!, size: 13, color: scheme.onSurfaceVariant),
                          ],
                          const SizedBox(height: 4),
                          CommonText.regular(dateTime, size: 12, color: scheme.onSurfaceVariant),
                          if (property != null && property!.isNotEmpty && property != title) ...[
                            const SizedBox(height: 4),
                            CommonText.regular(
                              property!,
                              size: 12,
                              color: scheme.onSurfaceVariant,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          if (recurrence != null && recurrence!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            AppCard(
                              radius: UiConstants.radiusSmall,
                              enableShadows: false,
                              color: scheme.tertiaryContainer.withValues(alpha: 0.5),
                              child: CommonText.medium(
                                recurrence!,
                                size: 11,
                                color: scheme.onTertiaryContainer,
                              ).paddingSymmetric(horizontal: 8, vertical: 4),
                            ),
                          ],
                        ],
                      ),
                    ),
                    _JobCardStatusChip(label: status, scheme: scheme),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          Icon(IconsaxPlusLinear.arrow_right_2, size: 18, color: scheme.onSurfaceVariant),
        ],
      ).paddingAll(14),
    );
  }
}

class _JobCardStatusChip extends StatelessWidget {
  const _JobCardStatusChip({required this.label, required this.scheme});

  final String label;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final lower = label.toLowerCase();
    Color bg;
    Color fg;
    if (lower.contains('cancel')) {
      bg = scheme.errorContainer.withValues(alpha: 0.6);
      fg = scheme.error;
    } else if (lower.contains('complete') || lower.contains('done')) {
      bg = scheme.tertiaryContainer.withValues(alpha: 0.6);
      fg = scheme.onTertiaryContainer;
    } else {
      bg = scheme.primaryContainer.withValues(alpha: 0.5);
      fg = scheme.primary;
    }

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(UiConstants.radiusSmall),
      ),
      child: CommonText.semiBold(label, size: 12, color: fg).paddingSymmetric(horizontal: 12, vertical: 6),
    );
  }
}
