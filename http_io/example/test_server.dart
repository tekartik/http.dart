import 'dart:async';

import 'package:tekartik_http_io/http_server_io.dart';
import 'package:tekartik_http_test/test_server.dart' as test;

Future main() async {
  await test.echoServe(httpServerFactoryIo, 8181);
}
