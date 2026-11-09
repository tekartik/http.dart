// ignore_for_file: avoid_print

/// A JSON handler and a client, served and called in memory.
///
/// The same `run` works on the VM with `httpFactoryIo`
/// (`package:tekartik_http_io/http_io.dart`).
library;

import 'dart:convert';

import 'package:tekartik_http/http.dart';
import 'package:tekartik_http/http_memory.dart';
import 'package:tekartik_http/http_utils.dart';

/// Answers `{"hello": "<path>"}` to any request.
Future<void> handleRequest(HttpRequest request) async {
  request.response
    ..statusCode = httpStatusCodeOk
    ..headers.set(httpHeaderContentType, httpContentTypeJson)
    ..write(jsonEncode({'hello': request.uri.path}));
  await request.response.close();
}

Future<void> run(HttpFactory factory) async {
  // Port 0: any free port, read it back from server.uri.
  var server = await factory.server.bind(localhost, 0);
  server.listen(handleRequest);

  var client = factory.client.newClient();
  try {
    var response = await httpClientSend(
      client,
      httpMethodGet,
      server.uri.replace(path: 'world'),
    );
    print(response.statusCode); // 200
    print(response.bodyAsMap); // {hello: /world}
  } finally {
    client.close();
    await server.close();
  }
}

Future<void> main() async {
  await run(httpFactoryMemory);
}
