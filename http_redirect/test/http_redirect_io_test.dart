@TestOn('vm')
library tekartik_http_redirect.test.http_redirector_io_test;

import 'package:tekartik_http/http_memory.dart';
import 'package:tekartik_http_io/http_io.dart';
import 'package:test/test.dart';

import 'multiplatform/http_redirect_test.dart';

void main() {
  run(httpFactory: httpFactoryIo);
  run(httpFactory: httpFactoryIo, testServerHttpFactory: httpFactoryMemory);
  run(httpFactory: httpFactoryMemory, testServerHttpFactory: httpFactoryIo);
}
