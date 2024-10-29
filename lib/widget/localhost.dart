import 'dart:io';

String resolveUrl(String url) {
  // Replace 'localhost' only for mobile devices
  if (Platform.isAndroid || Platform.isIOS) {
    return url.replaceFirst('localhost', '192.168.1.121');
  }
  return url;
}
