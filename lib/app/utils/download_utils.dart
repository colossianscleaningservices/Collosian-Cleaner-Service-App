import 'dart:io';

import 'package:ccs_app/app/utils/permission_utils.dart';
import 'package:downloadsfolder/downloadsfolder.dart';

class DownloadUtils {
  DownloadUtils._();

  /// Saves [source] into the device Downloads folder via `downloadsfolder`.
  static Future<void> saveToDownloads({
    required File source,
    required String fileName,
  }) async {
    if (Platform.isAndroid) {
      final granted = await PermissionUtils.requestStorage();
      if (!granted) {
        throw StateError('Storage permission is required to save to Downloads');
      }
    }

    final name = basenameWithoutExtension(fileName);
    final ext = extension(fileName);
    final success = await copyFileIntoDownloadFolder(
      source.path,
      name.isEmpty ? fileName : name,
      file: source,
      desiredExtension: ext.isEmpty ? null : ext,
    );
    if (success != true) {
      throw StateError('Unable to save file to Downloads');
    }
  }
}
