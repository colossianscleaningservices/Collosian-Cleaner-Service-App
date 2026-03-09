import 'package:ccs_app/app/network/response/cleaner_review_list_response.dart';
import 'package:get/get.dart';

import '../../../network/repository/cleaner_repository.dart';
import '../../../network/utils/network_result_extensions.dart';
import '../../../utils/custom_loader.dart';

class CleanerReviewController extends GetxController {
  final CleanerRepository _cleanerRepository = CleanerRepository();

  final reviews = <Reviews>[].obs;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    _fetchReviewData();
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<void> _fetchReviewData() async {
    Loader.show();
    try {
      final reviewResult = await _cleanerRepository.geCleanerReviews();
      reviewResult.handle(
        success: (res) {
          final raw = res.data;

          if (raw != null && raw.reviews?.isNotEmpty == true) {
            reviews.addAll(res.data?.reviews as Iterable<Reviews>);
          }

          reviews.refresh();
        },
      );
    } catch (_) {
    } finally {
      Loader.hide();
    }
  }
}
