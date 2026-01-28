import 'package:ccs_app/app/model/menu_model.dart';
import 'package:ccs_app/export.dart';

class AppCard extends StatefulWidget {
  const AppCard({
    required this.child,
    super.key,
    this.onTap,
    this.radius = UiConstants.radiusLarge,
    this.color,
    this.offset,
    this.boxBorder,
    this.shadowColor,
    this.borderColor,
    this.borderRadius,
    this.borderWidth = 0,
    this.shadowOpacity = 0.0,
    this.elevation = 0,
    this.enableHover = true,
    this.enableScale = true,
    this.enableShadows = true,
    this.blurRadius,
    this.margin,
    this.padding,
    this.gradient,
  });

  final Widget child;
  final double? radius;
  final double? borderWidth;
  final VoidCallback? onTap;
  final Color? color;
  final Color? shadowColor;
  final Color? borderColor;
  final double shadowOpacity;
  final double elevation;
  final bool enableHover;
  final bool enableScale;
  final BoxBorder? boxBorder;
  final Offset? offset;
  final BorderRadiusGeometry? borderRadius;
  final bool enableShadows;
  final double? blurRadius;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final Gradient? gradient;

  /// Factory constructor for stat card style
  factory AppCard.statCard({
    required Widget child,
    required BuildContext context,
    EdgeInsets? padding,
    Color? backgroundColor,
    VoidCallback? onTap,
  }) {
    final colorScheme = context.colorScheme;
    return AppCard(
      onTap: onTap,
      radius: UiConstants.radiusDefault,
      color: backgroundColor ?? colorScheme.surface.withValues(alpha: 0.5),
      borderWidth: 1,
      borderColor: colorScheme.outline.withValues(alpha: 0.1),
      padding: padding ?? const EdgeInsets.all(16),
      enableShadows: false,
      child: child,
    );
  }

  /// Factory constructor for summary card with gradient
  factory AppCard.summary({
    required Widget child,
    required BuildContext context,
    EdgeInsets? padding,
    EdgeInsets? margin,
    VoidCallback? onTap,
  }) {
    final colorScheme = context.colorScheme;
    return AppCard(
      onTap: onTap,
      radius: UiConstants.radiusLarge,
      gradient: LinearGradient(
        colors: [
          colorScheme.surfaceContainerHighest,
          colorScheme.surfaceContainerHighest.withValues(alpha: 0.8),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderWidth: 1,
      borderColor: colorScheme.outline.withValues(alpha: 0.1),
      enableShadows: true,
      padding: padding ?? const EdgeInsets.all(24),
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: child,
    );
  }

  /// Factory constructor for icon container
  factory AppCard.iconContainer({
    required Widget child,
    required BuildContext context,
    EdgeInsets? padding,
    double? size,
    VoidCallback? onTap,
  }) {
    final colorScheme = context.colorScheme;
    return AppCard(
      onTap: onTap,
      radius: UiConstants.radiusDefault,
      color: colorScheme.primary.withValues(alpha: 0.1),
      padding: padding ?? const EdgeInsets.all(12),
      enableShadows: false,
      child: size != null ? SizedBox(width: size, height: size, child: child) : child,
    );
  }

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.enableScale && widget.onTap != null) {
      setState(() {});
      _animationController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.enableScale && widget.onTap != null) {
      setState(() {});
      _animationController.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.enableScale && widget.onTap != null) {
      setState(() {});
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = widget.radius ?? UiConstants.radiusLarge;
    final effectiveColor = widget.color ?? context.colorScheme.surfaceContainerHighest;
    final effectiveBorderColor = widget.borderColor ?? context.colorScheme.outline.withValues(alpha: 0.1);

    Widget cardContent = AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: widget.gradient == null ? effectiveColor : null,
            gradient: widget.gradient,
            borderRadius: BorderRadius.circular(effectiveRadius),
            border: Border.all(
              color: (widget.borderWidth ?? 0) <= 0 ? Colors.transparent : effectiveBorderColor,
              width: widget.borderWidth ?? 0,
            ),
            boxShadow: widget.enableShadows
                ? context.effectiveShadows()
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: Ink(
              decoration: BoxDecoration(
                color: widget.gradient == null ? effectiveColor : null,
                gradient: widget.gradient,
                borderRadius: BorderRadius.circular(effectiveRadius),
              ),
              child: InkWell(
                onTap: widget.onTap,
                onTapUp: _handleTapUp,
                onTapDown: _handleTapDown,
                onTapCancel: _handleTapCancel,
                borderRadius: BorderRadius.circular(effectiveRadius),
                splashColor: context.colorScheme.onPrimary.withValues(
                  alpha: 0.1,
                ),
                highlightColor: context.colorScheme.onPrimary.withValues(
                  alpha: 0.05,
                ),
                child: widget.padding != null ? Padding(padding: widget.padding!, child: widget.child) : widget.child,
              ),
            ),
          ),
        ),
      ),
    );

    if (widget.margin != null) {
      cardContent = Padding(padding: widget.margin!, child: cardContent);
    }

    return cardContent;
  }
}

class AppGrid extends StatelessWidget {
  const AppGrid({
    required this.child,
    super.key,
    this.delegate,
    this.maxExtent = 120,
    this.phoneCount = 1,
    this.tabletCount = 2,
    this.landscapeCount = 3,
    this.controller,
    this.axisSpacing,
    this.physics,
  });

