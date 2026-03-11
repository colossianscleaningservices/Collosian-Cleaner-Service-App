import 'dart:async';
import 'dart:io';

import 'package:ccs_app/app/network/repository/cleaner_repository.dart';
import 'package:ccs_app/app/network/response/get_staff_document_response.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:dio/dio.dart' as dio;

import '../../../../export.dart';
import 'package:path/path.dart' as path;

class SupportDocumentController extends GetxController {
  final CleanerRepository _cleanerRepository = CleanerRepository();

  final count = 0.obs;
  final document = Rxn<String>();
  final documentCtrl = TextEditingController();
  final jobStartDate = Rxn<DateTime>();
  final selectedDocument = Rxn<Documents>();

  List<String> documentTypeOptions = ['Passport', 'Visa', 'Driver License', 'Address Proof', 'Crb Check', 'Work Permit', 'Other'];

  RxList<File> pickedFiles = <File>[].obs;

  /// List of documents shown on the support document screen. Populate via API in loadDocuments.
  final RxList<Documents> documents = <Documents>[].obs;

  var isPdfLoading = false.obs;

  var isEditingDocument = false.obs;

  void setJobStartDate(DateTime? d) => jobStartDate.value = d;

  void increment() => count.value++;
  final picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
  }

  /// Pull-to-refresh callback.
  Future<void> refreshDocuments() => geCleanerDocuments();

  /// Returns icon for document type for list display.
  IconData iconForDocumentType(String type) {
    switch (type.toLowerCase()) {
      case 'passport':
        return Icons.badge_outlined;
      case 'visa':
        return Icons.card_travel_outlined;
      case 'driver license':
        return Icons.directions_car_outlined;
      case 'address proof':
        return Icons.home_outlined;
      default:
        return Icons.description_outlined;
    }
  }

  Future<void> onViewFile(Documents item) async {
    if (item.documentUrl!.endsWith('.pdf')) {
      final GlobalKey<SfPdfViewerState> pdfViewerKey = GlobalKey();
      Notifier.openSheet(Get.context as BuildContext,
          showIcon: false,
          showPrimaryButton: false,
          showSecondaryButton: false,
          body: Expanded(
            child: SfPdfViewer.network(
              item.documentUrl ?? '',
              key: pdfViewerKey,
              password: "1234",
            ),
          ));
    } else {
      var multiImageProvider = MultiImageProvider(
        [
          NetworkImage(item.documentUrl.toString()),
        ],
        initialIndex: 0,
      );
      showImageViewerPager(
        Get.context!,
        useSafeArea: true,
        multiImageProvider,
        swipeDismissible: true,
        backgroundColor: Get.context!.colorScheme.surface,
        closeButtonColor: Get.context!.colorScheme.secondary,
        doubleTapZoomable: true,
      );
    }

    /*if (item.fileUrl != null && item.fileUrl!.isNotEmpty) {
      // TODO: Open file (e.g. url_launcher or file viewer)
    } else {
      Notifier.info('No file attached');
    }*/
  }

  void onEditDocument(Documents item) {
    setEditingData(item);

    Get.toNamed(Routes.ADD_DOCUMENT)?.then((result) {
      if (result == true) refreshDocuments();
    });
  }

  void onDeleteDocument(Documents item) {
    confirmDeleteJob(Get.context!, item.id?.toInt() ?? 0);
  }

  @override
  void onReady() {
    super.onReady();
    geCleanerDocuments();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void setEditingData(Documents item) {
    log('tag', item.documentUrl?.split('/').last ?? '');
    isEditingDocument.value = true;

    selectedDocument.value = item;

    document.value = item.documentName?.replaceAll('_', ' ').capitalize;

    documentCtrl.text = item.documentNumber!;

    jobStartDate.value = DateTime.parse(item.expiryDate!);

    refresh();
  }

  void clearData() {
    isEditingDocument.value = false;
    pickedFiles.clear();
    document.value = null;
    documentCtrl.text = '';
    jobStartDate.value = null;
  }

  Future<void> getFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      pickedFiles.clear();
      PlatformFile file = result.files.first;
      pickedFiles.add(File(file.path.toString()));
    } else {
      // User canceled the picker
    }
  }

  // Function to pick an image from the camera
  Future<void> getImageFromCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      pickedFiles.clear();
      pickedFiles.add(File(pickedFile.path.toString()));
    }
  }

  // Returns an icon based on the file extension
  IconData getIcon(String file) {
    var last = file.split(".").last;
    switch (last) {
      case "pdf":
        return Icons.file_copy_outlined;
      case "jpg" || "png" || "jpeg":
        return Icons.image;
      case "mp4":
        return Icons.movie_creation_outlined;
      case "txt":
        return Icons.text_snippet_outlined;
      case "csv":
        return Icons.text_snippet;
      default:
        return Icons.folder_open_outlined;
    }
  }

