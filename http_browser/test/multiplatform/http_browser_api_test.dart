@TestOn('vm || browser')
library tekartik_http_browser.test.http_browser_api_test;

// ignore: depend_on_referenced_packages
import 'package:tekartik_common_utils/env_utils.dart';
import 'package:tekartik_http_browser/http_client_browser.dart';
import 'package:test/test.dart';

Future main() async {
  group('http_browser_api', () {
    test('httpClientFactoryIo', () async {
      try {
        httpClientFactoryBrowser;
        expect(isRunningAsJavascript, isTrue);
      } on UnimplementedError catch (_) {}
    });
  });
}
