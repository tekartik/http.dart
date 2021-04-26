import 'package:tekartik_http/http.dart';
import 'package:tekartik_http/http_memory.dart';
import 'package:tekartik_http/http_server.dart';
import 'package:tekartik_http_redirect/http_redirect.dart';
import 'package:test/test.dart';

void main() {
  run(httpFactoryMemory);
}

void run(HttpFactory factory) {
  group('redirect', () {
    test('redirect', () async {
      var httpServer = await factory.server.bind(localhost, 0);

      httpServer.listen((HttpRequest request) {
        request.response
          ..write('tekartik_http_redirect')
          ..close();
      });
      var port = httpServer.port;
      //devPrint('port: $port');

      var httpRedirectServer = await startServer(
          factory.server,
          Options()
            ..host = localhost
            ..port = 0
            ..baseUrl = 'http://$localhost:$port');

      var client = factory.client.newClient();
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