// Shows a bottom sheet to pick a file from the file manager or camera.
  void showFilePicker({required VoidCallback? filePicker, VoidCallback? cameraPicker}) {
    var context = Get.context as BuildContext;
    showModalBottomSheet(
      context: context,
      clipBehavior: Clip.hardEdge,
      useSafeArea: true,
      useRootNavigator: true,
      backgroundColor: Get.context?.colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16))),
      builder: (builder) {
        return SafeArea(
          child: Wrap(children: [
            Container(
              color: Get.context?.colorScheme.surface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                      child: CommonText.extraBold(
                    "Choose Files",
                    size: context.isTablet ? 22 : 18,
                    color: Get.context?.colorScheme.secondary,
                  ).paddingAll(16)),
                  AppButton(onPressed: filePicker, label: "File Manager").paddingSymmetric(horizontal: 16),
                  if (kIsWeb == false)
                    SizedBox(
                      height: context.isTablet ? 16 : 12,
                    ),
                  if (kIsWeb == false) AppButton(onPressed: cameraPicker, label: "Camera").paddingSymmetric(horizontal: 16),
                  SizedBox(
                    height: context.isTablet ? 16 : 12,
                  ),
                  AppButton(
                    onPressed: () => Get.back(),
                    label: "CANCEL",
                    type: ButtonType.outline,
                  ).paddingSymmetric(horizontal: 16),
                ],
              ).paddingOnly(left: 32, right: 32, bottom: 8),
            ).paddingOnly(bottom: 16),
          ]),
        );
      },
    );
  }

  Future<void> addDocument() async {
    Get.context!.hideKeyboard();
    if (document.value == null) {
      Notifier.info('Please select the document.');
      return;
    }
    if (documentCtrl.text.trim().isEmpty) {
      Notifier.info('Document number is required.');
      return;
    }

    if (jobStartDate.value == null) {
      Notifier.info('Expiry date is required.');
      return;
    }

    if (!isEditingDocument.value && pickedFiles.isEmpty) {
      Notifier.info('Please select document.');
      return;
    }

    Loader.show();
    final data = <String, dynamic>{};

    if (pickedFiles.isNotEmpty) {
      final filePath = pickedFiles.first.path;

// get extension (.jpg, .png, .pdf etc)
      final extension = path.extension(filePath);

      var partFile = await dio.MultipartFile.fromFile(
        filePath,
        filename: "file_${DateTime.now().millisecondsSinceEpoch}$extension",
      );

      data["file"] = partFile;
    }

    data["document_name"] = document.value?.toLowerCase().replaceAll(' ', '_');
    // if(otherDocumentName != null) data["other_document_name"] = otherDocumentName;
    data["document_number"] = documentCtrl.text;
    data["expiry_date"] = jobStartDate.value?.toDisplayDate('yyyy-MM-dd');

    isEditingDocument.value ? updateDocument(data) : uploadDocument(data);
  }

  Future<void> uploadDocument(Map<String, dynamic> data) async {
    var result = await _cleanerRepository.uploadStaffDocument(data);

    result.handle(
      success: (value) {
        Loader.hide();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (Get.context == null) return;
          Notifier.openSheet(Get.context as BuildContext,
              title: "Success", message: "${value.message}", isDismissable: false, isShowCloseIcon: false, showSecondaryButton: false, onPrimaryPressed: () {
            Get.back(result: {'isUpdate': true});
          });
        });
        clearData();
        geCleanerDocuments();
      },
      onError: (_) {
        Loader.hide();
      },
      contextTag: 'media-upload',
    );
  }

  Future<void> updateDocument(Map<String, dynamic> data) async {
    var result = await _cleanerRepository.updateStaffDocument(selectedDocument.value?.id?.toInt() ?? 0, data);

    result.handle(
      success: (value) {
        Loader.hide();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (Get.context == null) return;
          Notifier.openSheet(Get.context as BuildContext,
              title: "Success", message: "${value.message}", isDismissable: false, isShowCloseIcon: false, showSecondaryButton: false, onPrimaryPressed: () {
            Get.back(result: {'isUpdate': true});
          });
        });
        clearData();
        geCleanerDocuments();
      },
      onError: (_) {
        Loader.hide();
      },
      contextTag: 'media-upload',
    );
  }

  Future<void> geCleanerDocuments() async {
    Loader.show();
    try {
      final result = await _cleanerRepository.getDocuments();
      result.handle(
        success: (response) {
          Loader.hide();
          documents.clear();
          response.data?.documents?.forEach((item) {
            documents.add(item);
          });

          documents.refresh();
        },
      );
    } finally {
      Loader.hide();
    }
  }

  Future<void> deleteDocument(int id) async {
    Loader.show();
    try {
      final result = await _cleanerRepository.deleteStaffDocument(id);
      result.handle(
        success: (response) {
          geCleanerDocuments();
        },
      );
    } finally {
      Loader.hide();
    }
  }

  void confirmDeleteJob(BuildContext context, int id) {
    Notifier.openSheet(
      context,
      type: SheetType.error,
      title: 'Delete Document?',
      message: 'Are you sure you want to delete this document',
      primaryButtonLabel: 'Yes',
      secondaryButtonLabel: 'No',
      showPrimaryButton: true,
      showSecondaryButton: true,
      onPrimaryPressed: () {
        deleteDocument(id);
      },
      onSecondaryPressed: () {},
    );
  }
}
