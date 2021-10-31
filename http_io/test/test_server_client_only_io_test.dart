// Copyright (c) 2017, Alexandre Roux. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:tekartik_http_io/http_client_io.dart';
import 'package:tekartik_http_test/test_server.dart';
import 'package:tekartik_http_test/test_server_client_test.dart';
import 'package:test/test.dart';

Future<void> main() async {
  var uri = Platform.environment[uriVarKey];
  // uri = 'http://localhost:8180';
  EchoServerClient? client;
  if (uri != null) {
    client =
        EchoServerClient(factory: httpClientFactoryIo, uri: Uri.parse(uri));
  }
  group('echo client', () {
    if (uri != null) {
      run(client!);
    }
    test('on', () {
      // fail('ok test running');
    });
  }, skip: uri == null ? 'skipped for no uri' : false);
}
