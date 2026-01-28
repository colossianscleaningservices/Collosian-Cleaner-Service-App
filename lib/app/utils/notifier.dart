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

  static void openSheet(
      BuildContext context, {
        String title = "Alert!",
        String? message,
        Widget? iconWidget,
        Widget? body,
        SvgGenImage icon = Assets.imagesAppLogo,
        String primaryButtonLabel = "Confirm",
        String secondaryButtonLabel = "Cancel",
        bool isDismissable = true,
        bool showPrimaryButton = true,
        bool showSecondaryButton = true,
        void Function()? onPrimaryPressed,
        void Function()? onSecondaryPressed,
      }) {
    void closeSheet() {
      if (Get.isBottomSheetOpen ?? false) {
        Get.back();
      }
    }

    var scheme = context.colorScheme;

    var content = SafeArea(
      top: false,
      child: AppCard(
        child: Column(
          spacing: 16,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                iconWidget ?? icon.svg(width: 120, colorFilter: ColorFilter.mode(scheme.secondary, BlendMode.srcATop)),
                Spacer(),
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(icon: const Icon(Icons.close), onPressed: closeSheet, style: filledIconButtonStyle(context)),
                ),
              ],
            ),

            AppCard(color: scheme.outline, radius: 100, child: Icon(IconsaxPlusLinear.check, size: 48).marginAll(16)).marginSymmetric(vertical: 16),

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
      margin: const EdgeInsets.symmetric(horizontal: 16),
      title: Text(title),
      description: Text(message),
      closeButton: const ToastCloseButton(showType: CloseButtonShowType.none),
    );
  }
}
