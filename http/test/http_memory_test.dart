import 'package:tekartik_http/http_memory.dart';
import 'package:test/test.dart';

void main() {
  group('memory', () {
    group('server', () {
      test('address', () async {
        var server =
            await httpServerFactoryMemory.bind(InternetAddress.anyIPv4, 1);
        expect(server.address, InternetAddress.anyIPv4);
        var uri = httpServerGetUri(server);
        expect(uri.host, httpMemoryHost);
        await server.close();
      });
    });
  });
}
