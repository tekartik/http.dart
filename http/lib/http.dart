import 'package:tekartik_http/http.dart';

export 'package:tekartik_http/src/http.dart';
export 'package:tekartik_http/src/http_constant.dart';

export 'http_client.dart';
export 'http_server.dart';

/// Localhost.
const String localhost = 'localhost';

/// Use to dynamically assign a port
const int portDynamic = 0;

/// Http client and server factory.
abstract class HttpFactory {
  /// Http client factory.
  HttpClientFactory get client;

  /// Http server factory.
  HttpServerFactory get server;
}

/// Parse any uri (String or Uri).
Uri parseUri(dynamic url) {
  Uri uri;
  if (url is Uri) {
    uri = url;
  } else {
    uri = Uri.parse(url.toString());
  }
  return uri;
}
