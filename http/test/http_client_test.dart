import 'package:tekartik_http/http_client.dart';
import 'package:test/test.dart';

void main() async {
  group('utils', () {
    test('isHttpClientSuccessful', () {
      expect(isHttpStatusCodeSuccessful(httpStatusCodeOk), isTrue);
      expect(isHttpStatusCodeSuccessful(httpStatusCodeNotFound), isFalse);
    });
  });
}
