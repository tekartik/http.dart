import 'package:tekartik_http/http_client.dart';
import 'package:test/test.dart';

class _NoObjectUrlClientFactory extends HttpClientFactory {
  @override
  Client newClient() => throw UnimplementedError();
}

void main() async {
  group('utils', () {
    test('isHttpClientSuccessful', () {
      expect(isHttpStatusCodeSuccessful(httpStatusCodeOk), isTrue);
      expect(isHttpStatusCodeSuccessful(httpStatusCodeNotFound), isFalse);
    });
  });
  group('object_url', () {
    test('unsupported', () {
      var factory = _NoObjectUrlClientFactory();
      expect(factory.supportsObjectUrl, isFalse);
      expect(() => factory.objectUrlFactory, throwsUnsupportedError);
    });
    test('memory', () {
      expect(httpClientFactoryMemory.supportsObjectUrl, isTrue);
      expect(httpClientFactoryMemory.objectUrlFactory, isNotNull);
    });
  });
}
