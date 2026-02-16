import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../../../export.dart';
import '../../../model/support_document_item.dart';

class SupportDocumentController extends GetxController {

  final count = 0.obs;
  final document = Rxn<String>();
  final documentCtrl = TextEditingController();
  final jobStartDate = Rxn<DateTime>();
  List<String> documentTypeOptions = ['Passport', 'Visa', 'Driver License', 'Address Proof', 'Other'];

  RxList<File> pickedFiles = <File>[].obs;
  final isSaving = false.obs;

  /// List of documents shown on the support document screen. Populate via API in loadDocuments.
  final RxList<SupportDocumentItem> documents = <SupportDocumentItem>[].obs;

  /// Whether the document list is currently loading.
  final isLoadingDocuments = false.obs;
  var isPdfLoading = false.obs;

  void setJobStartDate(DateTime? d) => jobStartDate.value = d;

  void increment() => count.value++;
  final picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    loadDocuments();
  }

  /// Loads documents (e.g. from API). Replace with real API call.
  Future<void> loadDocuments() async {
    isLoadingDocuments.value = true;
    try {
      // TODO: Replace with API call

      documents.clear();

      await Future.delayed(const Duration(milliseconds: 400));

      documents.add(SupportDocumentItem(type: 'Passport', number: '123456', expiry: DateTime.now()));
      documents.add(SupportDocumentItem(type: 'Visa', number: '12345689', expiry: DateTime.now()));
    } finally {
      isLoadingDocuments.value = false;
    }
  }

  /// Pull-to-refresh callback.
  Future<void> refreshDocuments() => loadDocuments();

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

  Future<void> onViewFile(SupportDocumentItem item) async {
    final GlobalKey<SfPdfViewerState> pdfViewerKey = GlobalKey();
    Notifier.openSheet(Get.context as BuildContext,
        showIcon: false,
        showPrimaryButton: false,
        showSecondaryButton: false,
        body: Expanded(
          child: SfPdfViewer.network(
            'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf',
            key: pdfViewerKey,
            password: "1234",
          ),
        ));

    /*if (item.fileUrl != null && item.fileUrl!.isNotEmpty) {
      // TODO: Open file (e.g. url_launcher or file viewer)
    } else {
      Notifier.info('No file attached');
    }*/
  }

  void onEditDocument(SupportDocumentItem item) {
    // TODO: Navigate to edit screen or open bottom sheet
  }

  void onDeleteDocument(SupportDocumentItem item) {
    // TODO: Confirm and call API to delete, then loadDocuments()
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  // Function to pick files using FilePicker
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

    isSaving.value = true;

    try {
      // TODO: Call API to update profile
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      Notifier.info('Document updated successfully');
      Get.back(result: true);
    } catch (e) {
      Notifier.info('Failed to update profile: $e');
    } finally {
      isSaving.value = false;
    }
  }
}
