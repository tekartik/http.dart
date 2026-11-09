import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tekartik_http/http.dart';
import 'package:tekartik_http/http_memory.dart';
import 'package:tekartik_http/src/http_server_memory.dart'
    show HttpServerFactoryMemory;
import 'package:test/test.dart';

void main() {
  group('review regression', () {
    test('HttpClientResponse.reasonPhrase comes from the response', () async {
      var client = MockClient(
        (request) async =>
            http.Response('nope', 404, reasonPhrase: 'Not Found'),
      );
      var response = await httpClientSend(
        client,
        httpMethodGet,
        Uri.parse('http://example.com/x'),
      );
      expect(response.reasonPhrase, 'Not Found');
      // Still settable
      response.reasonPhrase = 'other';
      expect(response.reasonPhrase, 'other');
      try {
        await httpClientRead(
          client,
          httpMethodGet,
          Uri.parse('http://example.com/x'),
        );
        fail('should fail');
      } on HttpClientException catch (e) {
        expect((e as http.ClientException).message, contains('Not Found'));
      }
    });

    test('httpClientRead error status without request', () async {
      // A streamed response with no request (MockClient.streaming lets the
      // handler build it).
      var client = MockClient.streaming(
        (request, body) async => http.StreamedResponse(Stream.value([]), 500),
      );
      var uri = Uri.parse('http://example.com/no_request');
      try {
        await httpClientRead(client, httpMethodGet, uri);
        fail('should fail');
      } on HttpClientException catch (e) {
        expect(e.statusCode, 500);
        expect((e as http.ClientException).uri, uri);
      }
    });

    test('memory server write non string object', () async {
      var server = await httpServerFactoryMemory.bind(localhost, 0);
      server.listen((request) async {
        request.response
          ..write(42)
          ..write(null)
          ..write(true)
          ..write('!');
        await request.response.close();
      });
      var client = httpClientFactoryMemory.newClient();
      expect(await client.read(httpServerGetUri(server)), '42nulltrue!');
      client.close();
      await server.close();
    }, timeout: const Timeout(Duration(seconds: 10)));

    test('memory headers contentType set to null removes it', () {
      var headers = HttpHeaders();
      headers.contentType = ContentType.parse('text/plain');
      expect(headers.value(httpHeaderContentType), 'text/plain');
      headers.contentType = null;
      expect(headers.value(httpHeaderContentType), isNull);
      expect(headers.contentType, isNull);
    });

    test('memory dynamic port skips a port already bound', () async {
      var factory = httpServerFactoryMemory as HttpServerFactoryMemory;
      var explicitPort = factory.lastPort + 1;
      var server1 = await factory.bind(localhost, explicitPort);
      var server2 = await factory.bind(localhost, 0);
      expect(server2.port, isNot(explicitPort));
      await server1.close();
      await server2.close();
    });
  });
}
