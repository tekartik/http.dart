// Copyright (c) 2017, Alexandre Roux. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart';
import 'package:tekartik_common_utils/common_utils_import.dart';
import 'package:tekartik_http/http.dart';
import 'package:tekartik_http/http_client.dart';
import 'package:tekartik_http/http_memory.dart';
import 'package:tekartik_http/http_server.dart';
import 'package:test/test.dart';

void main() {
  run(httpFactoryMemory);
}

void run(HttpFactory httpFactory) {
  final httpClientFactory = httpFactory.client;
  final httpServerFactory = httpFactory.server;
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

  group('server', () {
    test('address', () async {
      var server = await httpServerFactory.bind(InternetAddress.anyIPv4, 0);
      expect(server.address, isNotNull);
      expect(server.port, isNotNull);
      expect(server.port, isNot(0));
      await server.close();
    });
  });
  group(
    'http_client_response',
    () {
      HttpServer server;
      Client client;
      setUpAll(() async {
        server = await httpServerFactory.bind(localhost, 0);
        server.listen((request) async {
          var statusCode = parseInt(request.uri.queryParameters['statusCode']);
          var body = request.uri.queryParameters['body'];
          if (statusCode != null) {
            request.response.statusCode = statusCode;
          }
          if (body != null) {
            request.response.write(body);
          }

          await request.response.close();
        });
        client = httpClientFactory.newClient();
      });

      test('httpServerGetUri', () async {
        var uri = httpServerGetUri(server);
        // expect(uri.toString().startsWith('http://_memory:'), isTrue);
        expect(uri.toString().startsWith('http://'), isTrue);
      });

      test('defaultStatusCode', () async {
        var uri = httpServerGetUri(server);
        //var response = await client.get('http://localhost:8181/?statusCode=200');
        // devPrint(uri);
        //var response = await client.get('${uri}/?statusCode=200');

        var response = await httpClientSend(
            client, httpMethodGet, '${uri}?statusCode=none');
        expect(response.isSuccessful, isTrue);

        expect(response.statusCode, 200);
        //expect(response.toString(), startsWith('HTTP 200'));
        expect(response.toString(), startsWith('HTTP 200'));
      });
      test(
        'success',
        () async {
          var uri = httpServerGetUri(server);
          //var response = await client.get('http://localhost:8181/?statusCode=200');
          // devPrint(uri);
          //var response = await client.get('${uri}/?statusCode=200');

          var response = await httpClientSend(
              client, httpMethodGet, '${uri}?statusCode=200');
          expect(response.isSuccessful, isTrue);

          expect(response.toString().startsWith('HTTP 200 size 0 headers '),
              isTrue); // 0');
        },
      );

      test(
        'failure',
        () async {
          var uri = httpServerGetUri(server);
          var response = await httpClientSend(
              client, httpMethodGet, '${uri}?statusCode=400');
          expect(response.isSuccessful, isFalse);
          expect(response.statusCode, 400);
        },
      );

      test(
        'failure_throw',
        () async {
          var uri = httpServerGetUri(server);
          try {
            await httpClientSend(
                client, httpMethodGet, '${uri}?statusCode=400&body=test',
                throwOnFailure: true);
            fail('should fail');
          } on HttpClientException catch (e) {
            expect(e.statusCode, 400);
            expect(e.response.statusCode, 400);
            expect(e.response.body, 'test');
          }
        },
      );

      test('port', () async {
        var server1 =
            await httpServerFactory.bind(InternetAddress.any, httpPortAny);
        var port1 = server1.port;
        var server2 =
            await httpServerFactory.bind(InternetAddress.any, httpPortAny);
        var port2 = server2.port;
        expect(port1, isNot(port2));
      });

      test('httpClientRead', () async {
        var uri = httpServerGetUri(server);
        var result = await httpClientRead(
            client, httpMethodGet, '${uri}?statusCode=200&body=test');
        expect(result, 'test');
      });

      test('httpClientRead', () async {
        var uri = httpServerGetUri(server);
        try {
          await httpClientRead(
              client, httpMethodGet, '${uri}?statusCode=400&body=test');
          fail('should fail');
        } on HttpClientException catch (e) {
          expect(e.statusCode, 400);
          expect(e.response.statusCode, 400);
          expect(e.response.body, 'test');
        }
      });
      tearDownAll(() async {
        client.close();
        await server.close();
      });
    },
  );

  group('server_request_fragment', () {
    test('fragment', () async {
      var server = await httpServerFactory.bind(InternetAddress.anyIPv4, 0);
      server.listen((request) async {
        request.response.write(request.uri.fragment);
        await request.response.close();
      });
      var client = httpClientFactory.newClient();
      var response = await client
          .get('${httpServerGetUri(server)}/some_path#some_fragment');
      expect(response.body, '');
      expect(response.statusCode, 200);
      client.close();
      await server.close();
    });
  });

  group('server_request_bytes_response_bytes', () {
    test('fragment', () async {
      var server = await httpServerFactory.bind(localhost, 0);
      server.listen((request) async {
        var bytes = await httpStreamGetBytes(request);
        request.response.add(bytes);
        await request.response.close();
      });
      var client = httpClientFactory.newClient();
      var response = await client.post('${httpServerGetUri(server)}',
          body: Uint8List.fromList([1, 2, 3]));
      expect(response.bodyBytes, [1, 2, 3]);
      expect(response.statusCode, 200);
      client.close();
      await server.close();
    });
  });

  group('server_request_response_headers', () {
    test('headers', () async {
      var server = await httpServerFactory.bind(InternetAddress.anyIPv4, 0);
      server.listen((request) async {
        expect(request.headers.value('x-test'), 'test_value');
        expect(request.headers.value('X-Test'), 'test_value');
        request.response.headers.set('x-test', 'test_value');
        request.response.statusCode = 200;
        await request.response.close();
      });
      var client = httpClientFactory.newClient();
      var response = await httpClientSend(client, httpMethodGet,
          httpServerGetUri(server), // 'http://127.0.0.1:${server.port}',
          //var response = await client.get('http://127.0.0.1:${server.port}',
          headers: <String, String>{'x-test': 'test_value'});
      expect(response.statusCode, 200);
      expect(response.headers.value('x-test'), 'test_value');
      expect(response.headers.value('X-Test'), 'test_value');
      client.close();
      await server.close();
    });
  });
  group('client_server', () {
    HttpServer server;
    Client client;

    var host = '127.0.0.1';
    String url;
    setUpAll(() async {
      server = await httpServerFactory.bind(host, 0);
      url = 'http://$host:${server.port}';

      server.listen((request) async {
        final body = await utf8.decoder.bind(request).join();
        request.response.headers.contentType =
            ContentType.parse(httpContentTypeText);
        request.response.headers.set('X-Foo', 'bar');
        request.response.headers.set(
            'set-cookie', ['JSESSIONID=verylongid; Path=/somepath; HttpOnly']);
        request.response.statusCode = 200;
        // devPrint('body ${body} ${body.length}');
        if (body != null && body.isNotEmpty) {
          request.response.write(body);
        } else {
          request.response.write('ok');
        }
        await request.response.close();
      });
      client = httpClientFactory.newClient();
    });

    tearDownAll(() async {
      client.close();
      await server.close();
    });

    test('make get request', () async {
      var client = httpClientFactory.newClient();
      var response = await client.get(url);
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
      var response = await client.post(url, body: 'hello');
      expect(response.statusCode, 200);
      expect(response.contentLength, greaterThan(0));
      expect(response.body, equals('hello'));
      client.close();
    });

    test('make get request with library-level get method', () async {
      var client = httpClientFactory.newClient();
      var response = await client.get(url);
      // devPrint(response.headers);
      expect(response.statusCode, 200);
      expect(response.contentLength, greaterThan(0));
      expect(response.body, equals('ok'));
      expect(response.headers, contains('content-type'));
      expect(response.headers['set-cookie'],
          'JSESSIONID=verylongid; Path=/somepath; HttpOnly');
      client.close();
    });
  });

  group('response_io_sink', () {
    test('writeln', () async {
      var server = await httpServerFactory.bind(localhost, 0);
      server.listen((request) {
        request.response
          ..writeln('test')
          ..close();
      });
      var client = httpClientFactory.newClient();
      expect(await client.read('http://$localhost:${server.port}'), 'test\n');
      client.close();
      await server.close();
    });

    test('writeAll', () async {
      var server = await httpServerFactory.bind(localhost, 0);
      server.listen((request) {
        request.response
          ..writeAll(['test', true, 1], ',')
          ..close();
      });
      var client = httpClientFactory.newClient();
      expect(
          await client.read('http://$localhost:${server.port}'), 'test,true,1');
      client.close();
      await server.close();
    });

    // This fails on node
    test('writeCharCode', () async {
      var server = await httpServerFactory.bind(localhost, 0);
      server.listen((request) {
        request.response
          ..writeCharCode('é'.codeUnitAt(0))
          ..close();
      });
      var client = httpClientFactory.newClient();
      expect(await client.read('http://$localhost:${server.port}'), 'é');
      client.close();
      await server.close();
    }, skip: true);
  });

  test('response_stream', () async {
    var server = await httpServerFactory.bind(localhost, 0);
    server.listen((request) {
      request.response
        ..write('abc')
        ..close();
    });
    var client = httpClientFactory.newClient();
    var url = 'http://$localhost:${server.port}';
    final bytes = await client.readBytes(url);
    expect(bytes, const TypeMatcher<Uint8List>());

    client.close();
    await server.close();
  });
}
