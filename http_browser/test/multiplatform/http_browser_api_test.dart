@TestOn('vm || browser')
library;

// ignore: depend_on_referenced_packages
import 'package:tekartik_common_utils/env_utils.dart';
import 'package:tekartik_http_browser/http_client_browser.dart';
import 'package:test/test.dart';

Future main() async {
  group('http_browser_api', () {
    test('httpClientFactoryBrowser', () async {
      try {
        httpClientFactoryBrowser;
        expect(kDartIsWeb, isTrue);
      } on UnimplementedError catch (_) {}
    });
  });
}
