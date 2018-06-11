import 'dart:async';

import 'package:node_io/node_io.dart' as node;
import 'package:tekartik_http/http_server.dart';

class HttpServerFactoryNode implements HttpServerFactory {
  @override
  Future<HttpServer> bind(address, int port) =>
      node.HttpServer.bind(address, port);
}

HttpServerFactoryNode _httpServerFactoryNode;
HttpServerFactoryNode get httpServerFactoryNode =>
    _httpServerFactoryNode ??= new HttpServerFactoryNode();
