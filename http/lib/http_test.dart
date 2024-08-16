import 'http_server.dart';

/// Test http server
extension TestHttpServer on HttpServer {
  /// Get the base Uri for the client
  Uri get uri => httpServerGetUri(this);
}
