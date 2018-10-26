import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:tekartik_http/http.dart';
import 'package:tekartik_http/src/http_client_memory.dart';

List<int> getBodyAsBytes(body, {Encoding encoding}) {
  if (body is String) {
    return utf8.encode(body);
  }
  return body as List<int>;
}

class HttpServerMemory extends Stream<HttpRequest> implements HttpServer {
  final int port;

  @override
  bool autoCompress;

  @override
  Duration idleTimeout;

  @override
  String serverHeader;

  @override
  InternetAddress address;

  HttpServerMemory(this.port);

  var requestCtlr = StreamController<HttpRequestMemory>();

  void addRequest(HttpRequestMemory request) {
    requestCtlr.add(request);
  }

  @override
  Future close({bool force = false}) async {
    await requestCtlr.close();
  }

  @override
  HttpConnectionsInfo connectionsInfo() => throw 'not implemented yet';

  // TODO: implement defaultResponseHeaders
  @override
  HttpHeaders get defaultResponseHeaders => throw 'not implemented yet';

  @override
  StreamSubscription<HttpRequest> listen(
      void Function(HttpRequest event) onData,
      {Function onError,
      void Function() onDone,
      bool cancelOnError}) {
    return requestCtlr.stream.listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  @override
  set sessionTimeout(int timeout) {
    // TODO: implement sessionTimeout
  }
}

class HttpConnectionMemory {}

class HttpDataMemory {
  final Map<int, HttpServerMemory> servers = {};
}

HttpDataMemory _httpDataMemory;

HttpDataMemory get httpDataMemory => _httpDataMemory ??= HttpDataMemory();

class HttpServerFactoryMemory extends HttpServerFactory {
  int lastPort = 0;

  @override
  Future<HttpServer> bind(address, int port) async {
    if (port == 0) {
      port = ++lastPort;
    }
    if (httpDataMemory.servers[port] != null) {
      throw Exception('port $port is busy');
    }
    var server = HttpServerMemory(port);
    httpDataMemory.servers[port] = server;
    return server;
  }
}

HttpServerFactoryMemory _httpServerFactoryMemory;

HttpServerFactoryMemory get httpServerFactoryMemory =>
    _httpServerFactoryMemory ??= HttpServerFactoryMemory();
