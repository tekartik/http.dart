import 'package:tekartik_http/http.dart';

export 'package:tekartik_http/src/http.dart';
export 'package:tekartik_http/src/http_constant.dart';

export 'http_client.dart';
export 'http_server.dart';

const String localhost = 'localhost';

abstract class HttpFactory {
  HttpClientFactory get client;

  HttpServerFactory get server;
}

Uri parseUri(dynamic url) {
  Uri uri;
  if (url is Uri) {
    uri = url;
  } else {
    uri = Uri.parse(url.toString());
  }
  return uri;
}
