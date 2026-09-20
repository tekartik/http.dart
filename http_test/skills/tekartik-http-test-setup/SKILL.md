---
name: tekartik-http-test-setup
description: >-
  Use when validating a tekartik_http implementation (io, browser, memory,
  node...) against the shared tekartik_http_test suite, or when a test needs a
  throwaway echo HTTP server: run(HttpFactory) from http_test.dart,
  echoServe/serve/HttpServerState/EchoServerClient/handleEchoRequest from
  test_server.dart, runEchoServerClientTests from echo_server_client_test.dart,
  runObjectUrlClientTests from object_url_client_test.dart, the
  TEKARTIK_HTTP_TEST_SERVER_URI (uriVarKey) external server mode, and the
  body/statusCode/use_body/header_get_demo/header_set_demo query parameters.
---

# Shared http test suite (tekartik_http_test)

`tekartik_http_test` is the conformance suite for `tekartik_http`: a
`HttpFactory` implementation (`tekartik_http_io`, `tekartik_http_browser`, the
memory one...) is considered correct when `run(factory)` passes. It also ships
a tiny echo server any package can reuse in its own tests.

## Guidelines

* Dependency (git, not on pub.dev), in `dev_dependencies` of the package under
  test:
  ```yaml
  dev_dependencies:
    tekartik_http_test:
      git:
        url: https://github.com/tekartik/http.dart
        path: http_test
      version: '>=0.7.0'
  ```
  It pulls `tekartik_http` and `tekartik_http_io` transitively, but declare
  `tekartik_http` yourself for the abstractions you import.
* `package:tekartik_http_test/http_test.dart` exposes `run(HttpFactory
  httpFactory)`: the whole suite (server bind/close, request and response
  streaming, headers, status codes, fragments, byte bodies, `IOSink` style
  writes, plus the echo-server group and, when
  `httpFactory.client.supportsObjectUrl` is true, the `blob:` group). Call it
  from a `main()` of your own; it declares its own `group`/`test`.
* One test file per implementation, guarded with `@TestOn('vm')` /
  `@TestOn('browser')` so the factory is only touched where it works. Keep a
  `run(httpFactoryMemory)` file next to it: it is the reference behaviour and
  runs everywhere.
* `package:tekartik_http_test/test_server.dart` is the echo server toolbox:
  * `echoServe(HttpServerFactory factory, int port)` binds on `localhost`
    (port `0` = free port), serves `handleEchoRequest` and returns an
    `HttpServerState` with `.uri` and `.close()`.
  * `serve(HttpServerFactory factory, int port)` is the older variant
    returning the raw `HttpServer` (only `body`/`statusCode` supported).
  * `handleEchoRequest(HttpRequest request)` alone can be plugged into an
    existing server (it handles CORS preflight via `request.handleCors()`).
  * `EchoServerClient(factory: HttpClientFactory, uri: Uri)` talks to it:
    `read(uri)`, `ping()` (throws `StateError` when the server is down) and
    `client` (lazily created, shared `http.Client`).
* Echo request contract (query parameters): `body=<text>` returns that text,
  `statusCode=<int>` sets the status, `use_body` echoes the request body back,
  `header_get_demo` returns the received `x-demo` header, `header_set_demo=<v>`
  sets `x-demo` on the response. Responses are `text/plain`.
* `package:tekartik_http_test/test_server_test.dart` has
  `run(HttpFactory httpFactory)` for the echo group only (it starts and stops
  its own server); `package:tekartik_http_test/test_server_client_test.dart`
  has `run(EchoServerClient client)` for the client side of an already running
  server, plus `uriVarKey` (`TEKARTIK_HTTP_TEST_SERVER_URI`) to point a
  client-only run at an external server. Import these with a prefix: three
  libraries export a symbol named `run`.
