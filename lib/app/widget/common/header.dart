import 'package:ccs_app/export.dart';

/// A customizable header widget for the application, typically used as an AppBar.
class Header extends StatelessWidget implements PreferredSizeWidget {
  const Header({
    required this.title,
    this.onBackTap,
    this.bottom,
    this.hasBackIcon = true,
    this.headerLogoIcon = true,
    this.titleCentered = false,
    this.actions,
    this.leadingIcon,
    this.bgColor,
    this.underlineOpacity = 1,
    this.size = 22,
    super.key,
    this.mStyle,
    this.lessonImage,
    this.widget,
    this.profileImage = '',
    this.subtitle = '',
  });

  final String title;
  final String? subtitle;
  final Image? lessonImage;
  final VoidCallback? onBackTap;
  final PreferredSizeWidget? bottom;
  final bool hasBackIcon;
  final bool headerLogoIcon;
  final bool titleCentered;
  final List<Widget>? actions;
  final String? leadingIcon;
  final Color? bgColor;
  final double size;
  final double? underlineOpacity;
  final SystemUiOverlayStyle? mStyle;
  final Widget? widget;
  final String profileImage;

  @override
  Widget build(BuildContext context) => AppBar(
    toolbarHeight: 68,
    actionsIconTheme: IconThemeData(color: context.colorScheme.primary),
    backgroundColor: bgColor ?? Get.context?.colorScheme.surface,
    automaticallyImplyLeading: hasBackIcon,
    leading: hasBackIcon
        ? IconButton(
            style: filledIconButtonStyle(context),
            onPressed: onBackTap ?? () => Get.back(),
            icon: const Icon(IconsaxPlusLinear.arrow_left_1),
          ).paddingOnly(left: 12, top: 8, bottom: 8)
        : null,
    title: Column(
      spacing: 4,
      crossAxisAlignment: .start,
      children: [
        CommonText.extraBold(title, color: context.colorScheme.primary, fontWeight: FontWeight.w700, size: size),
        subtitle != null
            ? CommonText.regular(subtitle!, color: context.colorScheme.primary, fontWeight: FontWeight.w400, size: 16)
            : const SizedBox(),
      ],
    ),
    centerTitle: false,
    actions: _buildActions(context),
    scrolledUnderElevation: 0,
  );

  List<Widget>? _buildActions(BuildContext context) {
    if (actions?.isEmpty ?? true) return actions;
    return actions!
        .map(
          (action) => switch (action) {
            SizedBox _ => action,
            final IconButton button => IconButton(
              key: button.key,
              onPressed: button.onPressed,
              onHover: button.onHover,
              onLongPress: button.onLongPress,
              tooltip: button.tooltip,
              icon: button.icon,
              selectedIcon: button.selectedIcon,
              isSelected: button.isSelected,
              style: filledIconButtonStyle(context).merge(button.style),
              iconSize: button.iconSize,
              visualDensity: button.visualDensity,
              padding: button.padding,
              alignment: button.alignment,
              splashRadius: button.splashRadius,
              color: button.color,
              focusColor: button.focusColor,
              hoverColor: button.hoverColor,
              highlightColor: button.highlightColor,
              splashColor: button.splashColor,
              disabledColor: button.disabledColor,
              mouseCursor: button.mouseCursor,
              focusNode: button.focusNode,
              autofocus: button.autofocus,
              enableFeedback: button.enableFeedback,
              constraints: button.constraints,
            ).paddingOnly(right: 12, top: 8, bottom: 8),
            _ => action.paddingOnly(right: 12, top: 8, bottom: 8),
          },
        )
        .toList();
  }

  @override
  Size get preferredSize => Size.fromHeight(56 + (bottom?.preferredSize.height ?? 0) + ((widget == null) ? 0 : 16));
}
