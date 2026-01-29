import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionUtils {
  PermissionUtils._();

  static Future<bool> requestCamera() async {
    if (kIsWeb) return true;
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  static Future<bool> requestPhotos() async {
    if (kIsWeb) return true;
    // iOS uses Permission.photos; Android 13+ uses Permission.photos as well,
    // older Android may require storage depending on picker source.
    final status = await Permission.photos.request();
    return status.isGranted;
  }

  static Future<bool> requestStorage() async {
    if (kIsWeb) return true;
    // On Android 13+, storage permission is generally replaced by media permissions.
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      return status.isGranted;
    }
    final status = await Permission.storage.request();
    return status.isGranted;
  }

  static Future<bool> requestNotifications() async {
    if (kIsWeb) return true;
    final status = await Permission.notification.request();
    return status.isGranted;
  }
}
