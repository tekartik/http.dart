import 'dart:async';

import 'package:node_io/node_io.dart' as node;
import 'package:tekartik_http/http_server.dart';
// ignore: implementation_imports
import 'package:tekartik_http_io/src/http_server_io.dart' as io;

/// Convert to a native internet address case by case...
dynamic unwrapInternetAddress(dynamic address) {
  if (address is InternetAddress) {
    if (address == InternetAddress.anyIPv4) {
      address = '0.0.0.0';
    } else {
      throw 'address $address not supported';
    }
  }
  return address;
}

class HttpServerFactoryNode implements HttpServerFactory {
  int lastDynamicPort = 33000;
  @override
  Future<HttpServer> bind(address, int port) async {
    if (port == 0) {
      port = lastDynamicPort;
    }
    address = unwrapInternetAddress(address);
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
