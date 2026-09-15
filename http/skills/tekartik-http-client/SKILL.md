---
name: tekartik-http-client
description: >-
  Use when sending HTTP requests from Dart with tekartik_http on any platform
  (VM, Flutter, browser, memory): HttpClientFactory.newClient(),
  httpClientSend, httpClientRead, httpClientReadBytes, HttpClientResponse,
  HttpClientException, throwOnFailure, BasicAuthClient, the httpMethod*,
  httpHeader*, httpContentType* and httpStatusCode* constants, the
  bodyAsMap/httpDataAsMap JSON helpers and object urls (blob:) through
  HttpObjectUrlFactory, createObjectUrl and revokeObjectUrl.
---

# tekartik_http client

`package:tekartik_http` puts `package:http` behind an `HttpClientFactory` so
the same code runs on the VM (`httpClientFactoryIo`, package
`tekartik_http_io`), in the browser (`httpClientFactoryBrowser`, package
`tekartik_http_browser`) and in tests (`httpClientFactoryMemory`, in this
package). `newClient()` returns a regular `package:http` `Client`; the helpers
below add typed responses, error handling and constants.

## Guidelines

* Import `package:tekartik_http/http_client.dart` (client only) or
  `package:tekartik_http/http.dart` (client + server, plus `localhost`,
  `localhostIpV4`, `portDynamic` and `HttpFactory`). Both re-export `Client`
  from `package:http`, the constants and the helpers;
  `package:tekartik_http/http_memory.dart` adds the memory factories but not
  `localhost`. Add `package:http` to the dependencies when using its other
  types (`Request`, `Response`, `ClientException`, `BaseClient`).
* Write functions that take an `HttpClientFactory` (or a `Client`) parameter
  and let the entry point pick the implementation. Never reference
  `httpClientFactoryIo` or `httpClientFactoryBrowser` from shared code: the
  getters throw `UnimplementedError` on the wrong platform.
* `factory.newClient()` creates a `Client`; keep one per logical session and
  `close()` it in a `finally`. Plain `package:http` calls work:
  `client.get(uri)`, `client.post(uri, body:, headers:)`, `client.read(uri)`,
  `client.readBytes(uri)`.
* Prefer the helpers for anything beyond a trivial call:
  - `httpClientSend(client, method, uri, {headers, body, encoding,
    throwOnFailure})` returns an `HttpClientResponse`: `statusCode`,
    `isSuccessful` (status < 400), `body`, `bodyBytes`, `headers`
    (case-insensitive `value(name)` and `[name]`), `bodyAsMap` /
    `bodyAsMapOrNull` (with `http_utils.dart`). It never throws on an HTTP
    error unless `throwOnFailure: true`.
  - `httpClientRead(client, method, uri, {headers, body, encoding,
    responseEncoding})` returns the body as a `String` and always throws
    `HttpClientException` on failure. Pass `responseEncoding: utf8` when the
    server sends no charset (the io client decodes latin1 by default).
  - `httpClientReadBytes(...)` returns a `Uint8List` and throws on failure.
* `body` accepts a `String`, a `List<int>` (sent as bytes) or a
  `Map<String, String>` (sent form url-encoded). JSON is encoded by hand:
  `body: jsonEncode(map)` with
  `headers: {httpHeaderContentType: httpContentTypeJson}`.
* Catch `HttpClientException` (`statusCode`, `response.body`,
  `response.headers`) for HTTP failures. Its implementation also extends
  `package:http`'s `ClientException`, so `on ClientException` catches both
  HTTP failures and network errors (closed client, CORS, DNS).
