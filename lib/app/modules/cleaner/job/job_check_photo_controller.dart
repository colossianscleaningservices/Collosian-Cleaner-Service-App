import 'dart:io';
import 'dart:ui';

import 'package:ccs_app/app/network/repository/common_repository.dart';
import 'package:ccs_app/export.dart';
import 'package:dio/dio.dart' as dio;
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../network/repository/job_repository.dart';
import '../../../network/response/get_staff_job_details_response.dart';

enum JobCheckPhotoMode { checkIn, checkOut }

/// Runs on a background isolate. Applies watermark and writes JPEG to [outputPath].
bool _watermarkPhotoInIsolate((String outputPath, Uint8List imgBytes, String watermarkText) args) {
  final (outputPath, imgBytes, watermarkText) = args;
  try {
    final decoded = img.decodeImage(imgBytes);
    if (decoded == null) return false;

    const dstX = 16;
    const dstY = 16;
    const padding = 8;
    final font = decoded.width < 900 ? img.arial24 : img.arial48;
    final rectW = (watermarkText.length * (decoded.width < 900 ? 12 : 20)).clamp(40, decoded.width);
    final rectH = decoded.width < 900 ? 28 : 44;

    img.fillRect(
      decoded,
      x1: (dstX - padding).clamp(0, decoded.width - 1),
      y1: (dstY - padding).clamp(0, decoded.height - 1),
      x2: (dstX + rectW + padding).clamp(0, decoded.width),
      y2: (dstY + rectH + padding).clamp(0, decoded.height),
      color: img.ColorRgba8(0, 0, 0, 200),
    );
    img.drawString(
      decoded,
      watermarkText,
      font: font,
      x: dstX,
      y: dstY,
      color: img.ColorRgba8(255, 255, 255, 255),
    );

    final out = img.encodeJpg(decoded, quality: 90);
    File(outputPath).writeAsBytesSync(out, flush: true);
    return File(outputPath).existsSync();
  } catch (_) {
    return false;
  }
}

/// Controller for the check-in / check-out photo screen.
/// Cleaner adds one or more photos and submits; job is only started/stopped after API success.
class JobCheckPhotoController extends GetxController {
  final JobRepository _jobRepository = JobRepository();
  final CommonRepository _commonRepository = CommonRepository();

  StaffJobDetails? job;
  late final JobCheckPhotoMode mode;

  final scheduleValidFrom = Rxn<DateTime>();

  void setStartDate(DateTime? d) => scheduleValidFrom.value = d;
  final startTime = Rxn<TimeOfDay>();
  final dateDisplayController = TextEditingController();
  final startTimeDisplayController = TextEditingController();

  bool get isCheckIn => mode == JobCheckPhotoMode.checkIn;

  final RxList<XFile> photos = <XFile>[].obs;
  final ImagePicker picker = ImagePicker();

  static const int _imageQuality = 85;

  String get pageTitle => isCheckIn ? 'Check-in' : 'Check-out';

  String get pageSubtitle => isCheckIn ? 'Add photos to start the job' : 'Add photos to finish the job';

  String get submitLabel => isCheckIn ? 'Start job' : 'Stop job';

