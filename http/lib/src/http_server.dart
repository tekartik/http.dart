import 'dart:async';
import 'dart:io';

abstract class HttpServerFactory {
  Future<HttpServer> bind(address, int port);
}
