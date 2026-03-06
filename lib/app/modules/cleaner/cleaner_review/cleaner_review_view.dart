import 'package:ccs_app/app/model/review_item.dart';
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

    // Dummy data until controller/API provides real reviews
    final reviews = _getDummyReviews();
    final averageRating = reviews.isEmpty ? 0.0 : reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;
    final roundedRating = (averageRating * 10).round() / 10;

    return AppScaffold(
      appBar: Header(
        title: 'Reviews',
        headerLogoIcon: false,
        hasBackIcon: true,
        titleCentered: false,
      ),
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: reviews.isEmpty
            ? NoDataView(
                title: 'No reviews yet',
                subtitle: 'Reviews from clients will appear here after completed jobs.',
                icon: IconsaxPlusLinear.star_1,
              )
            : SingleChildScrollView(
                padding: UiConstants.padding,
                child: Column(
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
                                  roundedRating.toStringAsFixed(1),
                                  size: 28,
                                  color: scheme.onSurface,
                                ),
                                const SizedBox(height: 4),
                                _StarRating(rating: roundedRating, scheme: scheme, size: 16),
                                const SizedBox(height: 4),
                                CommonText.regular(
                                  '${reviews.length} ${reviews.length == 1 ? 'review' : 'reviews'}',
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

                    // Review list
                    ...reviews.map(
                      (review) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ReviewCard(review: review, scheme: scheme),
                      ),
                    ),
                    const SizedBox(height: UiConstants.gap),
                  ],
                ),
              ),
      ),
    );
  }

  List<ReviewItem> _getDummyReviews() {
    final now = DateTime.now();
    return [
      ReviewItem(
        name: 'Sarah Johnson',
        clientName: 'Sarah Johnson',
        rating: 5,
        comment: 'Excellent deep clean. Very thorough and professional. Would definitely book again.',
        date: now.subtract(const Duration(days: 2)),
      ),
      ReviewItem(
        name: 'Michael Brown',
        clientName: 'Michael Brown',
        rating: 5,
        comment: 'Great job on the end-of-tenancy clean. The property was spotless.',
        date: now.subtract(const Duration(days: 5)),
      ),
      ReviewItem(
        name: 'Emma Wilson',
        clientName: 'Emma Wilson',
        rating: 4,
        comment: 'Good standard clean. A few missed spots but overall happy with the service.',
        date: now.subtract(const Duration(days: 10)),
      ),
      ReviewItem(
        name: 'James Taylor',
        clientName: 'James Taylor',
        rating: 5,
        comment: 'Prompt, friendly and left the place gleaming. Highly recommend.',
        date: now.subtract(const Duration(days: 14)),
      ),
      ReviewItem(
        name: 'Olivia Davis',
        clientName: 'Olivia Davis',
        rating: 4,
        comment: 'Very satisfied. Will use again for regular cleaning.',
        date: now.subtract(const Duration(days: 21)),
      ),
    ];
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
            filled ? Icons.star_rounded : Icons.star_border_rounded,
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

  final ReviewItem review;
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: scheme.primaryContainer,
                child: CommonText.semiBold(
                  review.name.isNotEmpty ? review.name[0].toUpperCase() : '?',
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
                          child: CommonText.semiBold(review.name, size: 16, color: scheme.onSurface),
                        ),
                        Row(
                          children: [
                            Icon(IconsaxPlusLinear.calendar_1, size: 14, color: scheme.onSurfaceVariant).marginOnly(right: 6),
                            CommonText.regular(
                              _formatDate(review.date),
                              size: 12,
                              color: scheme.onSurfaceVariant,
                            ),
                          ],
                        ),
                      ],
                    ).marginOnly(bottom: 4),
                    // Row(
                    //   children: [
                    //     CommonText.regular('Client: ', size: 14, color: scheme.onSurfaceVariant),
                    //     Expanded(
                    //       child: CommonText.semiBold(review.clientName, size: 16, color: scheme.onSurface),
                    //     ),
                    //   ],
                    // ),
                    // const SizedBox(height: 6),
                    _StarRating(rating: review.rating.toDouble(), scheme: scheme, size: 16),
                  ],
                ),
              ),
            ],
          ).marginOnly(bottom: 8),
          CommonText.regular(
            review.comment,
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
