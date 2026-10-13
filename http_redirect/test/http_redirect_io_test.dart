@TestOn('vm')
library;

import 'package:tekartik_http/http_memory.dart';
import 'package:tekartik_http_io/http_io.dart';
// ignore: deprecated_member_use_from_same_package
import 'package:tekartik_http_redirect/http_redirect.dart';
import 'package:test/test.dart';

import 'multiplatform/http_redirect_test.dart';

void main() {
  run(httpFactory: httpFactoryIo);
  run(httpFactory: httpFactoryIo, testServerHttpFactory: httpFactoryMemory);
  run(httpFactory: httpFactoryMemory, testServerHttpFactory: httpFactoryIo);

  test('legacy startServer', () async {
    var httpServer = await httpFactoryIo.server.bind(localhost, 0);
    httpServer.listen((request) {
      request.response
        ..write('legacy')
        ..close();
    });
    // ignore: deprecated_member_use_from_same_package
    var redirectServer = await startServer(
      httpFactoryIo.server,
      Options()
        ..host = localhost
        ..port = 0
        ..baseUrl = 'http://$localhost:${httpServer.port}',
    );
    var client = httpFactoryIo.client.newClient();
    expect(
      await client.read(Uri.parse('http://$localhost:${redirectServer.port}')),
      'legacy',
    );
    client.close();
    await redirectServer.close(force: true);
    await httpServer.close(force: true);
  });
}
