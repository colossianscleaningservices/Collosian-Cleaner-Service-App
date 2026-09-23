import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ccs_app/export.dart';
import 'package:in_app_update_flutter/in_app_update_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Checks for a store update before splash leaves for login or a dashboard.
///
/// Android uses Play in-app updates. iOS compares the installed version with
/// the App Store listing and, when a newer build is published, presents the
/// store page inside the app.
class InAppUpdateService {
  InAppUpdateService._();

  static const _tag = 'IN_APP_UPDATE';
  static const _iosBundleId = 'app.ccs.io';
  static final InAppUpdateFlutter _plugin = InAppUpdateFlutter();
  static StreamSubscription<InstallStateAndroid>? _installSub;

  static Future<void> check() async {
    if (kIsWeb) return;
    try {
      if (Platform.isAndroid) {
        await _checkAndroid();
      } else if (Platform.isIOS) {
        await _checkIos();
      }
    } catch (e) {
      log(_tag, 'Update check skipped: $e');
    }
  }

  static Future<void> _checkAndroid() async {
    final info = await _plugin.checkUpdateAndroid().timeout(const Duration(seconds: 8));
    if (info.installStatus == InstallStatusAndroid.downloaded) {
      await _promptRestart();
      return;
    }

    if (info.updateAvailability == UpdateAvailabilityAndroid.developerTriggeredUpdateInProgress) {
      final result = await _plugin.startImmediateUpdateAndroid();
      log(_tag, 'Resumed in-progress update: ${result.name}');
      return;
    }

    final available = info.updateAvailability == UpdateAvailabilityAndroid.updateAvailable;
    if (!available) {
      log(_tag, 'No Android update (${info.updateAvailability.name})');
      return;
    }

    if (info.isImmediateUpdateAllowed) {
      final result = await _plugin.startImmediateUpdateAndroid();
      log(_tag, 'Immediate update result: ${result.name}');
      return;
    }

    if (!info.isFlexibleUpdateAllowed) return;

    final result = await _plugin.startFlexibleUpdateAndroid();
    log(_tag, 'Flexible update result: ${result.name}');
    if (result != UpdateResultAndroid.success) return;

    await _installSub?.cancel();
    _installSub = _plugin.installStateStreamAndroid.listen((state) {
      if (state.status != InstallStatusAndroid.downloaded) return;
      log(_tag, 'Flexible update downloaded');
      unawaited(_installSub?.cancel());
      _installSub = null;
      unawaited(_promptRestart());
    });
  }

  static Future<void> _promptRestart() async {
    if (Get.isDialogOpen ?? false) return;
    if (Get.context == null) {
      await _plugin.completeUpdateAndroid();
      return;
    }

    await Get.dialog<void>(
      AlertDialog(
        title: const Text('Update ready'),
        content: const Text('A new version has been downloaded. Restart to finish installing it.'),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('Later'),
          ),
          TextButton(
            onPressed: () => _plugin.completeUpdateAndroid(),
            child: const Text('Restart'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  static Future<void> _checkIos() async {
    final listing = await _lookupIosListing();
    if (listing == null) return;

    final local = await PackageInfo.fromPlatform();
    if (!_isNewer(listing.version, local.version)) {
      log(_tag, 'iOS is current (${local.version})');
      return;
    }

    log(_tag, 'iOS update ${local.version} -> ${listing.version}');
    await _plugin.showUpdateForIos(appStoreId: listing.trackId);
  }

  static Future<_IosListing?> _lookupIosListing() async {
    final client = HttpClient();
    try {
      final request = await client.getUrl(Uri.parse('https://itunes.apple.com/lookup?bundleId=$_iosBundleId')).timeout(const Duration(seconds: 8));
      final response = await request.close().timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return null;

      final body = await response.transform(utf8.decoder).join();
      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) return null;

      final results = decoded['results'];
      if (results is! List || results.isEmpty) return null;

      final first = results.first;
      if (first is! Map) return null;

      final version = first['version']?.toString() ?? '';
      final trackId = first['trackId']?.toString() ?? '';
      if (version.isEmpty || trackId.isEmpty) return null;
      return _IosListing(version: version, trackId: trackId);
    } finally {
      client.close(force: true);
    }
  }

  static bool _isNewer(String store, String local) {
    final storeParts = _parts(store);
    final localParts = _parts(local);
    final length = storeParts.length > localParts.length ? storeParts.length : localParts.length;
    for (var i = 0; i < length; i++) {
      final storePart = i < storeParts.length ? storeParts[i] : 0;
      final localPart = i < localParts.length ? localParts[i] : 0;
      if (storePart != localPart) return storePart > localPart;
    }
    return false;
  }

  static List<int> _parts(String version) => version.split('.').map((part) => int.tryParse(part) ?? 0).toList();
}

class _IosListing {
  const _IosListing({required this.version, required this.trackId});

  final String version;
  final String trackId;
}
