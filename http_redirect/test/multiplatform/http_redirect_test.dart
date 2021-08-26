import 'package:tekartik_http/http.dart';
import 'package:tekartik_http/http_memory.dart';
import 'package:tekartik_http_redirect/http_redirect.dart'; // ignore: deprecated_member_use_from_same_package
import 'package:test/test.dart';

void main() {
  run(httpFactory: httpFactoryMemory);
}

void run({
  HttpFactory? httpFactory,
  //HttpClientFactory? httpClientFactory,
  //HttpServerFactory? httpServerFactory,
  HttpFactory? testServerHttpFactory,
}) {
  var clientFactory = testServerHttpFactory?.client ?? httpFactory!.client;
  var serverFactory = httpFactory!.server;
  group('redirect', () {
    test('redirect', () async {
      var httpServer = await (testServerHttpFactory?.server ?? serverFactory)
          .bind(localhost, 0);

      httpServer.listen((HttpRequest request) {
        request.response
          ..write('tekartik_http_redirect')
          ..close();
      });
      var port = httpServer.port;
      //devPrint('port: $port');

      var httpRedirectServer = await HttpRedirectServer.startServer(
          httpClientFactory: testServerHttpFactory?.client ?? clientFactory,
          httpServerFactory: serverFactory,
          options: Options()
            ..host = localhost
            ..port = 0
            ..baseUrl = 'http://$localhost:$port');

      var client = clientFactory.newClient();
      var redirectPort = httpRedirectServer.port;
      //devPrint('redirectPort: $redirectPort');
      expect(port, isNot(redirectPort));
      expect(await client.read(Uri.parse('http://$localhost:$port')),
          'tekartik_http_redirect');
      client.close();

      await httpRedirectServer.close();
      await httpServer.close();
    });
  });
}
