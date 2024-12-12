import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:logger/logger.dart';


Future<String> getDeviceId() async {
  final deviceInfo = DeviceInfoPlugin();

  if (Platform.isAndroid) {
    final androidInfo = await deviceInfo.androidInfo;
    Logger().i('Device ID for Android: ${androidInfo.id}');
    return androidInfo.id;
  } else if (Platform.isIOS) {
    final iosInfo = await deviceInfo.iosInfo;
    Logger().i('Device ID for iOS: ${iosInfo.identifierForVendor}');
    return iosInfo.identifierForVendor ?? 'unknown_device';
  } else {
    Logger().w('Device platform not recognized. Returning default device_id.');
    return 'unknown_device';
  }
}
