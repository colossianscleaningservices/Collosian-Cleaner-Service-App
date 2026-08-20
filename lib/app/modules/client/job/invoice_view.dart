import 'package:ccs_app/app/widget/layout/app_scaffold.dart';
import 'package:ccs_app/export.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import 'invoice_controller.dart';

class InvoiceView extends GetView<InvoiceController> {
  const InvoiceView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final c = controller;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) c.onBack();
      },
      child: AppScaffold(
        appBar: Header(
          title: c.invoiceNumber,
          headerLogoIcon: false,
          hasBackIcon: true,
          titleCentered: false,
          onBackTap: c.onBack,
          actions: [
            IconButton(
              tooltip: 'Download invoice',
              onPressed: c.pdfUrl.isEmpty ? null : c.downloadFile,
              icon: Icon(IconsaxPlusLinear.arrow_down_2, color: scheme.primary),
            ),
          ],
        ),
        backgroundColor: scheme.surface,
        body: SafeArea(
          child: c.pdfUrl.isEmpty
              ? Center(
                  child: Padding(
                    padding: UiConstants.padding,
                    child: CommonText.regular(
                      'This invoice could not be opened.',
                      size: 15,
                      color: scheme.onSurfaceVariant,
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : SfPdfViewer.network(
                  c.pdfUrl,
                  key: c.pdfViewerKey,
                  controller: c.pdfController,
                  password: '1234',
                ),
        ),
      ),
    );
  }
}
