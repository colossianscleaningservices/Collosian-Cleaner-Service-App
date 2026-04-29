import '../../../../export.dart';
import '../../../network/repository/client_repository.dart';
import '../../../network/response/jobs.dart';

class UpcomingJobController extends GetxController {
  //JOBS
  RxList<Jobs> jobs = <Jobs>[].obs;
  var jobCurrentPage = 1;
  var jobTotalPage = 1;
  RxBool isJobMoreLoading = false.obs;
  ScrollController jobScrollController = ScrollController();
  final ClientRepository _clientRepository = ClientRepository();

  @override
  void onInit() {
    jobScrollController.addListener(() {
      if (_isScrollBottom) {
        if (jobCurrentPage <= jobTotalPage && !isJobMoreLoading.value) {
          isJobMoreLoading.value = true;
          fetchJobs();
        }
      }
    });
    super.onInit();
  }

  @override
  void onReady() {
    fetchJobs();
    super.onReady();
  }

  bool get _isScrollBottom {
    if (!jobScrollController.hasClients) return false;
    final maxScroll = jobScrollController.position.maxScrollExtent;
    final currentScroll = jobScrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  Future<void> fetchJobs({bool isLoaderShown = true}) async {
    if (!isJobMoreLoading.value && isLoaderShown) Loader.show();
    try {
      final result = await _clientRepository.getJob(page: jobCurrentPage, upcoming: true);
      result.handle(
        success: (response) {
          final raw = response.data;
          if (jobCurrentPage == 1) jobs.clear();
          if (raw != null && raw.jobs?.isNotEmpty == true) {
            jobs.addAll(raw.jobs as Iterable<Jobs>);
          }
          jobTotalPage = (response.data?.pagination?.totalPages ?? 1).toInt();

          if (jobCurrentPage <= jobTotalPage) {
            jobCurrentPage++;
          }
        },
      );
    } finally {
      if (!isJobMoreLoading.value && isLoaderShown) Loader.hide();
      isJobMoreLoading.value = false;
    }
  }

  void openDetail(Jobs job) {
    Get.toNamed(Routes.CLIENT_JOB_DETAIL, arguments: job.id)?.then((value) {
      if (value != null) {
        if (value.containsKey('action') && value['action'] == 'delete') {
          jobs.removeWhere((p) => p.id == job.id);
          jobs.refresh();
        }
      }
    });
  }
}
