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
      test('headers', () async {
        var headers = HttpHeadersMemory();
        expect(headers.toMap(), isEmpty);
        headers.set('name', 'value');
        headers.set('name2', ['value1', 'value2']);
        expect(headers.toMap(), {
          'name': ['value'],
          'name2': ['value1', 'value2']
        });
      });
    });
  });
}
