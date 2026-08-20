import 'package:ccs_app/app/services/pref.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get_ip_address/get_ip_address.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/theme.dart';

extension CcsStringX on String {
  bool get isNullOrEmpty => trim().isEmpty;

  int toInt() => int.tryParse(this) ?? 0;

  double toDouble() => double.tryParse(this) ?? 0.0;

  Color parseHexColor({Color fallback = Colors.grey}) {
    if (isNullOrEmpty) return fallback;
    final cleaned = replaceAll('#', '').trim();
    final value = int.tryParse('0xFF$cleaned');
    return Color(value ?? fallback.toARGB32());
  }

  String toTitleCase() {
    final trimmed = trim();
    if (trimmed.isEmpty) return this;
    return trimmed.split(RegExp(r'\s+')).map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}').join(' ');
  }
}

extension CcsContextX on BuildContext {
  ThemeData get theme => Theme.of(this);

  bool get isModeDark => theme.brightness == Brightness.dark;

  /// WAVTech-style: map to app-defined schemes.
  ColorScheme get colorScheme => isModeDark ? darkColorScheme : lightColorScheme;

  MediaQueryData get mediaQuery => MediaQuery.of(this);

  double get height => mediaQuery.size.height;

  double get width => mediaQuery.size.width;

  EdgeInsets get mediaQueryPadding => mediaQuery.padding;

  double get topPadding => mediaQuery.padding.top;

  double get bottomPadding => mediaQuery.padding.bottom;

  double get topInset => mediaQuery.viewInsets.top;

  double get bottomInset => mediaQuery.viewInsets.bottom;

  void hideKeyboard() {
    final currentFocus = FocusScope.of(this);
    if (!currentFocus.hasPrimaryFocus && currentFocus.hasFocus) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  List<BoxShadow> effectiveShadows({
    Color? shadowColor,
    Offset? offset,
    double? blurRadius,
  }) {
    if (shadowColor != null || offset != null || blurRadius != null) {
      return [
        BoxShadow(
          color: theme.brightness == Brightness.dark ? Colors.grey.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.03),
          offset: offset ?? const Offset(-2, -2),
          blurRadius: blurRadius ?? 8,
        ),
        BoxShadow(
          color: shadowColor ?? (theme.brightness == Brightness.dark ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.08)),
          offset: offset ?? const Offset(2, 2),
          blurRadius: blurRadius ?? 8,
        ),
      ];
    }
    return [
      BoxShadow(
        color: colorScheme.shadow.withValues(alpha: isModeDark ? 0.22 : 0.06),
        blurRadius: 16,
        offset: const Offset(0, 8),
      ),
      BoxShadow(
        color: colorScheme.shadow.withValues(alpha: isModeDark ? 0.08 : 0.02),
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    ];
  }
}

bool isResponseBlank(dynamic value) {
  if (value is String) return value.trim().isEmpty;
  if (value is Iterable) return value.isEmpty;
  if (value is Map) return value.isEmpty;
  return false;
}

void openUrl(String uri) async {
  final Uri url = Uri.parse(uri);
  if (!await launchUrl(url)) {
    throw Exception('Could not launch $url');
  }
}

Future<void> getTimeZone() async {
  String timeZone = '';

  await FlutterTimezone.getLocalTimezone().then(
    (onValue) {
      timeZone = onValue.identifier;
      Prefs().putTimeZoneData(Prefs.timezone, timeZone);
      return timeZone;
    },
    onError: (onError) {
      return timeZone;
    },
  );
}

Future<void> getIpAddress() async {
  try {
    var data = IpAddress(type: RequestType.json).getIpAddress();

    data.then((value) {
      if (value is Map<String, dynamic> && value['ip'] != null) {
        Prefs().putData(Prefs.ipAddress, value['ip'].toString());
      }
    });
  } catch (_) {
    // Best-effort; leave ip_address empty on failure
  }
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}

Color getBgColor(String label, ColorScheme scheme){
  final lower = label.toLowerCase();
  Color bg;
  if (lower.contains('cancel') || lower.contains('reject') || lower.contains('declin')) {
    bg = scheme.errorContainer.withValues(alpha: 0.35);
  } else if (lower.contains('complete') || lower.contains('done') || lower.contains('finished') || lower.contains('paid')) {
    bg = scheme.tertiaryContainer.withValues(alpha: 0.35);
  } else if (lower.contains('pending')) {
    bg = scheme.secondaryContainer.withValues(alpha: 0.40);
  } else {
    bg = scheme.primaryContainer.withValues(alpha: 0.25);
  }

  return bg;
}

Color getFgColor(String label, ColorScheme scheme){
  final lower = label.toLowerCase();
  Color fg;
  if (lower.contains('cancel') || lower.contains('reject') || lower.contains('declin')) {
    fg = scheme.error;
  } else if (lower.contains('complete') || lower.contains('done') || lower.contains('finished') || lower.contains('paid')) {
    fg = scheme.onTertiaryContainer;
  } else if (lower.contains('pending')) {
    fg = scheme.onSecondaryContainer;
  } else {
    fg = scheme.primary;
  }

  return fg;
}

/// Job `status` is for listing/UI. `cleaner_job_status` is for actions/workflow.
class JobStatusX {
  JobStatusX._();

  static String normalize(String? status) =>
      (status ?? '').trim().toLowerCase().replaceAll('_', ' ');

  /// Combined job status for chips. Job-level Approved is shown as Assigned.
  static String displayLabel(String? status) {
    final n = normalize(status);
    if (n.isEmpty) return 'N/A';
    if (n == 'approved') return 'Approved';
    if (n == 'canceled' || n == 'cancelled') return 'Cancelled';
    if (n == 'in process') return 'In Process';
    return n.split(' ').where((w) => w.isNotEmpty).map((w) => '${w[0].toUpperCase()}${w.substring(1)}').join(' ');
  }

  /// Cleaner detail chip: Finished (job) wins over Completed (cleaner).
  static String displayLabelForCleaner({
    required String? jobStatus,
    required String? cleanerJobStatus,
  }) {
    if (isJobFinished(jobStatus)) return 'Finished';
    if (isCleanerCompleted(cleanerJobStatus)) return 'Completed';
    if (isCleanerInProcess(cleanerJobStatus)) return 'In Process';
    return displayLabel(jobStatus);
  }

  static bool isPending(String? status) => normalize(status) == 'pending';

  static bool isApproved(String? status) => normalize(status) == 'approved';

  static bool isInProcess(String? status) => normalize(status) == 'in process';

  static bool isJobFinished(String? status) => normalize(status) == 'finished';

  static bool isCancelled(String? status) {
    final n = normalize(status);
    return n == 'cancelled' || n == 'canceled';
  }

  static bool isCleanerCompleted(String? status) {
    final n = normalize(status);
    return n == 'completed' || n == 'finished';
  }
  static bool isCleanerInProcess(String? status) {
    final n = normalize(status);
    return n == 'in process' || n == 'In Process';
  }
}

