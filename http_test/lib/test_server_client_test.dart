// Copyright (c) 2017, Alexandre Roux. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:tekartik_http/http_memory.dart';
import 'package:tekartik_http_test/test_server.dart';
import 'package:test/test.dart';

var uriVarKey = 'TEKARTIK_HTTP_TEST_SERVER_URI';

Future<void> main() async {
  var factory = httpFactoryMemory;
  late Uri uri;
  late EchoServerClient client;
  var echoServeState = await echoServe(factory.server, 0);
  uri = echoServeState.uri;
  client = EchoServerClient(factory: factory.client, uri: uri);

  tearDownAll(() async {
    await echoServeState.close();
    try {
      await client.ping();
      fail('unexpected ping success');
    } catch (e) {
      // fail('expected ping error');
    }
  });

  run(client);
}

void run(EchoServerClient client) {
  var uri = client.uri;
  group('test_server', () {
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
