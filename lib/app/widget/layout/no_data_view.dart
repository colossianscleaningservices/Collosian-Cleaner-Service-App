import 'package:ccs_app/export.dart';

class NoDataView extends StatelessWidget {
  const NoDataView({
    super.key,
    this.title,
    this.subtitle,
    this.icon,
    this.actionLabel,
    this.onAction,
    this.padding,
  });

  final String? title;
  final String? subtitle;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Padding(
      padding: padding ?? const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: scheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(UiConstants.radiusXLarge),
              ),
              child: Icon(
                icon ?? IconsaxPlusLinear.folder_open,
                size: 48,
                color: scheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            CommonText.bold(
              title ?? 'No data available',
              size: 18,
              color: scheme.onSurface,
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              CommonText.regular(
                subtitle!,
                size: 14,
                color: scheme.onSurfaceVariant,
                textAlign: TextAlign.center,
              ),
            ],
            if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: 24),
              AppButton(
                label: actionLabel!,
                onPressed: onAction,
                type: ButtonType.tonal,
                btnVerticalPadding: 12,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