* Use the constants instead of literals: methods `httpMethodGet`,
  `httpMethodPost`, `httpMethodPut`, `httpMethodPatch`, `httpMethodDelete`,
  `httpMethodHead`, `httpMethodOptions`; headers `httpHeaderContentType`,
  `httpHeaderAuthorization`, `httpHeaderAccept`, `httpHeaderUserAgent`,
  `httpHeaderAcceptEncoding`, `httpHeaderContentEncoding`,
  `httpAccessControlAllowOrigin` and the other `httpAccessControl*`; content
  types `httpContentTypeJson`, `httpContentTypeText`, `httpContentTypeHtml`,
  `httpContentTypeHtmlStrict` (with utf-8 charset), `httpContentTypeBytes`,
  `httpContentTypeWwwFormUrlEncoded`, `httpContentTypeCharsetUtf8`; status
  codes `httpStatusCodeOk`, `httpStatusCodeBadRequest`,
  `httpStatusCodeUnauthorized`, `httpStatusCodeForbidden`,
  `httpStatusCodeNotFound`, `httpStatusCodeRequestTimeout`,
  `httpStatusCodeInternalServerError`, `httpStatusCodeServiceUnavailable`;
  schemes `httpSchemeHttp`, `httpSchemeHttps`, `httpSchemeBlob`;
  `isHttpStatusCodeSuccessful(code)`.
* JSON helpers in `package:tekartik_http/http_utils.dart`: `bodyAsMap` /
  `bodyAsMapOrNull` on `http.Response`, `http.Request`, `HttpClientResponse`
  (and on the server `HttpRequest`); `httpDataAsMap(data)`,
  `httpDataAsMapOrNull`, `httpDataAsString`, `httpDataAsStringOrNull` decode
  a `String`, `Uint8List`, `Map` or `List`. `copyRequest({url})` on a
  `BaseRequest` and `copyWithBytes(bytes)` on `Response` /
  `StreamedResponse` duplicate an already consumed request or response
  (interceptors, retries).
* Basic auth: `BasicAuthClient(username, password, {inner})` from
  `package:tekartik_http/basic_auth_client.dart` wraps a client and adds the
  `Authorization` header to every request; `close()` closes the inner client
  only when `BasicAuthClient` created it.
* Object urls (`blob:`): a factory implementing `HttpObjectUrlFactory`
  (browser and memory) turns in-memory bytes into a url that its own clients
  read with GET. Check `factory.supportsObjectUrl`, then
  `factory.objectUrlFactory.createObjectUrl(bytes, contentType: 'image/png')`
  and `revokeObjectUrl(url)` once consumed (the bytes are retained until
  then). Any method other than GET, or a revoked url, fails with a
  `ClientException`. Not available on io (`supportsObjectUrl` is false,
  `objectUrlFactory` throws `UnsupportedError`).
* Testing: `httpClientFactoryMemory` only reaches servers bound with
  `httpServerFactoryMemory` in the same isolate (urls `http://_memory:<port>/`,
  see the `tekartik-http-server` skill) and memory object urls; any other
  url throws. `HttpClientMixin` (`http_memory.dart`) helps writing a fake
  `Client` by implementing `httpCall` / `httpSend`.
* `parseUri(dynamic)` accepts a `String` or a `Uri`;
  `httpStreamGetBytes(stream)` collects a `Stream<Uint8List>`.

## Examples

### Shared API client, implementation injected

```dart
import 'dart:convert';

import 'package:tekartik_http/http_client.dart';
import 'package:tekartik_http/http_utils.dart';

class ApiClient {
  final Client client;
  final Uri baseUri;

  ApiClient(HttpClientFactory factory, this.baseUri)
    : client = factory.newClient();

  Future<Map<String, Object?>> getJson(String path) async {
    var response = await httpClientSend(
      client,
      httpMethodGet,
      baseUri.resolve(path),
      headers: {httpHeaderAccept: httpContentTypeJson},
      throwOnFailure: true,
    );
    return response.bodyAsMap;
  }

  Future<Map<String, Object?>> postJson(
    String path,
    Map<String, Object?> data,
  ) async {
    var text = await httpClientRead(
      client,
      httpMethodPost,
      baseUri.resolve(path),
      headers: {httpHeaderContentType: httpContentTypeJson},
      body: jsonEncode(data),
      responseEncoding: utf8,
    );
    return httpDataAsMap(text);
  }

  void close() => client.close();
}
```

