import 'package:ccs_app/export.dart';
import 'package:url_launcher/url_launcher.dart';

/// Wraps a titled block for accessibility (screen reader section boundaries).
class JobDetailSection extends StatelessWidget {
  const JobDetailSection({
    super.key,
    required this.semanticLabel,
    required this.emoji,
    required this.title,
    required this.scheme,
    required this.child,
  });

  final String semanticLabel;
  final String emoji;
  final String title;
  final ColorScheme scheme;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: semanticLabel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CommonText.regular(
            '$emoji  ${title.toUpperCase()}',
            size: 14,
            fontWeight: FontWeight.w800,
            color: scheme.onSurfaceVariant,
          ).paddingOnly(bottom: 8),
          child,
        ],
      ),
    );
  }
}

/// Placeholder blocks while job details are loading.
class JobDetailLoadingSkeleton extends StatelessWidget {
  const JobDetailLoadingSkeleton({super.key, required this.scheme});

  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final base = scheme.surfaceContainerHighest.withValues(alpha: 0.9);
    Widget bar(double h, [double factor = 1]) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Container(
            height: h,
            width: double.infinity,
            constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * factor),
            decoration: BoxDecoration(
              color: base,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );

    return SingleChildScrollView(
      padding: UiConstants.padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          bar(14, 0.45),
          bar(120),
          const SizedBox(height: 16),
          bar(14, 0.5),
          bar(100),
          const SizedBox(height: 16),
          bar(14, 0.55),
          bar(88),
        ],
      ),
    );
  }
}

/// Shown when the detail request failed and there is no cached job.
class JobDetailFetchError extends StatelessWidget {
  const JobDetailFetchError({
    super.key,
    required this.message,
    required this.scheme,
    required this.onRetry,
  });

  final String message;
  final ColorScheme scheme;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: UiConstants.padding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(IconsaxPlusLinear.warning_2, size: 48, color: scheme.error),
            const SizedBox(height: 16),
            CommonText.semiBold('Couldn\'t load job', size: 18, color: scheme.onSurface, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            CommonText.regular(message, size: 14, color: scheme.onSurfaceVariant, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            AppButton(
              label: 'Try again',
              onPressed: onRetry,
              btnVerticalPadding: 12,
              btnCornerRadius: 12,
            ),
          ],
        ),
      ),
    );
  }
}

/// Joins primary date, optional time range, and optional end date with middots.
String jobScheduleSummaryLine({
  String? dateFormatted,
  String? timeRange,
  String? endsFormatted,
}) {
  final parts = <String>[];
  if (dateFormatted != null && dateFormatted.trim().isNotEmpty) {
    parts.add(dateFormatted.trim());
  }
  if (timeRange != null && timeRange.trim().isNotEmpty) {
    parts.add(timeRange.trim());
  }
  if (endsFormatted != null && endsFormatted.trim().isNotEmpty) {
    parts.add('Ends ${endsFormatted.trim()}');
  }
  return parts.join(' · ');
}

/// Property headline, optional type line, single-line address with inline actions.
/// When [propertyName] is null or empty, the title block is omitted (e.g. location-only card).
class JobPropertyBlock extends StatelessWidget {
  const JobPropertyBlock({
    super.key,
    this.clientName,
    this.propertyName,
    this.typeLine,
    this.addressText,
    this.metaLine,
    this.paymentLine,
    required this.scheme,
  });

  final String? clientName;
  final String? propertyName;
  /// Property type and subtype joined, e.g. `Bungalow · Garden`.
  final String? typeLine;
  /// Full address in one string (street, city, postcode as you prefer).
  final String? addressText;
  final String? metaLine;
  final String? paymentLine;
  final ColorScheme scheme;

  String get _fullAddressForMaps {
    final parts = <String>[];
    if (addressText != null && addressText!.trim().isNotEmpty) {
      parts.add(addressText!.trim());
    }
    final name = propertyName?.trim() ?? '';
    if (name.isNotEmpty) {
      parts.add(name);
    }
    return parts.join(', ');
  }

