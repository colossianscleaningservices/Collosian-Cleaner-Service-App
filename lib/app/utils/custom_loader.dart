import '../../export.dart';

class Loader {
  static bool _isLoading = false;

  static void show() {
    if (_isLoading || (Get.isDialogOpen == true)) return;
    _isLoading = true;

    try {
      Get.dialog(
        name: 'loader_dialog',
        barrierDismissible: false,
        Dialog(
          insetPadding: EdgeInsets.zero,
          child: Container(
            constraints: const BoxConstraints(maxHeight: 74, maxWidth: 74),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Get.context?.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(child: CircularProgressIndicator.adaptive()),
          ),
        ),
      );
    } catch (_) {
      _isLoading = false;
    }
  }

  static void hide() {
    if (!_isLoading && Get.isDialogOpen != true) return;
    _isLoading = false;

    if (Get.isDialogOpen == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          if (Get.isDialogOpen == true) Get.back();
        } catch (_) {}
      });
    }
  }
}