Entry points: `ApiClient(httpClientFactoryIo, uri)` on the VM
(`package:tekartik_http_io/http_client_io.dart`),
`ApiClient(httpClientFactoryBrowser, uri)` in the browser
(`package:tekartik_http_browser/http_client_browser.dart`),
`ApiClient(httpClientFactoryMemory, uri)` in tests.

### Handling failures

```dart
import 'package:http/http.dart' show ClientException;
import 'package:tekartik_http/http_client.dart';

Future<String?> fetchOrNull(Client client, Uri uri) async {
  try {
    return await httpClientRead(client, httpMethodGet, uri);
  } on HttpClientException catch (e) {
    // HTTP error, the response is available
    if (e.statusCode == httpStatusCodeNotFound) {
      return null;
    }
    print('HTTP ${e.statusCode}: ${e.response.body}');
    rethrow;
  } on ClientException catch (e) {
    // Network error, closed client, CORS...
    print('network error $e');
    rethrow;
  }
}
```

### Download bytes and inspect the headers

```dart
import 'package:tekartik_http/http_client.dart';

Future<void> download(HttpClientFactory factory, Uri uri) async {
  var client = factory.newClient();
  try {
    var response = await httpClientSend(client, httpMethodGet, uri);
    if (!response.isSuccessful) {
      throw StateError('failed ${response.statusCode}');
    }
    var mimeType = response.headers.value(httpHeaderContentType);
    var bytes = response.bodyBytes;
    print('$mimeType ${bytes.length} bytes');
  } finally {
    client.close();
  }
}
```

### Basic authentication

```dart
import 'package:tekartik_http/basic_auth_client.dart';
import 'package:tekartik_http/http_client.dart';

Future<String> readProtected(HttpClientFactory factory, Uri uri) async {
  var client = BasicAuthClient('user', 'secret', inner: factory.newClient());
  try {
    return await httpClientRead(client, httpMethodGet, uri);
  } finally {
    client.close(); // closes the inner client too
  }
}
```

### Object url (blob:) on the browser or in memory

```dart
import 'dart:typed_data';

import 'package:tekartik_http/http_client.dart';

Future<Uint8List> roundTrip(HttpClientFactory factory, Uint8List bytes) async {
  if (!factory.supportsObjectUrl) {
    throw UnsupportedError('object url not supported (io?)');
  }
  var objectUrlFactory = factory.objectUrlFactory;
  var url = objectUrlFactory.createObjectUrl(bytes, contentType: 'image/png');
  try {
    var client = factory.newClient();
    try {
      return await client.readBytes(url); // GET only
    } finally {
      client.close();
    }
  } finally {
    objectUrlFactory.revokeObjectUrl(url);
  }
}
```

### Test with the memory implementation

```dart
import 'package:tekartik_http/http.dart'; // localhost
import 'package:tekartik_http/http_memory.dart';
import 'package:tekartik_http/http_utils.dart';
import 'package:test/test.dart';

void main() {
  test('api', () async {
    var server = await httpServerFactoryMemory.bind(localhost, 0);
    server.listen((request) {
      request.response.headers.set(httpHeaderContentType, httpContentTypeJson);
      request.response.write('{"ok":true}');
      request.response.close();
    });
    var client = httpClientFactoryMemory.newClient();
    var response = await httpClientSend(client, httpMethodGet, server.uri);
    expect(response.bodyAsMap, {'ok': true});
    client.close();
    await server.close();
  });
}
```

## Common mistakes

* Referencing `httpClientFactoryIo` in code shared with the web (or
  `httpClientFactoryBrowser` in VM code): inject the factory instead.
* Forgetting `client.close()`; in the browser it also aborts in-flight
  requests, so do not close a client shared by pending calls.
* Expecting `httpClientSend` to throw on a 404: it returns the response
  unless `throwOnFailure: true`; `httpClientRead` and `httpClientReadBytes`
  always throw.
* Passing a `Map` body expecting JSON: it is sent form-encoded.
  `jsonEncode` it and set `httpHeaderContentType`.
* Using the memory client against an io server or the io client against a
  memory server: they only see their own implementation.
* Creating object urls without revoking them.
