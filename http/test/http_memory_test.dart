import 'dart:typed_data';

import 'package:http/http.dart' show ClientException;
import 'package:tekartik_http/http_memory.dart';
import 'package:tekartik_http/src/http_client_memory.dart'
    show HttpHeadersMemory, HttpRequestMemory;
import 'package:test/test.dart';

void main() {
  group('memory', () {
    group('object_url', () {
      test('create, read, revoke', () async {
        var factory = httpClientFactoryMemory;
        var objectUrlFactory = factory.objectUrlFactory;
        var url = objectUrlFactory.createObjectUrl(
          Uint8List.fromList([1, 2, 3]),
          contentType: httpContentTypeBytes,
        );
        expect(url.scheme, httpSchemeBlob);
        expect(url.toString(), startsWith('blob:http://$httpMemoryHost/'));
        var client = factory.newClient();
        expect(await client.readBytes(url), [1, 2, 3]);
        var response = await client.get(url);
        expect(response.statusCode, httpStatusCodeOk);
        expect(response.headers['content-type'], httpContentTypeBytes);
        expect(response.headers['content-length'], '3');

        objectUrlFactory.revokeObjectUrl(url);
        await expectLater(
          client.readBytes(url),
          throwsA(isA<ClientException>()),
        );
        client.close();
      });
      test('unique urls', () {
        var objectUrlFactory = httpClientFactoryMemory.objectUrlFactory;
        var url1 = objectUrlFactory.createObjectUrl(Uint8List(0));
        var url2 = objectUrlFactory.createObjectUrl(Uint8List(0));
        expect(url1, isNot(url2));
        objectUrlFactory.revokeObjectUrl(url1);
        objectUrlFactory.revokeObjectUrl(url2);
      });
    });
    group('server', () {
      test('address', () async {
        var server = await httpServerFactoryMemory.bind(
          InternetAddress.anyIPv4,
          1,
        );
        expect(server.address, InternetAddress.anyIPv4);
        var uri = httpServerGetUri(server);
        expect(uri.host, httpMemoryHost);
        await server.close();
      });
      test('headers', () async {
        var headers = HttpHeadersMemory();
        expect(headers.toMap(), isEmpty);
        headers.set('name', 'value');
        headers.set('name2', ['value1', 'value2']);
        expect(headers.toMap(), {
          'name': 'value',
          'name2': ['value1', 'value2'],
        });
      });
      test('request', () async {
        var request = HttpRequestMemory(
          'GET',
          Uri.parse('http://example.com/test'),
        );
        expect(request.method, 'GET');
        expect(request.uri, Uri.parse('http://example.com/test'));
        expect(request.requestedUri, Uri.parse('http://example.com/test'));
      });
    });
  });
}
