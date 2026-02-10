import 'package:ccs_app/export.dart';
import 'package:image_picker/image_picker.dart';

import '../../../model/client_job.dart';
import '../../../network/repository/cleaner_repository.dart';

enum JobCheckPhotoMode { checkIn, checkOut }

/// Controller for the check-in / check-out photo screen.
/// Cleaner adds one or more photos and submits; job is only started/stopped after API success.
class JobCheckPhotoController extends GetxController {
  final CleanerRepository _cleanerRepository = CleanerRepository();

  late final ClientJob job;
  late final JobCheckPhotoMode mode;

  bool get isCheckIn => mode == JobCheckPhotoMode.checkIn;

  final RxList<XFile> photos = <XFile>[].obs;
  final isSubmitting = false.obs;
  final ImagePicker picker = ImagePicker();

  String get pageTitle => isCheckIn ? 'Check-in' : 'Check-out';

  String get pageSubtitle => isCheckIn ? 'Add photos to start the job' : 'Add photos to finish the job';

  String get submitLabel => isCheckIn ? 'Start job' : 'Stop job';

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    job = ClientJob(
      id: '',
      clientName: '—',
      jobType: '—',
      date: DateTime.now(),
      startTime: '—',
      endTime: '—',
      status: '—',
      propertyOneLine: '—',
    );
    mode = JobCheckPhotoMode.checkIn;
    if (args is Map) {
      final j = args['job'];
      final m = args['mode'];
      if (j is ClientJob) job = j;
      if (m is JobCheckPhotoMode) mode = m;
    } else if (args is List && args.length >= 2) {
      if (args[0] is ClientJob) job = args[0] as ClientJob;
      if (args[1] is JobCheckPhotoMode) mode = args[1] as JobCheckPhotoMode;
    }
  }

  Future<void> addFromCamera() async {
    final XFile? file = await picker.pickImage(source: ImageSource.camera);
    if (file != null) photos.add(file);
  }

  Future<void> addFromGallery() async {
    final List<XFile>? files = await picker.pickMultiImage();
    if (files != null && files.isNotEmpty) photos.addAll(files);
  }

  void removePhoto(int index) {
    if (index >= 0 && index < photos.length) photos.removeAt(index);
  }

  void showPhotoSourceSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      clipBehavior: Clip.hardEdge,
      useSafeArea: true,
      backgroundColor: context.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(UiConstants.defaultPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CommonText.extraBold('Add photo', size: 18, color: context.colorScheme.onSurface),
              const SizedBox(height: 16),
              AppButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  addFromCamera();
                },
                label: 'Camera',
              ),
              const SizedBox(height: 12),
              AppButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  addFromGallery();
                },
                label: 'Gallery',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> submit() async {
    if (photos.isEmpty) {
      Notifier.info('Add at least one photo');
      return;
    }
    isSubmitting.value = true;
    try {
      final result = isCheckIn
          ? await _cleanerRepository.checkIn(jobId: job.id, photos: photos.toList())
          : await _cleanerRepository.checkOut(jobId: job.id, photos: photos.toList());
      result.when(
        success: (_) {
          Notifier.success(isCheckIn ? 'Job started' : 'Job completed');
          Get.back(result: true);
        },
        error: (e) async => await Notifier.apiError(e, contextTag: 'job_check_photo'),
      );
    } finally {
      isSubmitting.value = false;
    }
  }
}
