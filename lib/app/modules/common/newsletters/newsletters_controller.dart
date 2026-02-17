import 'package:ccs_app/app/network/repository/common_repository.dart';

import '../../../../export.dart';
import '../../../network/response/newsletter_response.dart';

class NewslettersController extends GetxController {
  final CommonRepository _commonRepository = CommonRepository();

  RxList<Newsletters> newsletters = <Newsletters>[].obs;
  ScrollController scrollController = ScrollController();
  var totalPage = 1;
  var currentPage = 1;
  bool _isLoading = false;

  @override
  void onInit() {
    scrollController.addListener(() {
      if (_isScrollBottom) {
        if (currentPage <= totalPage && !_isLoading) {
          loadNewsletters();
        }
      }
    });
    super.onInit();
  }

  @override
  void onReady() {
    loadNewsletters();
    super.onReady();
  }

  bool get _isScrollBottom {
    if (!scrollController.hasClients) return false;
    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  Future<void> loadNewsletters() async {
    if (_isLoading) return;
    _isLoading = true;
    Loader.show();
    try {
      final result = await _commonRepository.getNewsletters(page: currentPage);
      result.handle(
        success: (value) {
          if (currentPage == 1) newsletters.clear();
          newsletters.addAll(value.data?.newsletters ?? []);
          totalPage = (value.data?.pagination?.totalPages ?? 1).toInt();
          if (currentPage <= totalPage) {
            currentPage++;
          }
        },
        contextTag: 'get_newsletters',
      );
    } catch (e) {
      Notifier.error('Failed to load newsletters');
    } finally {
      Loader.hide();
      _isLoading = false;
    }
  }

  Future<void> refreshNewsletters() async {
    await loadNewsletters();
  }
}
