// ignore: avoid_web_libraries_in_flutter
import 'dart:html';

Future<void> download(String url, String fileName) async {
  final element = AnchorElement(href: url);
  element.href = url;
  element.download = fileName;
  element.click();
}
