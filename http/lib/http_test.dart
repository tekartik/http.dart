import 'http_server.dart';

extension TestHttpServer on HttpServer {
  /// Get the base Uri for the client
  Uri get uri => httpServerGetUri(this);
}
