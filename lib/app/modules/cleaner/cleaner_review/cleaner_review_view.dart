import 'package:ccs_app/app/network/response/cleaner_review_list_response.dart';
import 'package:ccs_app/app/widget/layout/app_scaffold.dart';
import 'package:ccs_app/export.dart';
import 'package:intl/intl.dart';

import 'cleaner_review_controller.dart';

/// Cleaner reviews: summary card (average rating, count) and list of client reviews.
class CleanerReviewView extends GetView<CleanerReviewController> {
  const CleanerReviewView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return AppScaffold(
      appBar: Header(
        title: 'Reviews',
        headerLogoIcon: false,
        hasBackIcon: true,
        titleCentered: false,
      ),
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Obx(() {
          return controller.reviews.isEmpty
              ? NoDataView(
                  title: 'No reviews yet',
                  subtitle: 'Reviews from clients will appear here after completed jobs.',
                  icon: IconsaxPlusLinear.star_1,
                )
              : SingleChildScrollView(
                  padding: UiConstants.padding,
                  controller: controller.reviewScrollController,child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Summary card
                      AppCard(
                        child: Row(
                          children: [
                            AppCard(
                              enableShadows: false,
                              radius: UiConstants.radiusDefault,
                              color: scheme.primaryContainer,
                              child: Icon(
                                IconsaxPlusLinear.star_1,
                                size: 28,
                                color: scheme.primary,
                              ).paddingAll(14),
                            ).marginOnly(right: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CommonText.extraBold(
                                    controller.overAllRating.value.toString(),
                                    size: 28,
                                    color: scheme.onSurface,
                                  ),
                                  const SizedBox(height: 4),
                                  _StarRating(rating: controller.overAllRating.value, scheme: scheme, size: 16),
                                  const SizedBox(height: 4),
                                  CommonText.regular(
                                    '${controller.reviewCount.value} ${controller.reviewCount.value == 1 ? 'review' : 'reviews'}',
                                    size: 14,
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ).paddingAll(UiConstants.defaultPadding),
                      ),
                      const SizedBox(height: 20),

                      // Section title
                      Row(
                        children: [
                          Icon(IconsaxPlusLinear.message_text_1, size: 20, color: scheme.primary),
                          const SizedBox(width: 8),
                          CommonText.semiBold('Recent reviews', size: 16, color: scheme.onSurface),
                        ],
                      ),
                      const SizedBox(height: 12),

                      ListView.builder(
                          itemCount: controller.reviews.length,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return _ReviewCard(review: controller.reviews[index], scheme: scheme).marginOnly(bottom: 12);
                          }),
                      const SizedBox(height: UiConstants.gap),
                    ],
                  ));
        }),
      ),
    );
  }
}

class _StarRating extends StatelessWidget {
  const _StarRating({required this.rating, required this.scheme, this.size = 18});

  final double rating;
  final ColorScheme scheme;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < rating.floor() || (i == rating.floor() && rating % 1 >= 0.5);
        return Padding(
          padding: EdgeInsets.only(right: i < 4 ? 4 : 0),
          child: Icon(
            filled ? IconsaxPlusBold.star : IconsaxPlusLinear.star,
            size: size,
            color: scheme.primary,
          ),
        );
      }),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review, required this.scheme});

  final Reviews review;
  final ColorScheme scheme;

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} weeks ago';
    return DateFormat('d MMM yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: scheme.primaryContainer,
                child: CommonText.semiBold(
                  review.client?.name?.isNotEmpty == true ? review.client!.name![0].toUpperCase() : '?',
                  size: 18,
                  color: scheme.primary,
                ),
              ).marginOnly(right: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: CommonText.semiBold(review.client?.name ?? '', size: 16, color: scheme.onSurface),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(IconsaxPlusLinear.calendar_1, size: 14, color: scheme.onSurfaceVariant).marginOnly(right: 6),
                            CommonText.regular(
                              review.submittedAt != null ? _formatDate(DateTime.parse(review.submittedAt ?? "")) : "N/A",
                              size: 12,
                              color: scheme.onSurfaceVariant,
                            ),
                          ],
                        ),
                      ],
                    ).marginOnly(bottom: 4),
                    _StarRating(rating: review.satisfactionRating?.toDouble() ?? 0.0, scheme: scheme, size: 16),
                  ],
                ),
              ),
            ],
          ).marginOnly(bottom: 8),
          if (review.comments != null)
            CommonText.regular(
              review.comments ?? 'N/A',
              size: 14,
              color: scheme.onSurface.withValues(alpha: 0.9),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ).paddingAll(UiConstants.defaultPadding),
    );
  }
}