* Client-only suites, for implementations that have no server
  (`tekartik_http_browser`):
  `runEchoServerClientTests(HttpClientFactory)` from
  `package:tekartik_http_test/echo_server_client_test.dart` spawns the echo
  server as a hybrid isolate/process (VM in a browser test too, via
  `spawnHybridUri`), and `runObjectUrlClientTests(HttpClientFactory)` from
  `package:tekartik_http_test/object_url_client_test.dart` covers `blob:` urls
  (`createObjectUrl` / `revokeObjectUrl`); only call the latter when
  `factory.supportsObjectUrl` is true.
* Do not import `package:tekartik_http/http_test.dart` or
  `http_test_helper.dart`: those are deprecated stubs of `tekartik_http`, not
  this suite.
* Anti-patterns: hardcoding a port (use `0` and read `state.uri`); forgetting
  `await state.close()` / `client.close()` in `tearDownAll`; calling
  `run(httpFactoryIo)` from a browser or node test; adding
  `tekartik_http_test` to `dependencies` instead of `dev_dependencies`.

## Examples

### Full suite for an implementation (io) and the memory reference

```dart
@TestOn('vm')
library;

import 'package:tekartik_http/http_memory.dart';
import 'package:tekartik_http_io/http_io.dart';
import 'package:tekartik_http_test/http_test.dart' as http_test;
import 'package:test/test.dart';

void main() {
  group('memory', () => http_test.run(httpFactoryMemory));
  group('io', () => http_test.run(httpFactoryIo));
}
```

### Client-only suites (no server implementation)

```dart
import 'package:tekartik_http/http_memory.dart';
import 'package:tekartik_http_test/echo_server_client_test.dart';
import 'package:tekartik_http_test/object_url_client_test.dart';
import 'package:test/test.dart';

void main() {
  // Works from a browser test too: the echo server runs on the VM side.
  runEchoServerClientTests(httpClientFactoryMemory);
  if (httpClientFactoryMemory.supportsObjectUrl) {
    runObjectUrlClientTests(httpClientFactoryMemory);
  }
}
```

### An echo server for your own tests

```dart
import 'package:tekartik_http/http.dart';
import 'package:tekartik_http/http_memory.dart';
import 'package:tekartik_http_test/test_server.dart';
import 'package:test/test.dart';

void main() {
  late HttpServerState serverState;
  late EchoServerClient client;
  setUpAll(() async {
    serverState = await echoServe(httpServerFactoryMemory, 0);
    client = EchoServerClient(
      factory: httpClientFactoryMemory,
      uri: serverState.uri,
    );
  });
  tearDownAll(() async => serverState.close());

  test('echo', () async {
    await client.ping();
    expect(
      await client.read(
        serverState.uri.replace(queryParameters: {'body': 'hello'}),
      ),
      'hello',
    );
    var response = await httpClientSend(
      client.client,
      httpMethodPost,
      serverState.uri.replace(queryParameters: {'use_body': 'true'}),
      body: 'sent',
    );
    expect(response.body, 'sent');
  });
}
```

### Standalone echo server on a fixed port (manual testing)

```dart
import 'package:tekartik_http_io/http_server_io.dart';
import 'package:tekartik_http_test/test_server.dart' as test_server;

Future<void> main() async {
  // http://localhost:8181?body=test&statusCode=400
  await test_server.echoServe(httpServerFactoryIo, 8181);
}
```

### Client suite against an externally started server

```dart
@TestOn('vm')
library;

import 'dart:io';

import 'package:tekartik_http_io/http_client_io.dart';
import 'package:tekartik_http_test/test_server.dart';
import 'package:tekartik_http_test/test_server_client_test.dart'
    as test_server_client;
import 'package:test/test.dart';

/// Run with TEKARTIK_HTTP_TEST_SERVER_URI=http://localhost:8181 dart test
void main() {
  var uri = Platform.environment[test_server_client.uriVarKey];
  group('echo client', () {
    if (uri != null) {
      test_server_client.run(
        EchoServerClient(factory: httpClientFactoryIo, uri: Uri.parse(uri)),
      );
    }
  }, skip: uri == null ? 'no ${test_server_client.uriVarKey}' : false);
}
```
