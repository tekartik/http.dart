// Copyright (c) 2017, Alexandre Roux. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:tekartik_http/http.dart';
import 'package:test/test.dart';
import 'package:tekartik_http/http_server.dart';
import 'package:tekartik_http/http_client.dart';

void run(HttpFactory httpFactory) {
  final HttpClientFactory httpClientFactory = httpFactory.client;
  final HttpServerFactory httpServerFactory = httpFactory.server;
  group('demo', () {
    test('localhost', () async {
      var server = await httpServerFactory.bind(localhost, 0);
      // print('### PORT ${server.port}');
      server.listen((request) {
        request.response
          ..write('test')
          ..close();
      });
      var client = httpClientFactory.newClient();
      expect(await client.read('http://$localhost:${server.port}'), 'test');
      client.close();
      await server.close();
    });
  });
  group('client_server', () {
    HttpServer server;

    setUpAll(() async {
      server = await httpServerFactory.bind('127.0.0.1', 8181);
      server.listen((request) async {
        String body = await request.map(utf8.decode).join();
        request.response.headers.contentType = ContentType.text;
        request.response.headers.set('X-Foo', 'bar');
        request.response.headers.set(
            'set-cookie', ['JSESSIONID=verylongid; Path=/somepath; HttpOnly']);
        request.response.statusCode = 200;
        if (body != null && body.isNotEmpty) {
          request.response.write(body);
        } else {
          request.response.write('ok');
        }
        request.response.close();
      });
    });

    tearDownAll(() async {
      await server.close();
    });

    test('make get request', () async {
      var client = httpClientFactory.newClient();
      var response = await client.get('http://127.0.0.1:8181/test');
      expect(response.statusCode, 200);
      expect(response.contentLength, greaterThan(0));
      expect(response.body, equals('ok'));
      expect(response.headers, contains('content-type'));
      expect(response.headers['set-cookie'],
          'JSESSIONID=verylongid; Path=/somepath; HttpOnly');
      client.close();
    });

    test('make post request with a body', () async {
      var client = httpClientFactory.newClient();
      var response =
          await client.post('http://127.0.0.1:8181/test', body: 'hello');
      expect(response.statusCode, 200);
      expect(response.contentLength, greaterThan(0));
      expect(response.body, equals('hello'));
      client.close();
    });

    test('make get request with library-level get method', () async {
      var client = httpClientFactory.newClient();
      var response = await client.get('http://127.0.0.1:8181/test');
      expect(response.statusCode, 200);
      expect(response.contentLength, greaterThan(0));
      expect(response.body, equals('ok'));
      expect(response.headers, contains('content-type'));
      expect(response.headers['set-cookie'],
          'JSESSIONID=verylongid; Path=/somepath; HttpOnly');
      client.close();
    });
  });
}
