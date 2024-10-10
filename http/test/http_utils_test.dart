// ignore_for_file: dead_code

import 'dart:convert';

import 'package:tekartik_http/http.dart';
import 'package:tekartik_http/http_utils.dart';
import 'package:test/test.dart';

void main() {
  group('functions', () {
    test('httpDataAsMapOrNull', () {
      expect(httpDataAsMapOrNull('{}'), isEmpty);
      expect(httpDataAsMapOrNull('{"test":1}'), {'test': 1});
      expect(httpDataAsMap('{"test":1}'), {'test': 1});
      expect(httpDataAsMapOrNull(''), null);
      expect(httpDataAsMapOrNull(null), null);
      expect(httpDataAsMapOrNull(<Object?>[]), null);
      expect(httpDataAsMapOrNull([1]), null);
      expect(httpDataAsMap(utf8.encode('{}')), isEmpty);
    });
    test('httpDataAsStringOrNull', () {
      expect(httpDataAsString('a'), 'a');
      expect(httpDataAsStringOrNull(null), null);
      expect(httpDataAsStringOrNull(true), 'true');
      expect(httpDataAsString(<Object?>[]), '[]');
      expect(httpDataAsString(<Object?>['a']), '["a"]');
      expect(httpDataAsString(<Map, Object?>{}), '{}');
    });
    test('api', () {
      Request? request;
      expect(request?.bodyAsMapOrNull, null);
      expect(request?.bodyAsMap, null);

      Response? response;
      expect(response?.bodyAsMapOrNull, null);
      expect(response?.bodyAsMap, null);

      HttpRequest? httpRequest;
      expect(httpRequest?.bodyAsMapOrNull, null);
      expect(httpRequest?.bodyAsMap, null);

      HttpClientResponse? clientResponse;
      expect(clientResponse?.bodyAsMapOrNull, null);
      expect(clientResponse?.bodyAsMap, null);
    });
  });
}