  Future<void> _copyAddress(BuildContext context) async {
    final text = _fullAddressForMaps;
    if (text.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: text));
    Notifier.success('Address copied');
  }

  Future<void> _openMaps() async {
    final q = _fullAddressForMaps;
    if (q.isEmpty) {
      Notifier.info('No address to show on map');
      return;
    }
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(q)}');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Notifier.info('Could not open Maps');
      }
    } catch (_) {
      Notifier.info('Could not open Maps');
    }
  }

  static ButtonStyle _iconBtnStyle(ColorScheme scheme) {
    return IconButton.styleFrom(
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.all(6),
      minimumSize: const Size(36, 36),
      foregroundColor: scheme.primary,
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasActions = _fullAddressForMaps.isNotEmpty;
    final addr = addressText?.trim() ?? '';
    final title = propertyName?.trim() ?? '';
    final hasClient = clientName != null && clientName!.trim().isNotEmpty;
    final gapBeforeAddress = title.isNotEmpty || (typeLine?.trim().isNotEmpty ?? false) || hasClient;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasClient)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: CommonText.regular(
              'Client: ${clientName!.trim()}',
              size: 14,
              color: scheme.onSurface,
            ),
          ),
        if (title.isNotEmpty) ...[
          CommonText.semiBold(title, size: 18, color: scheme.onSurface),
          if (typeLine != null && typeLine!.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            CommonText.regular(typeLine!.trim(), size: 14, color: scheme.onSurfaceVariant),
          ],
        ],
        if (addr.isNotEmpty || hasActions) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (addr.isNotEmpty)
                Expanded(
                  child: CommonText.medium(addr, size: 14, color: scheme.onSurface),
                )
              else if (hasActions)
                const Spacer(),
              if (hasActions) ...[
                IconButton(
                  tooltip: 'Copy address',
                  style: _iconBtnStyle(scheme),
                  onPressed: () => _copyAddress(context),
                  icon: Icon(IconsaxPlusLinear.copy, size: 20, color: scheme.primary),
                ),
                IconButton(
                  tooltip: 'Open in Maps',
                  style: _iconBtnStyle(scheme),
                  onPressed: _openMaps,
                  icon: Icon(IconsaxPlusLinear.map_1, size: 20, color: scheme.primary),
                ),
              ],
            ],
          ),
        ],
        if (metaLine != null && metaLine!.trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          CommonText.regular(metaLine!, size: 13, color: scheme.onSurfaceVariant),
        ],
        if (paymentLine != null && paymentLine!.trim().isNotEmpty) ...[
          const SizedBox(height: 6),
          CommonText.regular(paymentLine!, size: 12, color: scheme.onSurfaceVariant),
        ],
      ],
    );
  }
}

/// Staff preference line + equipment chips (shared rules for client job API shape).
class JobPreferencesBlock extends StatelessWidget {
  const JobPreferencesBlock({
    super.key,
    required this.scheme,
    this.staffPreference,
    required this.equipmentChips,
  });

  final ColorScheme scheme;
  final String? staffPreference;
  final List<Widget> equipmentChips;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (staffPreference != null && staffPreference!.trim().isNotEmpty) ...[
          CommonText.regular('Staff preference', size: 12, color: scheme.onSurfaceVariant),
          const SizedBox(height: 4),
          CommonText.semiBold(staffPreference!.trim(), size: 15, color: scheme.onSurface),
          const SizedBox(height: 12),
        ],
        CommonText.regular('Equipment available', size: 12, color: scheme.onSurfaceVariant),
        const SizedBox(height: 8),
        if (equipmentChips.isEmpty)
          CommonText.regular('None listed', size: 14, color: scheme.onSurfaceVariant)
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: equipmentChips,
          ),
      ],
    );
  }
}

List<Widget> buildJobEquipmentChips({
  required ColorScheme scheme,
  String? hoover,
  bool? provideCleaningProducts,
  bool? provideWashingMachine,
  bool? provideDryer,
}) {
  final list = <Widget>[];
  if (hoover != null && hoover.trim().isNotEmpty) {
    final lower = hoover.toLowerCase().trim();
    if (lower != 'no' && lower != 'none' && lower != 'n/a') {
      list.add(InfoChip(
        label: 'Hoover',
        backgroundColor: scheme.secondaryContainer,
        foregroundColor: scheme.onSecondaryContainer,
      ));
    }
  }
  if (provideCleaningProducts == true) {
    list.add(InfoChip(
      label: 'Cleaning products',
      backgroundColor: scheme.secondaryContainer,
      foregroundColor: scheme.onSecondaryContainer,
    ));
  }
  if (provideWashingMachine == true) {
    list.add(InfoChip(
      label: 'Washer',
      backgroundColor: scheme.secondaryContainer,
      foregroundColor: scheme.onSecondaryContainer,
    ));
  }
  if (provideDryer == true) {
    list.add(InfoChip(
      label: 'Dryer',
      backgroundColor: scheme.secondaryContainer,
      foregroundColor: scheme.onSecondaryContainer,
    ));
  }
  return list;
}
