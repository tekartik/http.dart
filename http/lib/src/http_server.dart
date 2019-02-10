import 'dart:async';
import 'dart:io';

import 'package:tekartik_http/http.dart';

abstract class HttpServerFactory {
  Future<HttpServer> bind(address, int port);
}

Uri httpServerGetUri(HttpServer server) => Uri.parse('http://${localhost}:${server.port}');

