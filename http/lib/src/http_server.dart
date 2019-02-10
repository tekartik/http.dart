import 'dart:async';
import 'dart:io';

import 'package:tekartik_http/http.dart';

abstract class HttpServerFactory {
  /// Use 0 to automatically assign a port
  Future<HttpServer> bind(address, int port);
}

/// Node does not support root uri. / appendend on puropose
Uri httpServerGetUri(HttpServer server) =>
    Uri.parse('http://${localhost}:${server.port}/');
