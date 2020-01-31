// Copyright (c) 2017, Alexandre Roux. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library tekartik_http.http_memory_test;

import 'package:tekartik_http/http_memory.dart';
import 'package:tekartik_http/http_test.dart';
import 'package:tekartik_http_test/http_test.dart';
import 'package:test/test.dart';

void main() {
  group('memory', () {
    run(httpFactoryMemory);

    group('server', () {
      test('address', () async {
        var server = await httpServerFactoryMemory.bind(InternetAddress.any, 1);
        expect(server.address, InternetAddress.anyIPv4);
        expect(server.uri, Uri.parse('http://_memory:1/'));
        expect(server.port, 1);
        await server.close();
      });
    });
  });
}
