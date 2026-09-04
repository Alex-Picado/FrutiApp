import 'dart:convert';

import 'package:web/web.dart' as web;

void descargarJson(String contenido) {
  final base64 = base64Encode(utf8.encode(contenido));
  final anchor = web.HTMLAnchorElement()
    ..href = 'data:application/json;base64,$base64'
    ..setAttribute('download', 'bitacora_accesos.json');
  web.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
}