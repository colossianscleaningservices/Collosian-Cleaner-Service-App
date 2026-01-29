import 'package:ccs_app/export.dart';

class QuickActionChip extends StatelessWidget {
  const QuickActionChip({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    required this.scheme,
    this.subtitle,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      radius: UiConstants.radiusDefault,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppCard(
            enableShadows: false,
            color: scheme.secondaryContainer,
            padding: const EdgeInsets.all(12),
            child: Icon(icon, size: 24, color: scheme.secondary),
          ).marginOnly(bottom: 12),
          CommonText.semiBold(label, size: 14, color: scheme.onSurface, textAlign: TextAlign.center),
          if (subtitle != null) ...[
            CommonText.regular(
              subtitle!,
              size: 11,
              color: scheme.onSurfaceVariant,
              textAlign: TextAlign.center,
            ).marginOnly(top: 4),
          ],
        ],
      ),
    );
  }
}
