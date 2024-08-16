import 'package:tekartik_http/http_server.dart';

/// Http headers mixin
mixin HttpHeadersMixin implements HttpHeaders {
  @override
  String toString() {
    var map = <String, dynamic>{};
    forEach((name, values) {
      map[name] = values;
    });
    return map.toString();
  }
}

/// Server that allows getting the uri
abstract class HttpServerWithUri {
  /// Get the uri to use
  Uri get uri;
}
