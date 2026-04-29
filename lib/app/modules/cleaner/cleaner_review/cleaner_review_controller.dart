import 'package:ccs_app/app/network/response/cleaner_review_list_response.dart';

import '../../../../export.dart';
import '../../../network/repository/cleaner_repository.dart';

class CleanerReviewController extends GetxController {
  final CleanerRepository _cleanerRepository = CleanerRepository();

  RxList<Reviews> reviews = <Reviews>[].obs;
  var reviewCurrentPage = 1;
  var reviewTotalPage = 1;
  RxBool isReviewMoreLoading = false.obs;
  ScrollController reviewScrollController = ScrollController();

  var overAllRating = 0.0.obs;
  var reviewCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    reviewScrollController.addListener(() {
      if (_isScrollBottom) {
        if (reviewCurrentPage <= reviewTotalPage && !isReviewMoreLoading.value) {
          isReviewMoreLoading.value = true;
          _fetchReviewData();
        }
      }
    });
  }

  bool get _isScrollBottom {
    if (!reviewScrollController.hasClients) return false;
    final maxScroll = reviewScrollController.position.maxScrollExtent;
    final currentScroll = reviewScrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  void onReady() {
    super.onReady();
    _fetchReviewData();
  }

  Future<void> _fetchReviewData({bool isLoaderShown = true}) async {
    if (!isReviewMoreLoading.value && isLoaderShown) Loader.show();
    try {
      final reviewResult = await _cleanerRepository.geCleanerReviews(reviewCurrentPage);
      reviewResult.handle(
        success: (res) {
          final raw = res.data;
          if (reviewCurrentPage == 1) reviews.clear();

          if (raw != null && raw.reviews?.isNotEmpty == true) {
            reviews.addAll(res.data?.reviews as Iterable<Reviews>);
          }

          reviews.refresh();

          reviewTotalPage = (res.data?.pagination?.totalPages ?? 1).toInt();

          overAllRating.value = res.data?.overallRating?.toDouble() ?? 0.0;
          reviewCount.value = res.data?.totalReviews?.toInt() ?? 0;

          if (reviewCurrentPage <= reviewTotalPage) {
            reviewCurrentPage++;
          }
        },
      );
    } finally {
      if (!isReviewMoreLoading.value && isLoaderShown) Loader.hide();
      isReviewMoreLoading.value = false;
    }
  }
}
