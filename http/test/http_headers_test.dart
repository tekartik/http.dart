import 'package:tekartik_http/http_memory.dart';
import 'package:test/test.dart';

void main() {
  group('headers', () {
    test('headers', () {
      var headers = HttpHeaders();
      expect(headers.toMap(), isEmpty);
      headers.set('name', 'value');
      headers.set('name2', ['value1', 'value2']);
      expect(headers.toMap(), {
        'name': 'value',
        'name2': ['value1', 'value2'],
      });
      expect(headers.toStringMap(), {
        'name': 'value',
        'name2': 'value1, value2',
      });
      expect(headers.toListMap(), {
        'name': ['value'],
        'name2': ['value1', 'value2'],
      });
    });

    test('headers.fromMap', () {
      var headers = HttpHeaders.fromMap({
        'name': 'value',
        'name2': ['value1', 'value2'],
      });
      expect(headers.toMap(), {
        'name': 'value',
        'name2': ['value1', 'value2'],
      });
      headers = HttpHeaders.fromMap({
        'name': ['value'],
        'name2': ['value1', 'value2'],
      });
      expect(headers.toMap(), {
        'name': 'value',
        'name2': ['value1', 'value2'],
      });
    });
    test('mimeType', () {
      var headers = HttpHeaders();
      headers.mimeType = 'text/plain';
      expect(headers.mimeType, 'text/plain');
      headers.contentType = ContentType.parse('application/json');
      expect(headers.mimeType, 'application/json');
    });
  });
}
