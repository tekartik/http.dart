import 'dart:typed_data';

import 'package:tekartik_common_utils/common_utils_import.dart';
import 'package:tekartik_http/http.dart';
import 'package:tekartik_http/src/http_client_memory.dart';
import 'package:tekartik_http/src/http_server.dart';
import 'package:tekartik_http/src/http_server_mixin.dart';
import 'package:tekartik_http/src/utils.dart';

/// get the body as bytes
Uint8List getBodyAsBytes(Object? body, {Encoding? encoding}) {
  List<int>? bytes;
  if (body is String) {
    bytes = utf8.encode(body);
  } else {
    bytes = body as List<int>?;
  }
  return asUint8List(bytes!);
}

/// Http server in memory
class HttpServerMemory extends Stream<HttpRequest>
    implements HttpServer, HttpServerWithUri {
  @override
  final int port;

  /*
  @override
  bool autoCompress;

  @override
  Duration idleTimeout;

  @override
  String serverHeader;
  */

  @override
  final InternetAddress? address;

  /// Create a new memory server
  HttpServerMemory(this.address, this.port);

  final _requestCtlr = StreamController<HttpRequest>();

  /// Add a request
  void addRequest(HttpRequestMemory request) {
    _requestCtlr.add(request);
  }

  @override
  Future close({bool force = false}) async {
    httpDataMemory.servers.remove(port);
    // This hangs if the server was not listened to
    // https://github.com/dart-lang/sdk/issues/19095
    _requestCtlr.close().unawait();
  }

  /*
  @override
  HttpConnectionsInfo connectionsInfo() => throw 'not implemented yet';

  // TODO: implement defaultResponseHeaders
  @override
  HttpHeaders get defaultResponseHeaders => throw 'not implemented yet';
  */
  @override
  StreamSubscription<HttpRequest> listen(
    void Function(HttpRequest event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return _requestCtlr.stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  Uri get uri => Uri.parse('http://_memory:$port/');

  /*
  @override
  set sessionTimeout(int timeout) {
    // TODO: implement sessionTimeout
  }
  */
}

/// Http connect in memory
class HttpConnectionMemory {}

/// Http data in memory
class HttpDataMemory {
  /// All servers
  final servers = <int, HttpServerMemory>{};
}

HttpDataMemory? _httpDataMemory;

/// Get the memory http data
HttpDataMemory get httpDataMemory => _httpDataMemory ??= HttpDataMemory();

/// Http server factory in memory
class HttpServerFactoryMemory extends HttpServerFactory {
  /// Last port used
  int lastPort = 0;

  @override
  Future<HttpServer> bind(address, int port) async {
    if (port == 0) {
      port = ++lastPort;
    }
    if (httpDataMemory.servers[port] != null) {
      throw Exception('port $port is busy');
    }
    InternetAddress? internetAddress;
    if (address is InternetAddress) {
      internetAddress = address;
    }
    var server = HttpServerMemory(internetAddress, port);
    httpDataMemory.servers[port] = server;
    return server;
  }
}

HttpServerFactoryMemory? _httpServerFactoryMemory;

/// Get the memory http server factory
HttpServerFactoryMemory get httpServerFactoryMemory =>
    _httpServerFactoryMemory ??= HttpServerFactoryMemory();
