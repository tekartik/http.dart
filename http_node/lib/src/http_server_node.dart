import 'dart:async';

import 'package:node_io/node_io.dart' as node;
import 'package:tekartik_http/http_server.dart';
// ignore: implementation_imports
import 'package:tekartik_http_io/src/http_server_io.dart' as io;

class HttpServerFactoryNode implements HttpServerFactory {
  int lastDynamicPort = 33000;
  @override
  Future<HttpServer> bind(address, int port) async {
    if (port == 0) {
      port = lastDynamicPort;
    }
    while (true) {
      try {
        var server = await node.HttpServer.bind(address, port);
        lastDynamicPort = server.port;
        return io.HttpServerIo(server);
      } catch (_) {
        port++;
        if (port > lastDynamicPort + 1000) {
          rethrow;
        }
      }
    }
  }
}

HttpServerFactoryNode _httpServerFactoryNode;
HttpServerFactoryNode get httpServerFactoryNode =>
    _httpServerFactoryNode ??= HttpServerFactoryNode();
