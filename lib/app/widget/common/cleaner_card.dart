import 'package:ccs_app/app/model/client_job.dart';
import 'package:ccs_app/export.dart';

/// Job detail cleaner row: avatar, name, status, Share button.
/// Used in both client and cleaner job detail views.
class CleanerCard extends StatelessWidget {
  const CleanerCard({super.key, required this.cleaner, required this.onShare, required this.onReview, required this.onTap, required this.scheme, this.isReview = false});

  final ClientJobCleaner cleaner;
  final VoidCallback onShare, onReview, onTap;
  final ColorScheme scheme;
  final bool isReview;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
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
                const SizedBox(height: 2),
                CommonText.regular(cleaner.status, size: 13, color: scheme.onSurfaceVariant),
              ],
            ),
          ),
         /* TextButton(
            onPressed: onShare,
            child: CommonText.regular('Share', size: 14, color: scheme.primary),
          ),*/
          if (isReview)
            TextButton(
              onPressed: onReview,
              child: CommonText.regular('Review', size: 14, color: scheme.primary),
            ),
        ],
      ).paddingAll(UiConstants.defaultPadding),
    );
  }
}
