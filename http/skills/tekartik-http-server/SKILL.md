---
name: tekartik-http-server
description: >-
  Use when writing a portable HTTP server or request handler in Dart with
  tekartik_http: HttpServerFactory.bind, HttpServer, HttpRequest,
  HttpResponse, HttpHeaders, ContentType, httpServerGetUri and server.uri,
  getBodyBytes, bodyAsMap, handleCors, InternetAddress, localhost, and testing
  handlers with the in-memory httpServerFactoryMemory / httpFactoryMemory
  (HttpFactory) before running them on io.
---

# tekartik_http server

A `dart:io`-like server API (`HttpServer`, `HttpRequest`, `HttpResponse`,
`HttpHeaders`, `ContentType`, `InternetAddress`) that does not import
`dart:io`, so handlers run unchanged on the VM (`httpServerFactoryIo`,
package `tekartik_http_io`), in memory (`httpServerFactoryMemory`, this
package, for tests and browser code) or on node (`tekartik_http_node`).
`HttpFactory` bundles a client and a server factory (`httpFactoryIo`,
`httpFactoryMemory`).

## Guidelines

* Import `package:tekartik_http/http.dart` (client + server, constants,
  `localhost`, `localhostIpV4`, `portDynamic`, `HttpFactory`).
  `package:tekartik_http/http_server.dart` alone has the server types but
  not the `httpHeader*`/`httpStatusCode*` constants. Never import `dart:io`
  unprefixed in the same file: `HttpServer`, `HttpRequest`, `HttpResponse`,
  `HttpHeaders`, `ContentType` and `InternetAddress` clash.
* Bind with `await factory.bind(address, port)`: `address` is `localhost`
  (a `String`) or `InternetAddress.anyIPv4` (alias `InternetAddress.any`) to
  listen on all interfaces; port `0` (`httpPortAny`, `portDynamic`) picks a
  free port, read it back with `server.port`. Build the client url with
  `server.uri` (`httpServerGetUri(server)`, also `server.clientUri`):
  `http://localhost:<port>/` on io, `http://_memory:<port>/` in memory.
* `HttpServer` is a `Stream<HttpRequest>`: `server.listen(handler)`. Every
  handler must finish its response: write, then `await
  request.response.close()`. A response left open hangs the client.
* Request: `request.method`, `request.uri` (path and query:
  `uri.path`, `uri.queryParameters`), `request.requestedUri` (with scheme
  and host), `request.headers.value(name)` / `headers[name]`
  (case-insensitive), `request.contentLength`. The body is a
  `Stream<Uint8List>` readable once: `await request.getBodyBytes()`,
  `await utf8.decoder.bind(request).join()`, or `await request.bodyAsMap` /
  `bodyAsMapOrNull` for JSON (`package:tekartik_http/http_utils.dart`).
* Response: set `statusCode` (default 200) and headers before writing:
  `headers.set(name, value)`, `headers.add(name, value)`,
  `headers.contentType = ContentType.parse(httpContentTypeJson)` or
  `headers.mimeType = httpContentTypeText`; then `write(obj)`, `writeln`,
  `writeAll`, `add(Uint8List)`, `addStream(stream)`, optionally
  `await flush()`, and `await close()`. `redirect(uri, {status})` closes the
  response too (io only, memory throws `UnimplementedError`).
* Charset: on io `write` encodes strings according to the `Content-Type`
  charset (latin1 when absent), in memory always utf-8. Send
  `'$httpContentTypeText; $httpContentTypeCharsetUtf8'` or
  `httpContentTypeHtmlStrict` for non-ASCII text, or `add` utf-8 bytes.
* `HttpHeaders` holds a `List<String>` per lower-cased name: `value(name)`
  (single value), `[name]` (list), `set`, `add`, `forEach`, `contentType`,
  plus `toMap()`, `toStringMap()` (joins with `, `, ready for a client
  `headers:` argument), `toListMap()` and `mimeType` from `HttpHeadersExt`.
  `HttpHeaders()` and `HttpHeaders.fromMap(map)` build a standalone
  instance. Request headers are read-only; response headers freeze once the
  body is written.
* CORS: start a handler with `if (request.handleCors()) return;`
  (`package:tekartik_http/http_utils.dart`). It adds permissive
  `Access-Control-Allow-Origin/Methods/Headers/Expose-Headers: *` and answers
  `OPTIONS` preflights itself (returns `true`). Header names:
  `httpAccessControlAllowOrigin`, `httpAccessControlAllowMethods`,
  `httpAccessControlAllowHeaders`, `httpAccessControlExposeHeaders`.
* Stop with `await server.close()` (`force: true` drops open connections);
  always close servers in `tearDown`/`tearDownAll`.
