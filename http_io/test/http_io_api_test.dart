@TestOn('vm || browser')
library;

// ignore: depend_on_referenced_packages
import 'package:tekartik_common_utils/env_utils.dart';
import 'package:tekartik_http_io/http_client_io.dart';
import 'package:tekartik_http_io/http_io.dart';
import 'package:tekartik_http_io/http_server_io.dart';
import 'package:test/test.dart';

Future main() async {
  group('http_io_api', () {
    test('httpServerFactoryIo', () async {
      try {
        httpServerFactoryIo;
        expect(isRunningAsJavascript, isFalse);
      } on UnimplementedError catch (_) {}
    });
    test('httpClientFactoryIo', () async {
      try {
        httpClientFactoryIo;
        expect(isRunningAsJavascript, isFalse);
      } on UnimplementedError catch (_) {}

      try {
        httpClientFactoryIoNoSslCheck;
        expect(isRunningAsJavascript, isFalse);
      } on UnimplementedError catch (_) {}
    });
    test('httpFactoryIo', () async {
      try {
        httpFactoryIo;
        expect(isRunningAsJavascript, isFalse);
      } on UnimplementedError catch (_) {}
    });
  });
}
