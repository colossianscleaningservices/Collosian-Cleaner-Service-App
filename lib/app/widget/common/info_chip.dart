import 'package:ccs_app/export.dart';

/// Small status/tag chip for job detail and similar screens.
class InfoChip extends StatelessWidget {
  const InfoChip({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    this.leftPadding = 10
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final double leftPadding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: leftPadding, right: 10, top: 6, bottom: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(UiConstants.radiusSmall),
        border: Border.all(color: foregroundColor.withValues(alpha: 0.18)),
      ),
      child: CommonText.medium(
        label,
        size: 13,
        color: foregroundColor,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