* Keep handlers in code depending only on `tekartik_http`, taking an
  `HttpServerFactory` or an `HttpFactory`; `main` passes
  `httpServerFactoryIo` / `httpFactoryIo`, tests pass
  `httpServerFactoryMemory` / `httpFactoryMemory`
  (`package:tekartik_http/http_memory.dart`). A memory server is reachable
  only by `httpClientFactoryMemory` clients of the same isolate, through its
  port (any host name works).
* Not in the abstraction: TLS (`bindSecure`), cookies, sessions,
  `HttpConnectionInfo`, socket detach, websockets. Use `dart:io` directly
  (prefixed) for those parts on the VM.

## Examples

### Portable JSON API handler

```dart
import 'dart:convert';

import 'package:tekartik_http/http.dart';
import 'package:tekartik_http/http_utils.dart';

Future<HttpServer> serveApi(HttpServerFactory factory, {int port = 0}) async {
  var server = await factory.bind(localhost, port);
  server.listen((request) async {
    if (request.handleCors()) {
      return; // preflight answered
    }
    var response = request.response;
    response.headers.set(httpHeaderContentType, httpContentTypeJson);
    switch ((request.method, request.uri.path)) {
      case (httpMethodGet, '/ping'):
        response.write(jsonEncode({'pong': request.uri.queryParameters['v']}));
      case (httpMethodPost, '/echo'):
        var data = await request.bodyAsMapOrNull;
        if (data == null) {
          response.statusCode = httpStatusCodeBadRequest;
          response.write(jsonEncode({'error': 'json object expected'}));
        } else {
          response.write(jsonEncode({'echo': data}));
        }
      default:
        response.statusCode = httpStatusCodeNotFound;
        response.write(jsonEncode({'error': 'not found'}));
    }
    await response.close();
  });
  print('listening on ${server.uri}');
  return server;
}
```

### io entry point

```dart
import 'package:tekartik_http_io/http_server_io.dart';

Future<void> main() async {
  await serveApi(httpServerFactoryIo, port: 8080);
  // http://localhost:8080/ping?v=1
}
```

### Bytes with an explicit content type and length

```dart
import 'dart:typed_data';

import 'package:tekartik_http/http.dart';

Future<void> sendBytes(
  HttpRequest request,
  Uint8List bytes,
  String mimeType,
) async {
  var response = request.response
    ..statusCode = httpStatusCodeOk
    ..headers.mimeType = mimeType
    ..contentLength = bytes.length
    ..add(bytes);
  await response.close();
}
```

### Same tests on memory and io

```dart
import 'package:tekartik_http/http.dart';
import 'package:tekartik_http/http_memory.dart';
import 'package:tekartik_http/http_utils.dart';
import 'package:test/test.dart';

void defineTests(HttpFactory httpFactory) {
  late HttpServer server;
  late Client client;
  setUpAll(() async {
    server = await serveApi(httpFactory.server);
    client = httpFactory.client.newClient();
  });
  tearDownAll(() async {
    client.close();
    await server.close();
  });
  test('ping', () async {
    var response = await httpClientSend(
      client,
      httpMethodGet,
      server.uri.replace(path: '/ping', queryParameters: {'v': '1'}),
    );
    expect(response.statusCode, httpStatusCodeOk);
    expect(response.bodyAsMap, {'pong': '1'});
  });
  test('echo', () async {
    var text = await httpClientRead(
      client,
      httpMethodPost,
      server.uri.resolve('/echo'),
      body: '{"a":1}',
    );
    expect(httpDataAsMap(text), {
      'echo': {'a': 1},
    });
  });
}

void main() {
  defineTests(httpFactoryMemory);
  // In a `@TestOn('vm')` file, with package:tekartik_http_io/http_io.dart:
  // defineTests(httpFactoryIo);
}
```

### Standalone headers

```dart
import 'package:tekartik_http/http.dart';

void headersDemo() {
  var headers = HttpHeaders.fromMap({
    'X-Token': 'abc',
    'accept': ['text/plain', 'application/json'],
  });
  print(headers.value('x-token')); // abc
  print(headers['Accept']); // [text/plain, application/json]
  print(headers.toStringMap()); // {x-token: abc, accept: text/plain, application/json}
  headers.mimeType = httpContentTypeJson;
  print(headers.contentType); // application/json
}
```

## Common mistakes

* Forgetting `await request.response.close()`, or returning from the handler
  before the body is written.
* Setting `statusCode` or headers after the first `write`/`add`.
* Reading the request body twice: it is a stream, keep the bytes.
* Importing `dart:io` unprefixed next to `tekartik_http`.
* Using `redirect`, cookies or TLS with the memory implementation.
* Binding `localhost` and expecting connections from another machine: bind
  `InternetAddress.anyIPv4`.
* Forgetting the charset on io text responses containing non-ASCII characters.
