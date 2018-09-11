export 'http_server.dart';
export 'http_client.dart';
export 'src/http.dart';
import 'package:tekartik_http/http.dart';

const String localhost = 'localhost';

abstract class HttpFactory {
  HttpClientFactory get client;
  HttpServerFactory get server;
}
