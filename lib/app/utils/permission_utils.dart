import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
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
    if (kIsWeb || !Platform.isAndroid) return true;

    final sdkInt = (await DeviceInfoPlugin().androidInfo).version.sdkInt;
    // WRITE_EXTERNAL_STORAGE is declared with maxSdkVersion 28. Android 10+
    // uses MediaStore for Downloads, so requesting storage logs
    // "No permissions found in manifest for: []15".
    if (sdkInt >= 29) return true;

    final status = await Permission.storage.request();
    return status.isGranted;
  }

  static Future<bool> requestNotifications() async {
    if (kIsWeb) return true;
    final status = await Permission.notification.request();
    return status.isGranted;
  }
}
