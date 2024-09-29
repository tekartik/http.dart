// Copyright (c) 2017, Alexandre Roux. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library;

import 'package:tekartik_http/http_memory.dart';
import 'package:tekartik_http_test/http_test.dart';
import 'package:test/test.dart';

void main() {
  group('memory', () {
    run(httpFactoryMemory);

    group('server', () {
      test('address', () async {
        var server =
            await httpServerFactoryMemory.bind(InternetAddress.anyIPv4, 1);
        expect(server.address, InternetAddress.anyIPv4);
        expect(httpServerGetUri(server), Uri.parse('http://_memory:1/'));
        await server.close();
      });
    });
  });
}
