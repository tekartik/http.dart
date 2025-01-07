import 'package:tekartik_http/http_server.dart';
import 'package:tekartik_http/src/http_headers.dart';

/// Http headers mixin
mixin HttpHeadersMixin implements HttpHeaders {
  @override
  String toString() {
    var map = toMap();
    return map.toString();
  }
}

/// Server that allows getting the uri
abstract class HttpServerWithUri {
  /// Get the uri to use
  Uri get uri;
}
