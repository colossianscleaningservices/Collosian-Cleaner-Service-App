import 'package:toastification/toastification.dart';

import '../../export.dart';
import '../gen/assets.gen.dart';
import '../services/session_service.dart';

class Notifier {
  Notifier._();

  static const _duration = Duration(seconds: 3);

  static void success(String message, {String title = 'Success'}) => _show(title: title, message: message, type: ToastificationType.success);

  static void info(String message, {String title = 'Info'}) => _show(title: title, message: message, type: ToastificationType.info);

  static void error(String message, {String title = 'Error'}) => _show(title: title, message: message, type: ToastificationType.error);

  static Future<void> apiError(Object error, {String? contextTag}) async {
    final ex = error is NetworkException ? error : NetworkException.fromDio(error);
    _show(title: ex.title, message: ex.message, type: ToastificationType.error);

    if (ex.requiresLogout) {
      await Get.find<SessionService>().logout();
    }
  }

  static void openSheet(BuildContext context, {
    String title = "Alert!",
    String? message,
    Widget? iconWidget,
    Widget? body,
    IconData? icon,
    SheetType? type = SheetType.info,
    String primaryButtonLabel = "Confirm",
    String secondaryButtonLabel = "Cancel",
    bool isDismissable = true,
    bool showPrimaryButton = true,
    bool showSecondaryButton = true,
    void Function()? onPrimaryPressed,
    void Function()? onSecondaryPressed,
  }) {
    var scheme = context.colorScheme;

    Color bg;
    Color fg;

    switch (type) {
      case SheetType.success:
        bg = Colors.green.shade100.withValues(alpha: 0.4);  // Background color for success
        fg = Colors.green.shade400;  // Foreground color (text) for success
        break;
      case SheetType.error:
        bg = scheme.errorContainer;   // Background color for info
        fg = scheme.error;   // Foreground color (text) for info
        break;
      case SheetType.info:
        bg = scheme.secondaryContainer;   // Background color for info
        fg = scheme.secondary;   // Foreground color (text) for info
        break;
      case SheetType.warning:
        bg = Colors.yellow.shade100.withValues(alpha: 0.6); // Background color for warning
        fg = Colors.yellow.shade800; // Foreground color (text) for warning
        break;
      case null:
        bg = scheme.secondaryContainer;   // Background color for info
        fg = scheme.secondary;   // Foreground color (text) for info
    }

    void closeSheet() {
      if (Get.isBottomSheetOpen ?? false) {
        Get.back();
      }
    }

    var content = SafeArea(
      top: false,
      child: AppCard(
        child: Column(
          spacing: 16,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Assets.imagesAppLogo.image(width: 120,),
                Spacer(),
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(icon: const Icon(Icons.close), onPressed: closeSheet, style: filledIconButtonStyle(context)),
                ),
              ],
            ),

            AppCard(
              enableShadows: false,
              color: bg,
              radius: 100,
              child: iconWidget ?? Icon(icon ?? IconsaxPlusLinear.check, size: 56, color: fg,).marginAll(16),
            ).marginOnly(top: 16),

            if (body == null)
              Column(
                spacing: 8,
                children: [
                  CommonText.bold(title, size: 24, color: scheme.primary, fontWeight: FontWeight.w900),
                  if (message != null)
                    CommonText.regular(message, textAlign: TextAlign.center, size: 18, color: scheme.onSurface.withValues(alpha: 0.7)),
                ],
              ).marginSymmetric(vertical: 16),

            if (body != null) body,

            /// Buttons
            if (showPrimaryButton || showSecondaryButton)
              Column(
                spacing: 16,
                children: [
                  if (showPrimaryButton)
                    SizedBox(
                      width: double.infinity,
                      child: AppButton(
                        type: ButtonType.primary,
                        label: primaryButtonLabel,
                        onPressed: onPrimaryPressed != null
                            ? () {
                          closeSheet();
                          onPrimaryPressed.call();
                        }
                            : () => closeSheet(),
                      ),
                    ),
                  if (showSecondaryButton)
                    SizedBox(
                      width: double.infinity,
                      child: AppButton(
                        type: ButtonType.tonal,
                        label: secondaryButtonLabel,
                        onPressed: onSecondaryPressed != null
                            ? () {
                          closeSheet();
                          onSecondaryPressed.call();
                        }
                            : () => closeSheet(),
                      ),
                    ),
                ],
              ).marginOnly(right: 8),
          ],
        ).paddingOnly(left: 24, right: 18, bottom: 18, top: 12),
      ).marginSymmetric(horizontal: 18, vertical: 24),
    );

    Get.bottomSheet(content, isDismissible: isDismissable, enterBottomSheetDuration: Duration(milliseconds: 250), isScrollControlled: true);
  }

  static void _show({required String title, required String message, required ToastificationType type}) {
    toastification.show(
      type: type,
      style: ToastificationStyle.flat,
      alignment: Alignment.topCenter,
      autoCloseDuration: _duration,
      margin: const EdgeInsets.symmetric(horizontal: 16,vertical: 8),
      title: Text(title),
      description: Text(message),
      closeButton: const ToastCloseButton(showType: CloseButtonShowType.none),
    );
  }
}

enum SheetType { success, error, info, warning }