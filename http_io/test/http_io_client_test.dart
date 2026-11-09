// Copyright (c) 2017, Alexandre Roux. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

@TestOn('vm')
library;

import 'dart:convert';

import 'package:tekartik_http_io/http_client_io.dart';
import 'package:tekartik_http_io/http_io.dart';
import 'package:tekartik_http_test/http_test.dart';
import 'package:test/test.dart';

import 'http_io_test.dart' show connectedFixtureUri;

void main() {
  run(httpFactoryIo);

  test('object url not supported', () {
    expect(httpClientFactoryIo.supportsObjectUrl, isFalse);
    expect(() => httpClientFactoryIo.objectUrlFactory, throwsUnsupportedError);
  });

  // A real https download (static fixture), with and without the SSL check.
  test('https download', () async {
    for (var factory in [httpClientFactoryIo, httpClientFactoryIoNoSslCheck]) {
      var client = factory.newClient();
      try {
        var map = jsonDecode(await client.read(connectedFixtureUri)) as Map;
        expect(map['name'], 'tekartik_http_test');
      } finally {
        client.close();
      }
    }
  });
}
