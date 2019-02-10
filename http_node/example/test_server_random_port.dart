import 'dart:async';

import 'package:tekartik_http_node/http_server_node.dart';
import 'package:tekartik_http_test/test_server.dart' as test;

Future main() async {
  await test.serve(httpServerFactoryNode, 0);
}
