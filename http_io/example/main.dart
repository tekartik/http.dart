// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:tekartik_http_io/http_io.dart';

/// A JSON server and a client on the Dart VM (real sockets, free port).
Future<void> main() async {
  var server = await httpFactoryIo.server.bind(localhost, 0);
  server.listen((request) async {
    var body = utf8.decode(await request.getBodyBytes());
    request.response
      ..headers.contentType = ContentType.parse(httpContentTypeJson)
      ..write(jsonEncode({'path': request.uri.path, 'body': body}));
    await request.response.close();
  });

  var client = httpFactoryIo.client.newClient();
  try {
    var uri = httpServerGetUri(server).replace(path: 'echo');
    var response = await httpClientSend(
      client,
      httpMethodPost,
      uri,
      body: 'hello',
    );
    print(response.statusCode); // 200
    print(jsonDecode(response.body)); // {path: /echo, body: hello}
  } finally {
    client.close();
    await server.close();
  }
}
