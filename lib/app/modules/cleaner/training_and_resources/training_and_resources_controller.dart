import 'package:ccs_app/app/model/common_model.dart';
import 'package:chewie/chewie.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:video_player/video_player.dart';

import '../../../../export.dart';
import '../../../network/repository/common_repository.dart';
import '../../../network/response/training_resource_response.dart';

class TrainingAndResourcesController extends GetxController {
  var searchFocus = FocusNode();
  var searchController = TextEditingController();
  var searchTerm = ''.obs;
  RxList<CommonModel> filter = <CommonModel>[].obs;
  RxList<Trainings> trainingList = <Trainings>[].obs;
  RxList<Trainings> mainTrainingList = <Trainings>[].obs;

  final CommonRepository _commonRepository = CommonRepository();
  ScrollController scrollController = ScrollController();
  final Rxn<Counts> counts = Rxn<Counts>(null);
  var totalPage = 1;
  var currentPage = 1;
  RxBool isMoreLoading = false.obs;
  var prevSearch = '';

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(() {
      if (_isScrollBottom) {
        if (currentPage <= totalPage && !isMoreLoading.value) {
          isMoreLoading.value = true;
          getTrainingResources();
        }
      }
    });

    searchController.addListener(() {
      if (searchController.text.trim().length > 2) {
        if (searchController.text.isNotEmpty) {
          if (prevSearch == searchController.text.trim()) return;
        }
        currentPage = 1;
        getTrainingResources(isFromSearch: true);
      } else if (searchController.text.isEmpty) {
        if (mainTrainingList.isNotEmpty) {
          trainingList.clear();
          trainingList.addAll(mainTrainingList);
        }
      }
    });

    initList();
  }

  bool get _isScrollBottom {
    if (!scrollController.hasClients) return false;
    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void initList() {
    filter.clear();
    filter.add(CommonModel(type: "All", isSelected: true));
    filter.add(CommonModel(type: "Video"));
    filter.add(CommonModel(type: "Flyer"));
  }

  @override
  void onReady() {
    getTrainingResources();
    super.onReady();
  }

  @override
  void onClose() {
    for (final item in trainingList) {
      item.chewieController?.videoPlayerController.dispose();
      item.chewieController?.dispose();
    }
    searchFocus.dispose();
    searchController.dispose();
    super.onClose();
  }

  /// Called by pull-to-refresh. Disposes existing video controllers and reloads the list.
  Future<void> refreshTraining() async {
    for (final item in trainingList) {
      item.chewieController?.videoPlayerController.dispose();
      item.chewieController?.dispose();
      item.chewieController = null;
    }
    currentPage = 1;
    getTrainingResources();
  }

  Future<void> getTrainingResources({bool isFromSearch = false}) async {
    if (!isMoreLoading.value && !isFromSearch) Loader.show();
    try {
      String? filterItem;
      filterItem = filter.firstWhereOrNull((item) => item.isSelected)?.type;

      final result = await _commonRepository.getTrainingResources(
          page: currentPage,
          filter: filterItem == "All"
              ? null
              : filterItem == 'Flyer'
                  ? 'Flyer/Document'
                  : filterItem,
          search: searchController.text);
      result.handle(
        success: (value) async {
          if (currentPage == 1) trainingList.clear();

          if (!isFromSearch) {
            mainTrainingList.clear();
          } else {
            prevSearch = searchController.text.trim();
          }

          value.data?.resources?.trainings?.forEach((item) async {
            if (trainingList.firstWhereOrNull((tr) => tr.id == item.id) == null) {
              if (item.contentType?.toLowerCase() == 'video') {
                final videoUrl = item.fileUrl;
                if (videoUrl != null && videoUrl.isNotEmpty) {
                  final ctrl = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
                  final chewieCtrl = ChewieController(
                    videoPlayerController: ctrl,
                    autoInitialize: true,
                    autoPlay: false,
                    looping: false,
                    allowFullScreen: true,
                    allowPlaybackSpeedChanging: false,
                    showControlsOnInitialize: false,
                  );
                  item.chewieController = chewieCtrl;
                }
              }
              trainingList.add(item);
            }
          });

          trainingList.refresh();

          if (!isFromSearch) {
            mainTrainingList.addAll(trainingList);
          }

          if (searchController.text.isEmpty) {
            trainingList.clear();
            trainingList.addAll(mainTrainingList);
          }

          totalPage = (value.data?.resources?.pagination?.totalPages ?? 1).toInt();

          if (currentPage <= totalPage) {
            currentPage++;
          }

          counts.value = value.data?.counts;
        },
        contextTag: 'get_training_resources',
      );
    } catch (e) {
      Notifier.error('Failed to fetch training resource');
    } finally {
      if (!isMoreLoading.value && !isFromSearch) Loader.hide();
      isMoreLoading.value = false;
    }
  }

  Future<void> seenTrainingResources(int id, int index) async {
    try {
      final result = await _commonRepository.seenTrainingResources(id);
      result.handle(
        success: (value) {
          trainingList[index].isSeen = true;
          counts.value?.seen = ((counts.value?.seen ?? 0) + 1);
          counts.value?.unseen = ((counts.value?.unseen ?? 1) - 1);
          trainingList.refresh();
        },
        contextTag: 'seenTrainingResources',
      );
    } catch (e) {
      Notifier.error('Failed to mark as seen');
    } finally {}
  }

  Future<void> onViewFile(String url) async {
    final GlobalKey<SfPdfViewerState> pdfViewerKey = GlobalKey();
    Notifier.openSheet(Get.context as BuildContext,
        showIcon: false,
        showPrimaryButton: false,
        showSecondaryButton: false,
        top: true,
        expandBody: true,
        body: SfPdfViewer.network(
          url,
          key: pdfViewerKey,
          password: "1234",
        ));
  }
}
