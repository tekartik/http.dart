@TestOn('vm || browser')
library tekartik_http_node.test.http_node_api_test;

import 'package:tekartik_common_utils/env_utils.dart';
import 'package:tekartik_http_node/http_client_node.dart';
import 'package:tekartik_http_node/http_server_node.dart';
import 'package:tekartik_http_node/http_node.dart';
import 'package:tekartik_http_node/src/universal/universal.dart';
import 'package:test/test.dart';

Future main() async {
  group('http_node_api', () {
    test('multiplatform', () async {
      httpFactoryUniversal;
    });
    test('httpServerFactoryNode', () async {
      try {
        httpServerFactoryNode;
        expect(isRunningAsJavascript, isTrue);
      } on UnimplementedError catch (_) {}
    });
    test('httpClientFactoryNode', () async {
      try {
        httpClientFactoryNode;
        expect(isRunningAsJavascript, isTrue);
      } on UnimplementedError catch (_) {}
    });
    test('httpFactoryNode', () async {
      try {
        httpFactoryNode;
        expect(isRunningAsJavascript, isTrue);
      } on UnimplementedError catch (_) {}
    });
  });
}
