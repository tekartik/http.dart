// Copyright (c) 2017, Alexandre Roux. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

@TestOn('vm')
library tekartik_http_io.http_io_test;

import 'dart:convert';
import 'dart:io';

import 'package:tekartik_http_io/http_io.dart';
import 'package:tekartik_http_test/http_test.dart';
import 'package:test/test.dart';
//import 'dart:io';

bool get runningOnTravis => Platform.environment['TRAVIS'] == "true";

void main() {
  run(httpFactoryIo);

  test('connected', () async {
    var client = httpFactoryIo.client.newClient();
    var content = await client.read('https://api.github.com',
        headers: {'User-Agent': 'tekartik_http_node'});
    var map = jsonDecode(content);
    expect(map['current_user_url'], 'https://api.github.com/user');
  }, skip: runningOnTravis);
}
