// Copyright (c) 2017, Alexandre Roux. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.
// ignore_for_file: depend_on_referenced_packages

import 'dart:typed_data';

import 'package:tekartik_common_utils/common_utils_import.dart';
import 'package:tekartik_http/http.dart';
import 'package:tekartik_http/http_memory.dart';
import 'package:tekartik_http_test/test_server_test.dart' as test_server;
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
      expect(await client.read(Uri.parse('http://$localhost:${server.port}')),
          'test');
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
    test('flush', () async {
      var server = await httpServerFactory.bind(localhost, 0);
      // print('### PORT ${server.port}');
      server.listen((request) async {
        request.response.write('test');
        await request.response.flush();
        await request.response.close();
      });
      var client = httpClientFactory.newClient();
      expect(await client.read(Uri.parse('http://$localhost:${server.port}')),
          'test');
      client.close();
      await server.close();
    });
    test('HttpRequest.toBytes', () async {
      var server = await httpServerFactory.bind(localhost, 0);
      // print('### PORT ${server.port}');
      server.listen((request) async {
        var bytes = await request.getBodyBytes();
        expect(utf8.decode(bytes), 'test');
        request.response.write('test');
        await request.response.flush();
        await request.response.close();
      });
      var client = httpClientFactory.newClient();
      expect(
          (await client.post(Uri.parse('http://$localhost:${server.port}'),
                  body: 'test'))
              .body,
          'test');
      client.close();
      await server.close();
    });
  });
  group(
    'http_client_response',
    () {
      late HttpServer server;
      late Client client;
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
            client, httpMethodGet, Uri.parse('$uri?statusCode=none'));
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
              client, httpMethodGet, Uri.parse('$uri?statusCode=200'));
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
              client, httpMethodGet, Uri.parse('$uri?statusCode=400'));
          expect(response.isSuccessful, isFalse);
          expect(response.statusCode, 400);
        },
      );

      test(
        'failure_throw',
        () async {
          var uri = httpServerGetUri(server);
          try {
            await httpClientSend(client, httpMethodGet,
                Uri.parse('$uri?statusCode=400&body=test'),
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

      test('httpClientRead1', () async {
        var uri = httpServerGetUri(server);
        var result = await httpClientRead(
            client, httpMethodGet, Uri.parse('$uri?statusCode=200&body=test'));
        expect(result, 'test');
      });

      test('httpClientRead2', () async {
        var uri = httpServerGetUri(server);
        try {
          await httpClientRead(client, httpMethodGet,
              Uri.parse('$uri?statusCode=400&body=test'));
          fail('should fail');
        } on HttpClientException catch (e) {
          expect(e.statusCode, 400);
          expect(e.response.statusCode, 400);
          expect(e.response.body, 'test');
        }
      });

      test('httpClientReadEncoding', () async {
        var uri = httpServerGetUri(server);
        var body = Uri.encodeComponent('é');
        var bytes = await httpClientReadBytes(
            client, httpMethodGet, Uri.parse('$uri?body=$body'));
        expect(bytes, [195, 169]);
        try {
          expect(
              await httpClientRead(
                  client, httpMethodGet, Uri.parse('$uri?body=$body')),
              'Ã©');
        } catch (_) {
          // failing on io...
          expect(
              await httpClientRead(
                  client, httpMethodGet, Uri.parse('$uri?body=$body')),
              'é');
        }
        expect(
            await httpClientRead(
                client, httpMethodGet, Uri.parse('$uri?body=$body'),
                responseEncoding: utf8),
            'é');
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
      var response = await client.get(
          Uri.parse('${httpServerGetUri(server)}/some_path#some_fragment'));
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
      var response = await client.post(Uri.parse('${httpServerGetUri(server)}'),
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
        expect(request.headers['x-test'], ['test_value']);
        expect(request.headers['X-Test'], ['test_value']);
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
      expect(response.headers['x-test'], 'test_value');
      expect(response.headers['X-Test'], 'test_value');
      client.close();
      await server.close();
    });
  });
  group('client_server', () {
    late HttpServer server;
    late Client client;

    var host = '127.0.0.1';
    late String url;
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
        if (body.isNotEmpty) {
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
      var response = await client.get(Uri.parse(url));
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
      var response = await client.post(Uri.parse(url), body: 'hello');
      expect(response.statusCode, 200);
      expect(response.contentLength, greaterThan(0));
      expect(response.body, equals('hello'));
      client.close();
    });

    test('make get request with library-level get method', () async {
      var client = httpClientFactory.newClient();
      var response = await client.get(Uri.parse(url));
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
      expect(await client.read(Uri.parse('http://$localhost:${server.port}')),
          'test\n');
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
      expect(await client.read(Uri.parse('http://$localhost:${server.port}')),
          'test,true,1');
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
      expect(await client.read(Uri.parse('http://$localhost:${server.port}')),
          'é');
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
    final bytes = await client.readBytes(Uri.parse(url));
    expect(bytes, const TypeMatcher<Uint8List>());

    client.close();
    await server.close();
  });

  test_server.run(httpFactory);
}
