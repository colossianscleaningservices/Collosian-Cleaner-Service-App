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

  /// Shows error toast and, when [NetworkException.requiresLogout] is true (e.g. 401)
  /// and the user is currently logged in, logs out and navigates to login once.
  static Future<void> apiError(Object error, {String? contextTag}) async {
    final ex = error is NetworkException ? error : NetworkException.fromDio(error);
    final session = Get.find<SessionService>();

    if (ex.requiresLogout) {
      if (session.shouldIgnoreUnauthorized(contextTag: contextTag)) return;

      if (!session.isLoggedIn) {
        _show(title: ex.displayTitle, message: ex.message, type: ToastificationType.error);
        if (Get.currentRoute != Routes.LOGIN) {
          Get.offAllNamed(Routes.LOGIN);
        }
        return;
      }

      if (!session.beginLogout()) return;
      toastification.dismissAll();
      _show(title: ex.displayTitle, message: ex.message, type: ToastificationType.error);
      await session.logout(notifyServer: false);
      return;
    }

    _show(title: ex.displayTitle, message: ex.message, type: ToastificationType.error);
  }

  static void openSheet(BuildContext context,
      {String title = "Alert!",
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
      bool showIcon = true,
      bool isShowCloseIcon = true,
      void Function()? onPrimaryPressed,
      void Function()? onSecondaryPressed,
      bool top = false,
      bool isSheetAutoClose = true,
      /// When true with [body], sheet fills available height (lists / PDF).
      /// When false (default), sheet wraps content height (time pickers, filters).
      bool expandBody = false,
      TextAlign msgAlign = TextAlign.center}) {
    final scheme = context.colorScheme;

    Color bg;
    Color fg;

    switch (type) {
      case SheetType.success:
        bg = Colors.green.shade100;
        fg = Colors.green.shade400;
        break;
      case SheetType.error:
        bg = scheme.errorContainer;
        fg = scheme.error;
        break;
      case SheetType.info:
        bg = scheme.primaryContainer;
        fg = scheme.primary;
        break;
      case SheetType.warning:
        bg = Colors.yellow.shade100.withValues(alpha: 0.6);
        fg = Colors.yellow.shade800;
        break;
      case null:
        bg = scheme.primaryContainer;
        fg = scheme.primary;
    }

    void closeSheet() {
      if (Get.isBottomSheetOpen ?? false) {
        Get.back();
      }
    }

    Widget buildHeader() {
      return Row(
        children: [
          Assets.imagesAppLogo.image(width: 120),
          const Spacer(),
          if (isShowCloseIcon)
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(IconsaxPlusLinear.close_circle),
                onPressed: closeSheet,
                style: filledIconButtonStyle(context),
              ),
            ),
        ],
      );
    }

    Widget? buildIcon() {
      if (!showIcon) return null;
      return AppCard(
        enableShadows: false,
        color: bg,
        radius: 100,
        child: iconWidget ??
            Icon(
              icon ?? IconsaxPlusLinear.check,
              size: 56,
              color: fg,
            ).marginAll(16),
      ).marginOnly(top: 16);
    }

    Widget? buildButtons() {
      if (!showPrimaryButton && !showSecondaryButton) return null;
      return Column(
        spacing: 16,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showPrimaryButton)
            SizedBox(
              width: double.infinity,
              child: AppButton(
                type: ButtonType.primary,
                label: primaryButtonLabel,
                txtClr: bg,
                bgColor: fg,
                onPressed: onPrimaryPressed != null
                    ? () {
                        if (isSheetAutoClose) closeSheet();
                        onPrimaryPressed.call();
                      }
                    : closeSheet,
              ),
            ),
          if (showSecondaryButton)
            SizedBox(
              width: double.infinity,
              child: AppButton(
                type: ButtonType.tonal,
                txtClr: fg,
                bgColor: bg,
                label: secondaryButtonLabel,
                onPressed: onSecondaryPressed != null
                    ? () {
                        closeSheet();
                        onSecondaryPressed.call();
                      }
                    : closeSheet,
              ),
            ),
        ],
      );
    }

    // Alerts / content body: shrink-wrap (+ scroll if tall).
    // expandBody: fill height so inner ListView/PDF get a real viewport (keyboard-safe).
    final content = SafeArea(
      top: top,
      bottom: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final available = constraints.maxHeight.isFinite
              ? constraints.maxHeight
              : MediaQuery.sizeOf(context).height;
          // Outer vertical margin 24*2.
          final maxHeight = (available - 48).clamp(120.0, available);

          final header = buildHeader();
          final iconWidgetBuilt = buildIcon();
          final buttons = buildButtons();
          final useExpand = body != null && expandBody;

          final Widget sheetChild;
          if (useExpand) {
            sheetChild = Padding(
              padding: const EdgeInsets.only(left: 24, right: 18, bottom: 18, top: 12),
              child: Column(
                children: [
                  header,
                  if (iconWidgetBuilt != null) ...[
                    const SizedBox(height: 16),
                    iconWidgetBuilt,
                  ],
                  const SizedBox(height: 16),
                  Expanded(child: body),
                  if (buttons != null) ...[
                    const SizedBox(height: 16),
                    buttons,
                  ],
                ],
              ),
            );
          } else {
            sheetChild = SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(left: 24, right: 18, bottom: 18, top: 12),
                child: Column(
                  spacing: 16,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    header,
                    if (iconWidgetBuilt != null) iconWidgetBuilt,
                    if (body == null)
                      Column(
                        spacing: 8,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CommonText.bold(
                            title,
                            size: 24,
                            color: scheme.primary,
                            fontWeight: FontWeight.w900,
                            textAlign: TextAlign.center,
                          ),
                          if (message != null)
                            CommonText.regular(
                              message,
                              textAlign: msgAlign,
                              size: 18,
                              color: scheme.onSurface.withValues(alpha: 0.7),
                            ),
                        ],
                      ).marginSymmetric(vertical: 16),
                    if (body != null) body,
                    if (buttons != null) buttons,
                  ],
                ),
              ),
            );
          }

          return AppCard(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: maxHeight,
                minHeight: useExpand ? maxHeight : 0,
              ),
              child: sheetChild,
            ),
          ).marginSymmetric(horizontal: 18, vertical: 24);
        },
      ),
    );

    Get.bottomSheet(
      content,
      isDismissible: isDismissable,
      persistent: false,
      enterBottomSheetDuration: const Duration(milliseconds: 250),
      isScrollControlled: true,
      ignoreSafeArea: false,
    );
  }

  static void _show({required String title, required String message, required ToastificationType type}) {
    toastification.show(
      type: type,
      style: ToastificationStyle.flatColored,
      alignment: Alignment.topCenter,
      autoCloseDuration: _duration,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: CommonText.medium(title),
      description: CommonText.regular(message),
      closeButton: const ToastCloseButton(showType: CloseButtonShowType.none),
      borderSide: BorderSide(color: Colors.transparent),
      dismissDirection: DismissDirection.vertical,
    );
  }
}

enum SheetType { success, error, info, warning }
