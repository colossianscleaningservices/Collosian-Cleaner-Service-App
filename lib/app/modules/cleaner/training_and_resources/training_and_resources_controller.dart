import 'package:ccs_app/app/model/common_model.dart';
import 'package:video_player/video_player.dart';

import '../../../../export.dart';
import '../../../network/repository/common_repository.dart';
import '../../../network/response/training_resource_response.dart';

class TrainingAndResourcesController extends GetxController {
  var groupSearchFocus = FocusNode();
  var groupSearchController = TextEditingController();
  var searchTerm = ''.obs;
  RxList<CommonModel> filter = <CommonModel>[].obs;
  RxList<CommonModel> training = <CommonModel>[].obs;

  final CommonRepository _commonRepository = CommonRepository();
  ScrollController scrollController = ScrollController();
  final Rxn<Counts> counts = Rxn<Counts>(null);
  var totalPage = 1;
  var currentPage = 1;
  var moreLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(() {
      if (_isScrollBottom) {
        if (currentPage <= totalPage) {
          if (moreLoading.value) return;
          moreLoading.value = true;
          getTrainingResources();
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

  /// Primary demo video (720p H.264). Some devices fail with MediaCodec on this.
  static const String _videoUrlPrimary = 'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4';
  static const String _videoUrlSecondary = 'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4';

  /// Fallback: smaller / more compatible encoding for devices that fail on primary.
  static const String _videoUrlFallback = 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4';

  void initList() {
    filter.clear();
    filter.add(CommonModel(type: "All", isSelected: true));
    filter.add(CommonModel(type: "Video"));
    filter.add(CommonModel(type: "Flyer"));
  }

  void addDummyData() {
    training.clear();
    final uriPrimary = Uri.parse(_videoUrlPrimary);
    final uriFallback = Uri.parse(_videoUrlFallback);

    final ctrl1 = VideoPlayerController.networkUrl(uriPrimary);
    _initializeWithFallback(ctrl1, uriFallback, (newCtrl) {
      final i = _indexOfController(ctrl1);
      if (i >= 0) _replaceVideoControllerAt(i, newCtrl);
    });
    training.add(CommonModel(type: "Video", videoPlayerController: ctrl1));

    final ctrl2 = VideoPlayerController.networkUrl(Uri.parse(_videoUrlSecondary));
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!ctrl2.value.isInitialized && !ctrl2.value.hasError) {
        _initializeWithFallback(ctrl2, uriFallback, (newCtrl) {
          final i = _indexOfController(ctrl2);
          if (i >= 0) _replaceVideoControllerAt(i, newCtrl);
        });
      }
    });
    training.add(CommonModel(type: "Video", videoPlayerController: ctrl2));

    training.add(CommonModel(type: 'flyer'));
    training.add(CommonModel(type: 'flyer'));
    training.add(CommonModel(type: 'flyer'));
    training.add(CommonModel(type: 'flyer'));
    training.add(CommonModel(type: 'flyer'));
    training.add(CommonModel(type: 'flyer'));
  }

  int _indexOfController(VideoPlayerController ctrl) {
    final len = training.length;
    for (var i = 0; i < len; i++) {
      if (training[i].videoPlayerController == ctrl) return i;
    }
    return -1;
  }

  void _replaceVideoControllerAt(int index, VideoPlayerController? newCtrl) {
    final len = training.length;
    if (index < 0 || index >= len) return;
    final item = training[index];
    item.videoPlayerController?.dispose();
    item.videoPlayerController = newCtrl;
    training.refresh();
  }

  /// Initialize video; on codec/network error try fallback URL (often more compatible).
  void _initializeWithFallback(
    VideoPlayerController ctrl,
    Uri fallbackUri,
    void Function(VideoPlayerController? newCtrl) onFallbackReady,
  ) {
    ctrl.initialize().then((_) {
      // Success with primary
    }).catchError((Object e, StackTrace st) {
      debugPrint('Video init failed, trying fallback: $e');
      final fallback = VideoPlayerController.networkUrl(fallbackUri);
      fallback.initialize().then((_) {
        onFallbackReady(fallback);
      }).catchError((Object e2, StackTrace st2) {
        debugPrint('Fallback video also failed: $e2');
        fallback.dispose();
        onFallbackReady(null);
      });
    });
  }

  @override
  void onReady() {
    getTrainingResources();
    super.onReady();
  }

  @override
  void onClose() {
    for (final item in training) {
      item.videoPlayerController?.dispose();
    }
    groupSearchFocus.dispose();
    groupSearchController.dispose();
    super.onClose();
  }

  /// Called by pull-to-refresh. Disposes existing video controllers and reloads the list.
  Future<void> refreshTraining() async {
    for (final item in training) {
      item.videoPlayerController?.dispose();
      item.videoPlayerController = null;
    }
    currentPage = 1;
    getTrainingResources();
  }

  Future<void> getTrainingResources() async {
    if (moreLoading.value == false) Loader.show();
    try {
      final result = await _commonRepository.getTrainingResources(page: currentPage);
      result.when(
        success: (value) {
          if (currentPage == 1) training.clear();

          totalPage = (value.data?.resources?.pagination?.totalPages ?? 1).toInt();

          if (currentPage <= totalPage) {
            currentPage++;
          }

          counts.value = value.data?.counts;
        },
        error: (e) async {
          await Notifier.apiError(e, contextTag: 'get_training_resources');
        },
      );
    } catch (e) {
      Notifier.error('Failed to fetch training resource');
    } finally {
      if (moreLoading.value == false) Loader.hide();
      moreLoading.value = false;
    }
  }
}
