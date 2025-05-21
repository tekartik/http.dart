// Copyright (c) 2017, Alexandre Roux. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:tekartik_http/http.dart';
import 'package:tekartik_http/http_memory.dart';
import 'package:tekartik_http_test/test_server.dart';
import 'package:test/test.dart';

void main() {
  run(httpFactoryMemory);
}

void run(HttpFactory httpFactory) {
  final httpClientFactory = httpFactory.client;
  final httpServerFactory = httpFactory.server;
  group('test_server', () {
    HttpServerState? echoServeState;
    late Uri uri;
    late EchoServerClient client;
    setUpAll(() async {
      echoServeState = await echoServe(httpServerFactory, 0);
      uri = echoServeState!.uri;
      client = EchoServerClient(factory: httpClientFactory, uri: uri);
    });
    tearDownAll(() async {
      await echoServeState?.close();
      try {
        await client.ping();
        fail('unexpected ping success');
      } catch (e) {
        // fail('expected ping error');
      }
    });
    test('body param', () async {
      expect(
        await client.read(uri.replace(queryParameters: {'body': 'test'})),
        'test',
      );
    });
    test('body content', () async {
      expect(
        await httpClientRead(
          client.client,
          httpMethodPost,
          uri.replace(queryParameters: {'use_body': 'true'}),
          body: 'test',
        ),
        'test',
      );
    });
    test('get header', () async {
      var text = await httpClientRead(
        client.client,
        httpMethodPost,
        uri.replace(queryParameters: {'header_get_demo': 'true'}),
        headers: {'x-demo': 'true'},
      );
      expect(text, 'true');
    });
    test('set header', () async {
      var response = await httpClientSend(
        client.client,
        httpMethodPost,
        uri.replace(queryParameters: {'header_set_demo': 'true'}),
      );
      expect(response.headers['x-demo'], 'true');
    });
    test('ping', () async {
      await client.ping();
    });
  });
}
