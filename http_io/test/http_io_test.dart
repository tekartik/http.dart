// Copyright (c) 2017, Alexandre Roux. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

@TestOn('vm')
library tekartik_http_io.http_io_test;

import 'dart:convert';
import 'dart:io' as io;

import 'package:tekartik_http/http.dart';
import 'package:tekartik_http/http_test.dart';
import 'package:tekartik_http_io/http_io.dart';
import 'package:tekartik_http_test/http_test.dart';
import 'package:test/test.dart';
//import 'dart:io';

bool get runningOnTravis => io.Platform.environment['TRAVIS'] == 'true';

void main() {
  run(httpFactoryIo);

  test('connected', () async {
    var client = httpFactoryIo.client.newClient();
    var content = await client.read(Uri.parse('https://api.github.com'),
        headers: {'User-Agent': 'tekartik_http_node'});
    var map = jsonDecode(content) as Map;
    expect(map['current_user_url'], 'https://api.github.com/user');
  }, skip: runningOnTravis);

  test('server_any_ipv4', () async {
    var server = await httpFactoryIo.server.bind(InternetAddress.anyIPv4, 0);
    expect(server.uri.toString(), startsWith('http://localhost:'));
    expect(server.port, isNot(0));
    expect(server.address!.type, InternetAddressType.IPv4);
    expect(server.address!.address, '0.0.0.0');
    await server.close();
  });

  test('server_any', () async {
    var server =
        await httpFactoryIo.server.bind(InternetAddress.any, httpPortAny);
    expect(server.uri.toString(), startsWith('http://localhost:'));
    expect(server.port, isNot(0));
    expect(server.address!.address, '0.0.0.0');
    await server.close();
  });

  test('redirect', () async {
    var server = await httpFactoryIo.server.bind(InternetAddress.anyIPv4, 0);
    server.listen((request) async {
      await request.response.redirect(Uri.parse('https://www.google.com'));
    });
    var client = httpFactoryIo.client.newClient();
    var response =
        await client.get(Uri.parse('http://127.0.0.1:${server.port}'));
    // print(response.body);
    expect(response.statusCode, 200);
    client.close();
  });
}
