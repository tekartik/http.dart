// Copyright (c) 2017, Alexandre Roux. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

@TestOn('vm')
library tekartik_http_io.http_io_test;

import 'dart:convert';

import 'package:tekartik_http/http.dart';
import 'package:tekartik_http_io/http_io.dart';
import 'package:tekartik_http_test/http_test.dart';
import 'package:test/test.dart';
//import 'dart:io';

void main() {
  run(httpFactoryIo);

  test('connected', () async {
    var client = httpFactoryIo.client.newClient();
    // Somehow user agent is required starting with Travis on travis...
    // See <https://github.com/travis-ci/travis-ci/issues/5649>
    var content = await client.read('https://api.github.com',
        headers: {httpHeaderUserAgent: 'Travis/1.0'});
    var map = jsonDecode(content);
    expect(map['current_user_url'], 'https://api.github.com/user');
  });
}
