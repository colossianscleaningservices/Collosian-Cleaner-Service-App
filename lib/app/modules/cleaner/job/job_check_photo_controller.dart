import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:ccs_app/app/network/repository/common_repository.dart';
import 'package:ccs_app/export.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

import '../../../network/repository/job_repository.dart';
import '../../../network/response/get_staff_job_details_response.dart';

enum JobCheckPhotoMode { checkIn, checkOut }

/// Runs on a background isolate. Applies watermark and writes to [filePath].
void _watermarkPhotoInIsolate((String filePath, Uint8List imgBytes, String watermarkText) args) {
  final (filePath, imgBytes, watermarkText) = args;
  const dstX = 20;
  const dstY = 30;
  const padding = 12;
  final decoded = img.decodeImage(imgBytes);
  if (decoded == null) return;
  final rectW = (watermarkText.length * 24);
  final rectH = 44;
  img.fillRect(
    decoded,
    x1: (dstX - padding).clamp(0, decoded.width - 1),
    y1: (dstY - padding).clamp(0, decoded.height - 1),
    x2: (dstX + rectW + padding).clamp(0, decoded.width),
    y2: (dstY + rectH + padding).clamp(0, decoded.height),
    color: img.ColorRgba8(0, 0, 0, 255),
  );
  img.drawString(
    decoded,
    watermarkText,
    font: img.arial48,
    x: dstX,
    y: dstY,
    color: img.ColorRgba8(255, 255, 255, 255),
  );
  final out = img.encodeJpg(decoded);
  File(filePath).writeAsBytesSync(out);
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

  String get pageTitle => isCheckIn ? 'Check-in' : 'Check-out';

  String get pageSubtitle => isCheckIn ? 'Add photos to start the job' : 'Add photos to finish the job';

  String get submitLabel => isCheckIn ? 'Start job' : 'Stop job';

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

  Future<void> addFromCamera([BuildContext? overlayContext]) async {
    final XFile? file = await picker.pickImage(source: ImageSource.camera);
    if (file != null) {
      Loader.show();
      final ctx = overlayContext != null && overlayContext.mounted ? overlayContext : null;
      // ignore: use_build_context_synchronously - ctx is re-checked for mounted in addBookmark
      await addBookmark(file, ctx);
      Loader.hide();
      photos.add(file);
    }
  }

  /// Renders watermark (styled pill with icon + Manrope text) as PNG and overlays on photo.
  /// Kept for optional future use when Manrope overlay is re-enabled.
  // ignore: unused_element
  Future<Uint8List?> _renderManropeWatermarkToPng(
    BuildContext context, {
    required String text,
    required double fontSize,
    double paddingV = 10,
    double iconSize = 18,
    double iconGap = 8,
  }) async {
    if (!context.mounted) return null;
    final scheme = context.colorScheme;
    final textColor = scheme.onSecondaryContainer;
    final style = GoogleFonts.manrope(
      fontSize: fontSize,
      color: textColor,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.2,
    );
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    final contentW = iconSize + iconGap + textPainter.width + 16;
    final contentH = textPainter.height.clamp(iconSize, double.infinity);
    final w = (contentW).ceil();
    final h = (contentH + paddingV * 2).ceil();
    final overlay = Overlay.of(context);
    final key = GlobalKey();
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => Positioned(
        left: -w * 2,
        top: 0,
        child: RepaintBoundary(
          key: key,
          child: Container(
            clipBehavior: Clip.hardEdge,
            width: w.toDouble(),
            height: h.toDouble(),
            decoration: BoxDecoration(
              color: scheme.secondaryContainer,
              boxShadow: context.effectiveShadows(),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: paddingV),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: iconSize,
                    color: scheme.secondary,
                  ),
                  SizedBox(width: iconGap),
                  Flexible(
                    child: CommonText.bold(
                      text,
                      isUnderLine: false,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    overlay.insert(entry);

    final completer = Completer<void>();
    WidgetsBinding.instance.addPostFrameCallback((_) => completer.complete());
    await completer.future;
    await Future<void>.delayed(const Duration(milliseconds: 50));

    final boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) {
      entry.remove();
      return null;
    }
    final image = await boundary.toImage(pixelRatio: 2.0);
    entry.remove();

    final byteData = await image.toByteData(format: ImageByteFormat.png);
    if (byteData == null) return null;
    return byteData.buffer.asUint8List(
      byteData.offsetInBytes,
      byteData.lengthInBytes,
    );
  }

  Future<void> addBookmark(XFile file, [BuildContext? context]) async {
    final imgBytes = await file.readAsBytes();
    final watermarkText = DateTime.now().toDisplayDate('dd, MMM yyyy, hh:mm a');

    await compute(
      _watermarkPhotoInIsolate,
      (file.path, imgBytes, watermarkText),
    );
  }

  Future<void> addFromGallery([BuildContext? overlayContext]) async {
    final files = await picker.pickMultiImage();
    if (files.isNotEmpty) {
      final ctx = overlayContext != null && overlayContext.mounted ? overlayContext : null;
      Loader.show();
      for (final item in files) {
        // ignore: use_build_context_synchronously - ctx only used when Manrope path is enabled
        await addBookmark(item, ctx);
      }
      Loader.hide();
      photos.addAll(files);
    }
  }

  void removePhoto(int index) {
    if (index >= 0 && index < photos.length) photos.removeAt(index);
  }

  void showPhotoSourceSheet(BuildContext context) {
    showPicker(cameraPicker: () => pickCameraImage(context), isShowGalleryOption: false);
  }

  Future<void> pickCameraImage([BuildContext? overlayContext]) async {
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        Loader.show();
        final ctx = overlayContext != null && overlayContext.mounted ? overlayContext : null;
        // ignore: use_build_context_synchronously - ctx is re-checked for mounted in addBookmark
        await addBookmark(pickedFile, ctx);
        Loader.hide();
        photos.add(pickedFile);
      }
    } catch (e) {
      Notifier.info('Failed to pick image: $e');
    }
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

          value.data?.fileUrl?.forEach((item){
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
    dateDisplayController.text = d != null ? CcsDateUtils.forInput(d) : '';
  }

  void setStartTime(TimeOfDay? t) {
    startTime.value = t;
    startTimeDisplayController.text = t != null ? '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}' : '';
  }
}
