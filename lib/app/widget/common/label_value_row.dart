import 'package:ccs_app/export.dart';

/// Label–value row for job detail and similar screens.
/// Label in fixed-width column, value in [Expanded].
class LabelValueRow extends StatelessWidget {
  const LabelValueRow({
    super.key,
    required this.label,
    required this.value,
    required this.scheme,
    this.labelWidth = 130,
  });

  final String label;
  final String value;
  final ColorScheme scheme;
  final double labelWidth;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: labelWidth,
            child: CommonText.regular(label, size: 14, color: scheme.onSurfaceVariant),
          ),
          Expanded(
            child: CommonText.regular(value, size: 14, color: scheme.onSurface),
          ),
        ],
      ),
    );
  }
}
