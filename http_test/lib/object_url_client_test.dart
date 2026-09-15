// Copyright (c) 2017, Alexandre Roux. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.
// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:tekartik_http/http_client.dart';
import 'package:tekartik_http/http_memory.dart';
import 'package:test/test.dart';

void main() {
  runObjectUrlClientTests(httpClientFactoryMemory);
}

/// Object url (`blob:`) tests.
///
/// [httpClientFactory] must support object urls ([HttpObjectUrlFactory]):
/// browser and memory client factories do.
void runObjectUrlClientTests(HttpClientFactory httpClientFactory) {
  group('object_url', () {
    late HttpObjectUrlFactory objectUrlFactory;
    late http.Client client;
    setUpAll(() {
      objectUrlFactory = httpClientFactory.objectUrlFactory;
      client = httpClientFactory.newClient();
    });
    tearDownAll(() {
      client.close();
    });

    test('supportsObjectUrl', () {
      expect(httpClientFactory.supportsObjectUrl, isTrue);
    });

    test('scheme', () {
      var url = objectUrlFactory.createObjectUrl(Uint8List.fromList([1]));
      try {
        expect(url.scheme, httpSchemeBlob);
      } finally {
        objectUrlFactory.revokeObjectUrl(url);
      }
    });

    test('readBytes', () async {
      var bytes = Uint8List.fromList([1, 2, 3]);
      var url = objectUrlFactory.createObjectUrl(bytes);
      try {
        expect(await client.readBytes(url), [1, 2, 3]);
        // The content is a copy, modifying the source has no effect
        bytes[0] = 4;
        expect(await client.readBytes(url), [1, 2, 3]);
      } finally {
        objectUrlFactory.revokeObjectUrl(url);
      }
    });

    test('empty', () async {
      var url = objectUrlFactory.createObjectUrl(Uint8List(0));
      try {
        expect(await client.readBytes(url), isEmpty);
      } finally {
        objectUrlFactory.revokeObjectUrl(url);
      }
    });

    test('text and content type', () async {
      var url = objectUrlFactory.createObjectUrl(
        Uint8List.fromList(utf8.encode('héllo')),
        contentType: '$httpContentTypeText; $httpContentTypeCharsetUtf8',
      );
      try {
        expect(await client.read(url), 'héllo');

        var response = await httpClientSend(client, httpMethodGet, url);
        expect(response.statusCode, httpStatusCodeOk);
        expect(response.isSuccessful, isTrue);
        expect(response.body, 'héllo');
        expect(
          response.headers.value(httpHeaderContentType),
          startsWith(httpContentTypeText),
        );
      } finally {
        objectUrlFactory.revokeObjectUrl(url);
      }
    });

    test('revoked', () async {
      var url = objectUrlFactory.createObjectUrl(Uint8List.fromList([1]));
      objectUrlFactory.revokeObjectUrl(url);
      try {
        await client.readBytes(url);
        fail('should fail');
      } on http.ClientException catch (_) {}
      // Revoking twice is harmless
      objectUrlFactory.revokeObjectUrl(url);
    });

    test('post fails', () async {
      var url = objectUrlFactory.createObjectUrl(Uint8List.fromList([1]));
      try {
        await client.post(url, body: 'test');
        fail('should fail');
      } on http.ClientException catch (_) {
      } finally {
        objectUrlFactory.revokeObjectUrl(url);
      }
    });
  });
}