  final double? maxExtent;
  final List<Widget> child;
  final int phoneCount;
  final int tabletCount;
  final int landscapeCount;
  final double? axisSpacing;
  final SliverGridDelegate? delegate;
  final ScrollController? controller;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = context.isPhone
        ? phoneCount
        : context.mediaQuerySize.width >= 1200
            ? landscapeCount
            : tabletCount;

    return GridView(
      controller: controller,
      shrinkWrap: true,
      physics: physics ?? const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisExtent: maxExtent,
        mainAxisSpacing: axisSpacing ?? 0,
        crossAxisSpacing: axisSpacing ?? 0,
      ),
      children: child,
    );
  }
}

class AppSliverGrid extends StatelessWidget {
  const AppSliverGrid({
    required this.child,
    super.key,
    this.maxExtent = 120,
    this.phoneCount = 1,
    this.tabletCount = 2,
    this.landscapeCount = 3,
    this.controller,
    this.axisSpacing,
    this.physics,
    this.padding,
  });

  final double? maxExtent;
  final List<Widget> child;
  final int phoneCount;
  final int tabletCount;
  final int landscapeCount;
  final double? axisSpacing;
  final EdgeInsets? padding;
  final ScrollController? controller;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = context.isPhone
        ? phoneCount
        : context.mediaQuerySize.width >= 900
            ? landscapeCount
            : tabletCount;

    return SliverPadding(
      padding: padding ?? EdgeInsets.zero,
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisExtent: maxExtent,
          mainAxisSpacing: axisSpacing ?? 0,
          crossAxisSpacing: axisSpacing ?? 0,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => child[index],
          childCount: child.length,
        ),
      ),
    );
  }
}

class MenuItem extends StatelessWidget {
  const MenuItem(this.item, {super.key, this.onTap, this.isDestructive,this.padding});

  final MenuModel item;
  final VoidCallback? onTap;
  final bool? isDestructive;
  final double? padding;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textColor = (isDestructive ?? false) ? colorScheme.error : colorScheme.onSurface;
    final iconColor = (isDestructive ?? false) ? colorScheme.error : colorScheme.secondary;

    return AppCard(
      radius: UiConstants.radiusLarge,
      enableShadows: false,
      color: colorScheme.surfaceBright,
      onTap: onTap,
      child: Row(
        spacing: 16,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(UiConstants.radiusDefault),
            ),
            child: Icon(item.icon, color: iconColor, size: 20),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                CommonText.medium(item.title!, size: 15, color: textColor),
                if (item.subtitle != null) ...[
                  const SizedBox(height: 2),
                  CommonText.regular(
                    item.subtitle!,
                    size: 12,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ],
              ],
            ),
          ),
          Icon(
            IconsaxPlusLinear.arrow_right_3,
            size: 18,
            color: colorScheme.onSurfaceVariant,
          ),
        ],
      ).paddingAll(padding ?? 0),
    );
  }
}

class AppDivider extends StatelessWidget {
  const AppDivider({super.key, this.marginLeft = 0});

  final double marginLeft;

  @override
  Widget build(BuildContext context) => Divider(
        thickness: 1,
        height: 1,
        color: context.colorScheme.outlineVariant,
      ).marginOnly(left: marginLeft).marginSymmetric(vertical: 16);
}

class PageLoader extends StatelessWidget {
  const PageLoader({super.key});

  @override
  Widget build(BuildContext context) => Center(
        child: Container(
          padding: const EdgeInsets.all(4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator.adaptive(
                  strokeWidth: 1.5,
                  backgroundColor: context.colorScheme.tertiary,
                ),
              ),
              const SizedBox(width: 16),
              CommonText.medium('Loading...', color: context.colorScheme.onPrimary),
            ],
          ),
        ).paddingOnly(bottom: MediaQuery.of(context).padding.bottom, top: 4),
      );
}

class SwipeRefresh extends StatelessWidget {
  const SwipeRefresh({required this.onRefresh, required this.child, super.key});

  final Widget child;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) => RefreshIndicator(
        onRefresh: onRefresh,
        color: context.colorScheme.primary,
        backgroundColor: context.colorScheme.tertiary,
        child: child,
      );
}

void showPicker({
  required VoidCallback? galleryPicker,
  VoidCallback? cameraPicker,
  bool? isShowCameraOption,
}) {
  final context = Get.context!;
  showModalBottomSheet(
    context: context,
    clipBehavior: Clip.hardEdge,
    useSafeArea: true,
    showDragHandle: true,
    useRootNavigator: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
    ),
    backgroundColor: context.colorScheme.surface,
    isScrollControlled: true,
    builder: (builder) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MenuItem(
            MenuModel(
              title: 'Choose from Gallery',
              subtitle: 'Select from your photo library',
              icon: IconsaxPlusLinear.gallery,
            ),
            onTap: () {
              Get.back();
              galleryPicker?.call();
            },
            padding: 12,
          ).marginOnly(left: 16, right: 16),
          if (isShowCameraOption ?? true) ...[
            MenuItem(
              MenuModel(
                title: 'Take a Photo',
                subtitle: 'Use camera to capture photo',
                icon: IconsaxPlusLinear.camera,
              ),
              onTap: () {
                Get.back();
                cameraPicker?.call();
              },
              padding: 12,
            ).marginOnly(left: 16, right: 16,top: 16),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: AppButton(
              label: 'Cancel',
              type: ButtonType.outline,
              onPressed: Get.back,
            ).paddingSymmetric(horizontal: 16, vertical: 8),
          ),
        ],
      ),
    ),
  );
}
