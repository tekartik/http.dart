// Copyright (c) 2017, Alexandre Roux. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.
@TestOn('browser')
library tekartik_http.http_browser_test;

import 'package:tekartik_http_browser/http_client_browser.dart';
import 'package:tekartik_http_test/echo_server_client_test.dart';
import 'package:test/test.dart';

void main() {
  runEchoServerClientTests(httpClientFactoryBrowser);
  test('client', () {
    var client = httpClientFactoryBrowser.newClient();
    expect(client, isNotNull);
    client.close();
  });
}
