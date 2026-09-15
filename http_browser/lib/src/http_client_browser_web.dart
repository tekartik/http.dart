import 'dart:js_interop';
import 'dart:typed_data';

import 'package:http/browser_client.dart' as http;
import 'package:http/http.dart' as http;
import 'package:tekartik_http_browser/src/http_client_browser.dart';
import 'package:web/web.dart' as web;

class _HttpClientFactoryBrowser implements HttpClientFactoryBrowser {
  @override
  http.Client newClient() {
    return http.BrowserClient();
  }

  @override
  Uri createObjectUrl(Uint8List bytes, {String? contentType}) {
    var parts = <JSAny>[bytes.toJS].toJS;
    var blob = contentType == null
        ? web.Blob(parts)
        : web.Blob(parts, web.BlobPropertyBag(type: contentType));
    return Uri.parse(web.URL.createObjectURL(blob));
  }

  @override
  void revokeObjectUrl(Uri url) {
    web.URL.revokeObjectURL(url.toString());
  }
}

HttpClientFactoryBrowser? _httpClientFactoryBrowser;

/// Browser http client factory (web only).
HttpClientFactoryBrowser get httpClientFactoryBrowser =>
    _httpClientFactoryBrowser ??= _HttpClientFactoryBrowser();
