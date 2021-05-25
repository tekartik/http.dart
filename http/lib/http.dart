library tekartik_http;

import 'dart:typed_data';

import 'http_memory.dart';

export 'package:tekartik_http/src/http.dart';
export 'package:tekartik_http/src/http_constant.dart';

export 'http_client.dart';
export 'http_server.dart';
export 'src/http_common.dart' show parseUri;

/// Localhost.
const String localhost = 'localhost';

/// Use to dynamically assign a port
const int portDynamic = 0;

/// Http client and server factory.
abstract class HttpFactory {
  /// Http client factory.
  HttpClientFactory get client;

  /// Http server factory.
  HttpServerFactory get server;
}

/// Read a stream of bytes
Future<Uint8List> httpStreamGetBytes(Stream<Uint8List> stream) async {
  var bytes = Uint8List(0);
  await stream.listen((event) {
    bytes = Uint8List.fromList([...bytes, ...event]);
  }).asFuture();
  return bytes;
}
