import 'dart:async';
import 'dart:io' as io;

import 'package:tekartik_http/http_server.dart';

class IoHttpServerFactory implements HttpServerFactory {
  @override
  Future<HttpServer> bind(address, int port) =>
      io.HttpServer.bind(address, port);
}

IoHttpServerFactory _ioHttpServerFactory;
IoHttpServerFactory get httpServerFactoryIo =>
    _ioHttpServerFactory ??= IoHttpServerFactory();
