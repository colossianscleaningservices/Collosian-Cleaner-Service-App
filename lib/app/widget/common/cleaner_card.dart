import 'package:ccs_app/app/model/client_job.dart';
import 'package:ccs_app/export.dart';

/// Job detail cleaner row: avatar, name, status chip, check-in/out, and actions.
/// Used in both client and cleaner job detail views.
class CleanerCard extends StatelessWidget {
  const CleanerCard({
    super.key,
    required this.cleaner,
    required this.onReview,
    required this.onTap,
    required this.scheme,
    this.isReview = false,
    this.showActions = true,
    this.checkInText,
    this.checkOutText,
  });

  final ClientJobCleaner cleaner;
  final VoidCallback onReview, onTap;
  final ColorScheme scheme;
  final bool isReview;

  /// When false, hides Review / chevron (e.g. cleaner-facing job detail).
  final bool showActions;
  final String? checkInText;
  final String? checkOutText;

  bool get _isCompleted {
    final s = cleaner.status.toLowerCase();
    return s.contains('complete') || s.contains('finished') || s.contains('done');
  }

  @override
  Widget build(BuildContext context) {
    final statusLabel = cleaner.status.capitalizeFirst ?? cleaner.status;

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AppAvatar(
                radius: 8,
                imageUrl: cleaner.avatarUrl,
                name: cleaner.name,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText.semiBold(
                      cleaner.name,
                      size: 16,
                      color: scheme.onSurface,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    _StatusChip(label: statusLabel, scheme: scheme),
                  ],
                ),
              ),
              if (showActions) Icon(IconsaxPlusLinear.arrow_right_2, size: 18, color: scheme.onSurfaceVariant),
            ],
          ),
          /*if (hasAttendance) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(UiConstants.radiusDefault),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _AttendanceCell(
                      icon: IconsaxPlusLinear.login,
                      label: 'Check-in',
                      value: hasCheckIn ? checkInText! : '—',
                      scheme: scheme,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 36,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    color: scheme.outline.withValues(alpha: 0.16),
                  ),
                  Expanded(
                    child: _AttendanceCell(
                      icon: IconsaxPlusLinear.logout,
                      label: 'Check-out',
                      value: hasCheckOut ? checkOutText! : '—',
                      scheme: scheme,
                    ),
                  ),
                ],
              ),
            ),
          ],*/
          if (showActions && _isCompleted && isReview) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: _ActionPill(
                label: 'Review',
                icon: IconsaxPlusLinear.star,
                scheme: scheme,
                onPressed: onReview,
              ),
            ),
          ],
        ],
      ).paddingAll(UiConstants.defaultPadding),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.scheme});

  final String label;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: getBgColor(label, scheme),
        borderRadius: BorderRadius.circular(UiConstants.radiusSmall),
      ),
      child: CommonText.semiBold(
        label,
        size: 11,
        color: getFgColor(label, scheme),
      ).paddingSymmetric(horizontal: 10, vertical: 4),
    );
  }
}

class _ActionPill extends StatelessWidget {
  const _ActionPill({
    required this.label,
    required this.icon,
    required this.scheme,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final ColorScheme scheme;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: scheme.primaryContainer.withValues(alpha: 0.7),
      borderRadius: BorderRadius.circular(UiConstants.radiusDefault),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(UiConstants.radiusDefault),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: scheme.primary),
              const SizedBox(width: 6),
              CommonText.semiBold(label, size: 13, color: scheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}
