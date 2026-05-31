// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:html' as html;
import 'dart:typed_data';

Future<void> downloadOrShare(Uint8List bytes, String filename) async {
  final blob   = html.Blob([bytes], 'application/pdf');
  final url    = html.Url.createObjectUrlFromBlob(blob);
  (html.AnchorElement(href: url)
        ..setAttribute('download', filename)
        ..click())
      .remove();
  html.Url.revokeObjectUrl(url);
}
