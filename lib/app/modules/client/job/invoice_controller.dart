import 'dart:io';

import 'package:ccs_app/app/utils/download_utils.dart';
import 'package:ccs_app/export.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class InvoiceController extends GetxController {
  final pdfViewerKey = GlobalKey<SfPdfViewerState>();
  final pdfController = PdfViewerController();

  static const _defaultZoom = 1.0;

  String pdfUrl = '';
  String invoiceNumber = 'Invoice';
  String? status;

  bool get isPdfZoomed => pdfController.zoomLevel > _defaultZoom;

  /// Zooms the PDF back out if it is zoomed in; otherwise leaves the screen.
  void onBack() {
    if (isPdfZoomed) {
      pdfController.zoomLevel = _defaultZoom;
      return;
    }
    Get.back();
  }

  @override
  void onClose() {
    pdfController.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      pdfUrl = (args['pdfUrl'] as String?)?.trim() ?? '';
      final number = (args['invoiceNumber'] as String?)?.trim();
      invoiceNumber = (number != null && number.isNotEmpty) ? number : 'Invoice';
      status = args['status'] as String?;
    }
  }

  Future<void> downloadFile() async {
    if (pdfUrl.isEmpty) {
      Notifier.info('File URL is missing');
      return;
    }

    Loader.show();
    File? tempFile;
    try {
      final number = invoiceNumber.trim();
      final fileName = number.toLowerCase().endsWith('.pdf')
          ? number
          : number == 'Invoice'
              ? 'invoice_${DateTime.now().millisecondsSinceEpoch}.pdf'
              : '$number.pdf';

      final tempPath = '${(await getTemporaryDirectory()).path}/$fileName';
      await Dio().download(pdfUrl, tempPath);
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
}
