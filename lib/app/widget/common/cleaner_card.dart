import 'package:ccs_app/app/model/client_job.dart';
import 'package:ccs_app/export.dart';

/// Job detail cleaner row: avatar, name, status, and action buttons.
/// Used in both client and cleaner job detail views.
class CleanerCard extends StatelessWidget {
  const CleanerCard({
    super.key,
    required this.cleaner,
    required this.onShare,
    required this.onReview,
    required this.onTap,
    required this.scheme,
    this.isReview = false,
    this.showActions = true,
  });

  final ClientJobCleaner cleaner;
  final VoidCallback onShare, onReview, onTap;
  final ColorScheme scheme;
  final bool isReview;

  /// When false, hides Share / Review / View (e.g. cleaner-facing job detail).
  final bool showActions;

  bool get _isCompleted {
    final s = cleaner.status.toLowerCase();
    return s.contains('complete') || s.contains('finished') || s.contains('done');
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppAvatar(
            imageUrl: cleaner.avatarUrl,
            name: cleaner.name,
            radius: 8,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText.semiBold(cleaner.name, size: 15, color: scheme.onSurface),
                const SizedBox(height: 4),
                CommonText.regular('Status: ${cleaner.status}', size: 13, color: scheme.onSurfaceVariant),
                if (showActions) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    alignment: WrapAlignment.end,
                    children: [
                      if (_isCompleted)
                        if (isReview)
                          TextButton(
                            onPressed: onReview,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: CommonText.regular('Review', size: 14, color: scheme.primary),
                          )
                        else ...[
                          TextButton(
                            onPressed: onTap,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: CommonText.regular('View', size: 14, color: scheme.primary),
                          ),
                          TextButton(
                            onPressed: onShare,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: CommonText.regular('Share', size: 14, color: scheme.primary),
                          ),
                        ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ).paddingAll(UiConstants.defaultPadding),
    );
  }
}
