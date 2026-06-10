import 'package:ccs_app/export.dart';

/// Common job card with clear hierarchy: job name → property → address → meta (timing, schedule, cleaners) → status.
/// Vertical status-colored line on the left; status chip top-right.
class JobCard extends StatelessWidget {
  const JobCard({
    required this.title,
    required this.dateTime,
    required this.status,
    super.key,
    this.subtitle,
    this.propertyName,
    this.address,
    this.property,
    this.recurrence,
    this.cleanerInfo,
    this.onTap,
    this.isFromDash = false,
    this.padding = 14,
  });

  final bool isFromDash;

  /// Job type / name (e.g. "Deep clean").
  final String title;

  /// Formatted date and time string.
  final String dateTime;

  /// Status label (e.g. "Scheduled", "Completed").
  final String status;

  /// Client name or other subtitle; shown in meta section.
  final String? subtitle;

  /// Property name (e.g. "12 Maple St", "Office A").
  final String? propertyName;

  /// Full address line. If null, [property] is used as fallback.
  final String? address;

  /// Legacy: used as address when [address] is null.
  final String? property;

  /// Schedule (e.g. "Weekly", "One-off").
  final String? recurrence;

  /// Cleaner assignment (e.g. "2 cleaners", "1 of 2 assigned").
  final String? cleanerInfo;

  final VoidCallback? onTap;

  final double padding;

  /// Returns the status color for the vertical line and chip.
  static Color statusLineColor(String status, ColorScheme scheme) {
    final lower = status.toLowerCase();
    if (lower.contains('cancel')) return scheme.error;
    if (lower.contains('complete') || lower.contains('done') || lower.contains('finished')) return scheme.tertiary;
    if (lower.contains('pending')) return scheme.secondary;
    return scheme.primary;
  }

  String? get _effectiveAddress => address ?? (property != null && property!.isNotEmpty ? property : null);

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final lineColor = statusLineColor(status, scheme);

    return AppCard(
      onTap: onTap,
      enableShadows: isFromDash ? false : true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Status line
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
                          CommonText.semiBold(
                            title.isEmpty ? 'N/A' :title,
                            size: 16,
                            color: scheme.onSurface,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          // Tier 2: Property name
                          if (propertyName != null && propertyName!.isNotEmpty)
                            CommonText.regular(
                              propertyName!,
                              size: 14,
                              fontWeight: FontWeight.w500,
                              color: scheme.onSurface,
                            ).marginOnly(bottom: 2),
                        ],
                      ),
                    ),
                    _JobCardStatusChip(label: status, scheme: scheme),
                  ],
                ),

                // Tier 3: Address
                if (_effectiveAddress != null && _effectiveAddress!.isNotEmpty && _effectiveAddress != propertyName)
                  CommonText.regular(
                    _effectiveAddress!,
                    size: 12,
                    color: scheme.onSurfaceVariant,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ).marginOnly(bottom: 2),
                const SizedBox(height: 8),
                // Tier 4: Meta row – timing, recurrence, cleaners
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _MetaChip(
                      icon: IconsaxPlusLinear.calendar_1,
                      label: dateTime,
                      scheme: scheme,
                      padding: 0,
                    ),
                    if (recurrence != null && recurrence!.isNotEmpty)
                      _MetaChip(
                        label: recurrence!,
                        scheme: scheme,
                        useTertiary: true,
                      ),
                    if (cleanerInfo != null && cleanerInfo!.isNotEmpty)
                      _MetaChip(
                        icon: IconsaxPlusLinear.profile_2user,
                        label: cleanerInfo!,
                        scheme: scheme,
                      ),
                  ],
                ),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  CommonText.regular(subtitle!, size: 12, color: scheme.onSurfaceVariant),
                ],
              ],
            ),
          ),
          const SizedBox(width: 4),
          Icon(IconsaxPlusLinear.arrow_right_2, size: 18, color: scheme.onSurfaceVariant),
        ],
      ).paddingAll(padding),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.label,
    required this.scheme,
    this.icon,
    this.useTertiary = false,
    this.padding = 8,
  });

  final String label;
  final ColorScheme scheme;
  final IconData? icon;
  final bool useTertiary;
  final double padding;

  @override
  Widget build(BuildContext context) {
    final bg = useTertiary ? scheme.tertiaryContainer.withValues(alpha: 0.5) : scheme.surfaceContainerHighest.withValues(alpha: 0.6);
    final fg = useTertiary ? scheme.onTertiaryContainer : scheme.onSurfaceVariant;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(UiConstants.radiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: 4),
          ],
          (padding == 0)
              ? Expanded(
                  child: CommonText.medium(
                  label,
                  size: 12,
                  color: fg,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ))
              : CommonText.medium(label, size: 12, color: fg),
        ],
      ),
    );
  }
}

class _JobCardStatusChip extends StatelessWidget {
  const _JobCardStatusChip({required this.label, required this.scheme});

  final String label;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    bg = getBgColor(label, scheme);
    fg = getFgColor(label, scheme);
    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(UiConstants.radiusSmall),
      ),
      child: CommonText.semiBold(label, size: 12, color: fg).paddingSymmetric(horizontal: 12, vertical: 6),
    );
  }
}
