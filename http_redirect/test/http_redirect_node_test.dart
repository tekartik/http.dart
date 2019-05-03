@TestOn('node')
library tekartik_http_redirect.test.http_redirector_node_test;

import 'package:tekartik_http_node/http_node.dart';
import 'package:test/test.dart';

import 'http_redirect_test.dart';

void main() {
  run(httpFactoryNode);
}
