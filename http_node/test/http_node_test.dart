@TestOn('node')
library tekartik_http_node.http_node_test;

import 'dart:convert';

import 'package:tekartik_http_node/http_node.dart';
import 'package:tekartik_http_test/http_test.dart';
import 'package:test/test.dart';
//import 'dart:node';

void main() {
  run(httpFactoryNode);
  test('connected', () async {
    var client = httpFactoryNode.client.newClient();
    var content = await client.read('https://api.github.com',
        headers: {'User-Agent': 'tekarik_http_node'});
    var map = jsonDecode(content);
    expect(map['current_user_url'], 'https://api.github.com/user');
  });
}
