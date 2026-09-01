import 'dart:io';

import 'package:ccs_app/app/network/repository/client_repository.dart';
import 'package:ccs_app/app/network/request/update_schedule_job_request.dart';
import 'package:ccs_app/app/network/request/pause_schedule_request.dart';
import 'package:ccs_app/app/network/request/schedule_job_request.dart';
import 'package:ccs_app/app/utils/download_utils.dart';
import 'package:ccs_app/export.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import '../../../model/client_job.dart';
import '../../../network/response/get_client_job_details_response.dart';
import '../dashboard/client_dashboard_controller.dart';

enum UserOptions { yes, no }

class ClientJobDetailController extends GetxController {
  final ClientRepository _clientRepository = ClientRepository();

  final job = Rx<ClientJobDetails?>(null);
  final isFetching = false.obs;
  final fetchError = RxnString();

  num? jobId;
  var from = '';

  Rx<UserOptions?> arrive = Rx<UserOptions?>(null);
  Rx<UserOptions?> uniform = Rx<UserOptions?>(null);
  Rx<UserOptions?> completedJob = Rx<UserOptions?>(null);
  Rx<UserOptions?> requestAgain = Rx<UserOptions?>(null);
  Rx<double> rating = 0.0.obs;
  final messageController = TextEditingController();
  final hoursController = TextEditingController();
  final reasonController = TextEditingController();
  final jobCleaner = Rx<ClientJobCleaner?>(null);
  final cleanerHeading = Rxn<String?>('Cleaners');

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is num) {
      jobId = args;
    }
    if (args is Map<String, dynamic>) {
      if (args['from'] != null) {
        from = args['from'];
      }

      if (args['jobId'] != null) {
        jobId = args['jobId'];
      }
    }
  }

  @override
  void onReady() {
    fetchJobDetails();
    super.onReady();
  }

  Future<void> fetchJobDetails({bool isLoaderShown = false}) async {
    if (jobId == null) return;
    isFetching.value = true;
    fetchError.value = null;
    if (isLoaderShown) Loader.show();
    try {
      final result = await _clientRepository.getJobDetails(jobId!);
      result.handle(
        showAlert: false,
        success: (response) {
          final raw = response.data;
          job.value = raw;
          fetchError.value = null;
          if (raw != null) {
            cleanerHeading.value = 'Cleaners(${raw.jobCleaners?.length.toString()}/${raw.numberOfCleaners.toString()})';
          }
        },
        onError: (NetworkException e) {
          fetchError.value = e.message;
        },
      );
    } finally {
      isFetching.value = false;
      if (isLoaderShown) Loader.hide();
    }
  }

  bool get _canEditJob => job.value?.canEdit ?? job.value?.isEdit ?? false;

  bool get _canCancelJob => job.value?.canCancel ?? true;

  void _showBlockedActionSheet({
    required String title,
    String? reason,
    required String fallback,
  }) {
    final context = Get.context;
    if (context == null) return;
    final trimmed = reason?.trim();
    Notifier.openSheet(
      context,
      type: SheetType.info,
      title: title,
      message: (trimmed != null && trimmed.isNotEmpty) ? trimmed : fallback,
      showSecondaryButton: false,
      primaryButtonLabel: 'Okay',
    );
  }

  void onEdit() {
    if (!_canEditJob) {
      _showBlockedActionSheet(
        title: 'Editing unavailable',
        reason: job.value?.editBlockedReason,
        fallback: 'This job cannot be edited right now. Please contact support.',
      );
      return;
    }
    Get.toNamed(Routes.CLIENT_CREATE_JOB, arguments: job.value)?.then((value) {
      if (value != null) {
        fetchJobDetails();
        bool isControllerRegistered = Get.isRegistered<ClientDashboardController>();
        if (isControllerRegistered) {
          ClientDashboardController ctrl = Get.find();
          ctrl.jobCurrentPage = 1;
          ctrl.fetchJobs(isLoaderShown: false);
        }
      }
    });
  }

  void confirmDeleteJob(BuildContext context) {
    Notifier.openSheet(
      context,
      type: SheetType.error,
      title: 'Delete job?',
      message: 'This will remove this "${job.value?.jobType?.capitalizeFirst ?? "N/A"}" job. This action cannot be undone.',
      primaryButtonLabel: 'Delete',
      secondaryButtonLabel: 'Cancel',
      showPrimaryButton: true,
      showSecondaryButton: true,
      onPrimaryPressed: deleteJob,
      onSecondaryPressed: () {},
    );
  }

  Future<void> deleteJob() async {
    if (jobId == null) return;
    Loader.show();
    try {
      final result = await _clientRepository.deleteJob(jobId!);
      result.handle(
        success: (value) async {
          Loader.hide();
          // Defer sheet to next frame so Loader.hide() from finally can close the loader first
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (Get.context == null) return;
            Notifier.success(value.message ?? "Job deleted Successfully!");
            Get.back(result: {'job_id': jobId, 'action': 'delete'});
          });
        },
        contextTag: 'delete_job',
      );
    } finally {
      Loader.hide();
    }
  }

  void onCancelJob() {
    if (!_canCancelJob) {
      _showBlockedActionSheet(
        title: 'Cancellation unavailable',
        reason: job.value?.cancelBlockedReason,
        fallback: 'This job cannot be cancelled right now. Please contact support.',
      );
      return;
    }
    final jobId = job.value?.id;
    if (jobId == null) {
      Notifier.info('Invalid job');
      return;
    }
    final scheme = (Get.context as BuildContext).colorScheme;
    final msgCtrl = TextEditingController();

    Notifier.openSheet(
      Get.context!,
      title: 'Cancel job?',
      type: SheetType.error,
      message: 'This will cancel this job. You can add a reason below.',
      body: Column(
        spacing: 8,
        children: [
          CommonText.bold('Cancel job?', size: 24, color: scheme.primary, fontWeight: FontWeight.w900).marginOnly(bottom: 8),
          CommonText.regular('This will cancel this job. You can add a reason below.',
              textAlign: TextAlign.center, size: 18, color: scheme.onSurface.withValues(alpha: 0.7)),
          CommonTextField(
            hint: 'Type your reason here...',
            controller: msgCtrl,
            maxLines: 4,
            minLines: 2,
            action: TextInputAction.done,
          ),
        ],
      ).marginSymmetric(vertical: 8),
      showPrimaryButton: true,
      showSecondaryButton: true,
      primaryButtonLabel: 'Cancel job',
      secondaryButtonLabel: 'Keep',
      onPrimaryPressed: () => _cancelJob(jobId, msgCtrl.text),
    );
  }

  Future<void> _cancelJob(num jobId, String msg) async {
    Loader.show();
    try {
      final result = await _clientRepository.cancelJob(jobId: jobId.toInt(), reason: msg);
      result.handle(
        success: (_) {
          Loader.hide();
          Notifier.success('Job cancelled');
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            Get.back();
            bool isControllerRegistered = Get.isRegistered<ClientDashboardController>();
            if (isControllerRegistered) {
              ClientDashboardController ctrl = Get.find();
              ctrl.jobCurrentPage = 1;
              ctrl.fetchJobs();
            }
          });
        },
        contextTag: 'cancel_job',
      );
    } finally {
      Loader.hide();
    }
  }

  /// Navigates to the schedule-job page for a normal (one-off) job.
  void onScheduleJob() {
    Get.toNamed(Routes.CLIENT_SCHEDULE_JOB, arguments: {'job': job.value, 'isEdit': false});
  }

  /// Navigates to the schedule-job page to edit an existing schedule.
  void onEditSchedule() {
    Get.toNamed(Routes.CLIENT_SCHEDULE_JOB, arguments: {'job': job.value, 'isEdit': true});
  }

  Future<void> scheduleJob(ScheduleJobRequest request) async {
    final jobId = job.value?.id?.toInt();
    if (jobId == null) {
      Notifier.info('Invalid job');
      return;
    }
    Loader.show();
    try {
      final result = await _clientRepository.scheduleJob(jobId: jobId, request: request);
      result.handle(
        success: (_) {
          Loader.hide();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (Get.context == null) return;
            fetchJobDetails(isLoaderShown: false);
            Notifier.openSheet(Get.context as BuildContext,
                title: "Success",
                type: SheetType.success,
                message: "Job scheduled for ${CcsDateUtils.fullDate(DateTime.parse(request.startDate ?? ""))}.",
                isDismissable: false,
                isShowCloseIcon: false,
                showSecondaryButton: false, onPrimaryPressed: () {
              Get.back();
            });
          });
        },
        contextTag: 'schedule_job',
      );
    } finally {
      Loader.hide();
    }
  }

  Future<void> updateScheduleJob(num scheduleId, UpdateScheduleJobRequest request) async {
    Loader.show();
    try {
      final result = await _clientRepository.updateScheduleJob(
        scheduleId: scheduleId.toInt(),
        request: request,
      );
      result.handle(
        success: (_) {
          Loader.hide();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (Get.context == null) return;
            fetchJobDetails(isLoaderShown: false);
            Notifier.openSheet(
              Get.context as BuildContext,
              title: 'Success',
              type: SheetType.success,
              message: 'Schedule updated successfully.',
              isDismissable: false,
              isShowCloseIcon: false,
              showSecondaryButton: false,
              onPrimaryPressed: () => Get.back(),
            );
          });
        },
        contextTag: 'update_schedule',
      );
    } finally {
      Loader.hide();
    }
  }

  num? get _scheduleId => job.value?.scheduler?.id ?? job.value?.scheduleId;

  bool get isSchedulePaused => job.value?.scheduler?.active == false;

  String _formatApiDate(DateTime date) => '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  void onPauseSchedule() {
    final scheduleId = _scheduleId;
    if (scheduleId == null) {
      Notifier.info('Schedule not found');
      return;
    }

    final scheme = (Get.context as BuildContext).colorScheme;
    final endDateCtrl = TextEditingController();
    DateTime? pauseEndDate;

    Notifier.openSheet(
      Get.context!,
      title: 'Pause schedule',
      type: SheetType.info,
      message: 'Pause this recurring schedule. Leave the end date empty to pause until you resume manually.',
      body: Column(
        spacing: 12,
        children: [
          CommonTextField(
            controller: endDateCtrl,
            label: 'Pause end date (optional)',
            hint: '-- / -- / ----',
            isReadOnly: true,
            onTap: () async {
              final context = Get.context;
              if (context == null) return;
              final d = await showDatePicker(
                context: context,
                initialDate: pauseEndDate ?? DateTime.now().add(const Duration(days: 7)),
                firstDate: DateTime.now(),
                lastDate: DateTime(2030, 12, 31),
              );
              if (d != null) {
                pauseEndDate = DateTime(d.year, d.month, d.day);
                endDateCtrl.text = CcsDateUtils.forInput(pauseEndDate!);
              }
            },
            suffixIcon: Icon(IconsaxPlusLinear.calendar_1, size: 20, color: scheme.primary),
          ),
          CommonText.regular(
            'If you set an end date, the schedule pauses until that date and then resumes automatically.',
            size: 12,
            color: scheme.onSurfaceVariant,
          ),
        ],
      ).marginSymmetric(vertical: 8),
      showPrimaryButton: true,
      showSecondaryButton: true,
      primaryButtonLabel: 'Pause schedule',
      secondaryButtonLabel: 'Keep running',
      onPrimaryPressed: () {
        final end = pauseEndDate;
        PauseScheduleRequest? request;
        if (end != null) {
          request = PauseScheduleRequest(
            inactiveStartDate: _formatApiDate(DateTime.now()),
            inactiveEndDate: _formatApiDate(end),
          );
        }
        _pauseSchedule(scheduleId, request: request);
      },
    );
  }

  Future<void> _pauseSchedule(num scheduleId, {PauseScheduleRequest? request}) async {
    Loader.show();
    try {
      final result = await _clientRepository.pauseScheduledJob(
        scheduleId: scheduleId.toInt(),
        request: request,
      );
      result.handle(
        success: (value) {
          Loader.hide();
          Notifier.success(value.message ?? 'Schedule paused');
          fetchJobDetails(isLoaderShown: false);
        },
        contextTag: 'pause_schedule',
      );
    } finally {
      Loader.hide();
    }
  }

  Future<void> onResumeSchedule() async {
    final scheduleId = _scheduleId;
    if (scheduleId == null) {
      Notifier.info('Schedule not found');
      return;
    }

    Loader.show();
    try {
      final result = await _clientRepository.resumeScheduledJob(scheduleId: scheduleId.toInt());
      result.handle(
        success: (value) {
          Loader.hide();
          Notifier.success(value.message ?? 'Schedule resumed');
          fetchJobDetails(isLoaderShown: false);
        },
        contextTag: 'resume_schedule',
      );
    } finally {
      Loader.hide();
    }
  }

  void onReviewCleanerProfile(ClientJobCleaner c) {
    clearAddReview();
    jobCleaner.value = c;
    jobCleaner.refresh();
    Get.toNamed(Routes.ADD_REVIEW, arguments: job.value);
  }

  void onViewFile(String url) {
    final invoice = job.value?.invoice;
    Get.toNamed(Routes.CLIENT_INVOICE, arguments: {
      'pdfUrl': url,
      'invoiceNumber': invoice?.invoiceNumber,
      'status': invoice?.status,
    });
  }

  void openFilter(BuildContext context) {
    Notifier.openSheet(context, body: filterJob(context), showIcon: false, showPrimaryButton: false, showSecondaryButton: false);
  }

  Widget filterJob(BuildContext context) {
    final scheme = context.colorScheme;
    hoursController.clear();
    reasonController.clear();

    return Column(
      children: [
        AppCard(
          color: Colors.transparent,
          enableShadows: false,
          child: Row(
            children: [
              AppCard(
                enableShadows: false,
                radius: UiConstants.radiusDefault,
                color: scheme.secondaryContainer.withValues(alpha: 0.7),
                child: Icon(
                  IconsaxPlusLinear.clock_1,
                  size: 20,
                  color: scheme.secondary,
                ).paddingAll(10),
              ).marginOnly(right: UiConstants.gap),
              Expanded(
                child: CommonText.bold('Extend Job Time', size: 18, color: scheme.onSurface),
              ),
            ],
          ),
        ).marginOnly(bottom: 12),

        // Filter card
        AppCard(
          radius: 0,
          enableShadows: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CommonTextField(
                hint: 'Enter Hours',
                controller: hoursController,
                action: TextInputAction.next,
                keyboardType: TextInputType.number,
                maxLength: 1,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              SizedBox(height: UiConstants.gap),
              CommonTextField(
                hint: 'Enter Reason',
                controller: reasonController,
                minLines: 4,
                maxLines: 4,
                action: TextInputAction.next,
              ),
            ],
          ).paddingSymmetric(vertical: 0),
        ).marginOnly(bottom: 18),

        Row(
          children: [
            Expanded(
              child: AppButton(
                type: ButtonType.tonal,
                label: 'Cancel',
                onPressed: () {
                  Get.back();
                },
              ).marginOnly(right: 4),
            ),
            Expanded(
              child: AppButton(
                type: ButtonType.primary,
                label: 'Send Request',
                onPressed: () {
                  submitRequest();
                },
              ).marginOnly(left: 4),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> downloadFile(String url, String? invoiceNumber) async {
    if (url.isEmpty) {
      Notifier.info('File URL is missing');
      return;
    }

    Loader.show();
    File? tempFile;
    try {
      final number = invoiceNumber?.trim();
      final fileName = (number != null && number.isNotEmpty)
          ? (number.toLowerCase().endsWith('.pdf') ? number : '$number.pdf')
          : 'invoice_${DateTime.now().millisecondsSinceEpoch}.pdf';

      final tempPath = '${(await getTemporaryDirectory()).path}/$fileName';
      await Dio().download(url, tempPath);
      tempFile = File(tempPath);

      await DownloadUtils.saveToDownloads(source: tempFile, fileName: fileName);
      Notifier.success(
        Platform.isIOS
            ? 'Open Files → On My iPhone → Colossians Cleaning to view $fileName.'
            : 'Open Files or your Downloads folder to view $fileName.',
        title: 'Invoice downloaded',
      );
    } catch (e) {
      log(runtimeType.toString(), 'Download error: $e');
      Notifier.error('Unable to download invoice');
    } finally {
      try {
        await tempFile?.delete();
      } catch (_) {}
      Loader.hide();
    }
  }

  Future<void> submitReview() async {
    final jobId = job.value?.id?.toInt();
    if (jobId == null) {
      Notifier.info('Invalid job');
      return;
    }

    if (jobCleaner.value == null) {
      Notifier.info('Cleaner information is missing');
      return;
    }

    if (arrive.value == null) {
      Notifier.info('Please confirm if the cleaner arrived on time');
      return;
    }

    if (uniform.value == null) {
      Notifier.info('Please confirm if the cleaner wore a uniform');
      return;
    }

    if (completedJob.value == null) {
      Notifier.info('Please confirm if the job was completed on time');
      return;
    }

    if (requestAgain.value == null) {
      Notifier.info('Please confirm if you would hire the cleaner again');
      return;
    }

    if (rating.value <= 0) {
      Notifier.info('Please provide a rating');
      return;
    }

    Loader.show();
    try {
      final result = await _clientRepository.submitJobReview(
        jobId: jobId,
        cleanerId: jobCleaner.value?.id.toInt() ?? 0,
        arrivedOnTime: arrive.value == UserOptions.yes,
        woreUniform: uniform.value == UserOptions.yes,
        completedOnTime: completedJob.value == UserOptions.yes,
        wouldRehire: requestAgain.value == UserOptions.yes,
        satisfactionRating: rating.value.toInt(),
        message: messageController.text.trim().isNotEmpty ? messageController.text.trim() : null,
      );
      result.handle(
        success: (value) {
          Loader.hide();
          // Defer sheet to next frame so Loader.hide() from finally can close the loader first
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (Get.context == null) return;
            Notifier.openSheet(Get.context as BuildContext,
                title: "Success",
                type: SheetType.success,
                message: "${value.message}",
                isDismissable: false,
                isShowCloseIcon: false,
                showSecondaryButton: false, onPrimaryPressed: () {
              Get.back();
              fetchJobDetails();
            });
          });
        },
        contextTag: 'submit_review',
      );
    } finally {
      Loader.hide();
    }
  }

  Future<void> submitRequest() async {
    final jobId = job.value?.id?.toInt();
    if (jobId == null) {
      Notifier.error('Invalid job');
      return;
    }

    if (hoursController.text.isEmpty) {
      Notifier.error('Please Enter Hours');
      return;
    }

    if (hoursController.text.toInt() > 3) {
      Notifier.error('The hours must not exceed three.');
      return;
    }

    if (reasonController.text.isEmpty) {
      Notifier.error('Please enter the reason for hour extension');
      return;
    }
    (Get.context as BuildContext).hideKeyboard();
    Get.back();

    Loader.show();
    try {
      final result = await _clientRepository.extensionRequest(jobId: jobId, requestedHours: hoursController.text.toInt(), reason: reasonController.text);
      result.handle(
        success: (value) {
          Loader.hide();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            fetchJobDetails(isLoaderShown: true);
          });
        },
        contextTag: 'submit_review',
      );
    } finally {
      Get.back();
      Loader.hide();
    }
  }

  void clearAddReview() {
    arrive.value = null;
    uniform.value = null;
    completedJob.value = null;
    requestAgain.value = null;
    rating.value = 0;
    messageController.clear();
  }
}