  String get timeLabel => isCheckIn ? 'Start Time' : 'Stop Time';
  String get dateLabel => isCheckIn ? 'Job Start Date' : 'Job End Date';

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map<String, dynamic>) {
      final j = args['job'];
      final m = args['mode'];
      if (j is StaffJobDetails) job = j;
      if (m is JobCheckPhotoMode) mode = m;
    } else if (args is List && args.length >= 2) {
      if (args[0] is StaffJobDetails) job = args[0] as StaffJobDetails;
      if (args[1] is JobCheckPhotoMode) mode = args[1] as JobCheckPhotoMode;
    } else {
      job = StaffJobDetails();
      mode = JobCheckPhotoMode.checkIn;
    }
    setScheduleValidFrom(DateTime.now());
    setStartTime(TimeOfDay.now());
  }

  String _watermarkedOutputPath(String sourcePath) {
    final separator = sourcePath.lastIndexOf(Platform.pathSeparator);
    final dir = separator >= 0 ? sourcePath.substring(0, separator) : sourcePath;
    return '$dir${Platform.pathSeparator}wm_${DateTime.now().millisecondsSinceEpoch}.jpg';
  }

  /// Converts HEIC/unsupported formats to PNG bytes the [img] package can decode.
  Future<Uint8List> _normalizeImageBytes(Uint8List bytes) async {
    try {
      final codec = await instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final data = await frame.image.toByteData(format: ImageByteFormat.png);
      frame.image.dispose();
      if (data == null) return Uint8List(0);
      return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    } catch (_) {
      return Uint8List(0);
    }
  }

  /// Watermarks [file] and returns a new [XFile], or null when processing fails.
  Future<XFile?> addBookmark(XFile file) async {
    try {
      var imgBytes = await file.readAsBytes();
      if (imgBytes.isEmpty) return null;

      if (img.decodeImage(imgBytes) == null) {
        final normalized = await _normalizeImageBytes(imgBytes);
        if (normalized.isEmpty) {
          log(runtimeType.toString(), 'Watermark skipped: unable to decode image (${file.path})');
          return null;
        }
        imgBytes = normalized;
      }

      final outputPath = _watermarkedOutputPath(file.path);
      final watermarkText = DateTime.now().toDisplayDate('dd, MMM yyyy, hh:mm a');
      final ok = await compute(
        _watermarkPhotoInIsolate,
        (outputPath, imgBytes, watermarkText),
      );
      if (!ok) {
        log(runtimeType.toString(), 'Watermark failed for ${file.path}');
        return null;
      }
      return XFile(outputPath);
    } catch (e, stack) {
      log(runtimeType.toString(), 'Watermark error: $e\n$stack');
      return null;
    }
  }

  Future<void> _processAndAddPhoto(XFile pickedFile) async {
    Loader.show();
    try {
      final watermarked = await addBookmark(pickedFile);
      if (watermarked != null) {
        photos.add(watermarked);
      } else {
        Notifier.error('Could not apply watermark. Please try again.');
      }
    } finally {
      Loader.hide();
    }
  }

  Future<void> addFromCamera() async {
    final file = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: _imageQuality,
    );
    if (file != null) {
      await _processAndAddPhoto(file);
    }
  }

  Future<void> addFromGallery() async {
    final files = await picker.pickMultiImage(imageQuality: _imageQuality);
    if (files.isEmpty) return;

    Loader.show();
    try {
      var addedAny = false;
      for (final item in files) {
        final watermarked = await addBookmark(item);
        if (watermarked != null) {
          photos.add(watermarked);
          addedAny = true;
        }
      }
      if (!addedAny) {
        Notifier.error('Could not process selected photos. Please try again.');
      }
    } finally {
      Loader.hide();
    }
  }

  void removePhoto(int index) {
    if (index >= 0 && index < photos.length) photos.removeAt(index);
  }

  void showPhotoSourceSheet(BuildContext context) {
    showPicker(cameraPicker: () => pickCameraImage(), isShowGalleryOption: false);
  }

  Future<void> pickCameraImage() async {
    try {
      final hasPermission = await requestCameraPermission();
      if (!hasPermission) return;

      final pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: _imageQuality,
      );
      if (pickedFile == null) return;

      await _processAndAddPhoto(pickedFile);
    } catch (e) {
      Loader.hide();
      Notifier.info('Failed to pick image: $e');
    }
  }

  Future<bool> requestCameraPermission() async {
    var status = await Permission.camera.status;

    if (status.isDenied) {
      status = await Permission.camera.request();
    }

    if (status.isGranted) {
      return true;
    }
    if (status.isPermanentlyDenied) {
      Notifier.info('Camera permission is required. Enable it in your device settings.');
    }
    return false;
  }

  Future<void> submit() async {
    if (photos.isEmpty) {
      Notifier.info('Add at least one photo');
      return;
    }

    if (job == null) {
      Notifier.error('Invalid job');
      return;
    }

    Loader.show();
    try {
      List<dio.MultipartFile> files = [];
      for (var photo in photos) {
        var value = await dio.MultipartFile.fromFile(photo.path, filename: "image_${DateTime.now()}.jpg").then((value) {
          return value;
        });
        files.add(value);
      }

      final data = <String, dynamic>{};
      data["files[]"] = files;
      data["mediaable_type"] = 'App\\Models\\Job';
      data["mediaable_id"] = '1';
      data["media_type"] = 'check_in';

      log(runtimeType.toString(), 'Media Upload Data => $data');
      for (var item in files) {
        log(runtimeType.toString(), 'Media Upload Data => ${item.length}');
      }

      final mediaUploadResult = await _commonRepository.mediaUpload(data);
      mediaUploadResult.handle(
        success: (value) async {
          List<String> imageUrlList = [];

          value.data?.fileUrl?.forEach((item) {
            imageUrlList.add(item);
          });

          final result = isCheckIn
              ? await _jobRepository.checkIn(
                  jobId: job?.id?.toInt() ?? 0,
                  checkInDate: scheduleValidFrom.value?.toDisplayDate('yyyy-MM-dd') ?? "",
                  checkInTime: startTime.value != null ? CcsDateTimeX.formatTimeOfDay(startTime.value!) : "",
                  photos: imageUrlList,
                )
              : await _jobRepository.checkOut(
                  jobId: job?.id?.toInt() ?? 0,
                  checkOutDate: scheduleValidFrom.value?.toDisplayDate('yyyy-MM-dd') ?? "",
                  checkOutTime: startTime.value != null ? CcsDateTimeX.formatTimeOfDay(startTime.value!) : "",
                  photos: imageUrlList,
                );

          result.handle(
            success: (value) {
              Notifier.success(value.message ?? (isCheckIn ? 'Job started' : 'Job completed'));
              Get.back(result: true);
            },
            contextTag: 'job_check_photo',
          );
        },
        contextTag: 'media_upload',
      );
    } finally {
      Loader.hide();
    }
  }

  void setScheduleValidFrom(DateTime d) {
    scheduleValidFrom.value = DateTime(d.year, d.month, d.day);
    dateDisplayController.text = CcsDateUtils.forInput(d);
  }

  void setStartTime(TimeOfDay? t) {
    startTime.value = t;
    startTimeDisplayController.text = t != null ? _formatTimeWithAmPm(t) : '';
  }

  String _formatTimeWithAmPm(TimeOfDay time) {
    final period = time.hour >= 12 ? 'PM' : 'AM';
    final hour12 = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour12:$minute $period';
  }
}
