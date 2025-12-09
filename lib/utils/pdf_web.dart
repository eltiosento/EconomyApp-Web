import 'dart:typed_data';

import 'package:web/web.dart' as web;
import 'package:js/js_util.dart' as jsutil;

void downloadPdfWeb(Uint8List bytes, String fileName) {
  // Convertimos Uint8List → JSArray para BlobPart
  final jsArray = jsutil.jsify([bytes]);

  // Creamos Blob
  final blob = web.Blob(jsArray, web.BlobPropertyBag(type: 'application/pdf'));

  // Creamos URL del Blob
  final url = web.URL.createObjectURL(blob);

  final anchor =
      web.HTMLAnchorElement()
        ..href = url
        ..download = fileName;

  anchor.click();

  // Liberar memoria
  web.URL.revokeObjectURL(url);
}
