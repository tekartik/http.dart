@TestOn('vm')
library;

import 'package:async/async.dart';
import 'package:http/http.dart' as http;
import 'package:stream_channel/stream_channel.dart';
import 'package:tekartik_http_io/http_client_io.dart';
import 'package:tekartik_http_test/src/echo_server.dart';
import 'package:test/test.dart';

void main() {
  runEchoServerClientTests(httpClientFactoryIo);
}

void runEchoServerClientTests(HttpClientFactory httpClientFactory) {
  group('echo_server_client_test', () {
    late final Uri uri;
    late final StreamChannel<Object?> httpServerChannel;
    late final StreamQueue<Object?> httpServerQueue;
    late http.Client client;
    setUpAll(() async {
      httpServerChannel = await startServer();
      httpServerQueue = StreamQueue(httpServerChannel.stream);
      var host = 'localhost:${await httpServerQueue.nextAsInt}';
      uri = Uri.http(host);
      client = httpClientFactory.newClient();
    });
    tearDownAll(() => httpServerChannel.sink.add(null));

    test('body param', () async {
      expect(
        await client.read(uri.replace(queryParameters: {'body': 'test'})),
        'test',
      );
    });
    test('body content', () async {
      expect(
        await httpClientRead(
          client,
          httpMethodPost,
          uri.replace(queryParameters: {'use_body': 'true'}),
          body: 'test',
        ),
        'test',
      );
    });
    test('get header', () async {
      var text = await httpClientRead(
        client,
        httpMethodPost,
        uri.replace(queryParameters: {'header_get_demo': 'true'}),
        headers: {'x-demo': 'true'},
      );
      expect(text, 'true');
    });
    test('set header', () async {
      var response = await httpClientSend(
        client,
        httpMethodPost,
        uri.replace(queryParameters: {'header_set_demo': 'true'}),
      );
      print(response.headers);
      expect(response.headers['x-demo'], 'true');
    });
  });
}
