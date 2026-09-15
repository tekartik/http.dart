---
name: tekartik-http-redirect-server
description: >-
  Use when working with the obsolete tekartik_http_redirect package of the
  tekartik/http.dart repo (HttpRedirectServer.startServer, Options,
  proxyHttpRequest, the x-tekartik-redirect-base-url and
  x-tekartik-redirect-url headers, CORS proxying for browser clients, the
  http_redirect command line) to keep it running, test it on the memory
  implementation, or migrate to its replacement in
  github.com/tekartik/http_redirect.dart.
---

# tekartik_http_redirect (obsolete): HTTP forwarding proxy

A small server built on the `tekartik_http` abstractions that forwards each
incoming request to another base url and copies the answer back, adding CORS
headers on demand. Typical use: let a browser page (`tekartik_http_browser`)
call an API without CORS support, or let a client pick the real target per
request through a header.

**This copy (`path: http_redirect` in `tekartik/http.dart`) is deprecated.**
Its libraries carry
`@Deprecated('Use https://github.com/tekartik/http_redirect.dart')`. New code
depends on the replacement `tekartik_http_redirect` in
`tekartik/http_redirect.dart`, `path: packages/http_redirect`. The
replacement keeps `HttpRedirectServer`, `Options`, `proxyHttpRequest` and the
headers, and adds a client side (`RedirectClient`, `RedirectClientFactory` in
`http_redirect_client.dart`), `Options.forwardArguments` (request query
merged into the target), `allowMissingRedirectHeader`, a
`redirectForwardKeyPrefix` header prefix, the redirect url as a query
parameter, and CLI defaults with CORS on.

## Guidelines

* Imports: `package:tekartik_http_redirect/http_redirect.dart`
  (`HttpRedirectServer`, `Options`, `proxyHttpRequest`,
  `redirectBaseUrlHeader`, `redirectUrlHeader`, `corsDefaultHeaders`,
  `debugHttpRedirectServer`, deprecated top-level `startServer`) and
  `package:tekartik_http_redirect/http_redirect_cli.dart` (the command line
  `main`). Both raise `deprecated_member_use`; add
  `// ignore: deprecated_member_use` on the import, or migrate.
* Start with `await HttpRedirectServer.startServer(httpFactory:
  httpFactoryIo, options: Options()..port = 8180..baseUrl = '...')`, or
  pass `httpClientFactory:` and `httpServerFactory:` separately (any mix,
  for example a memory server forwarding to io). The result exposes `port`,
  `httpServer` and `close()` (force-closes the server and the client). One
  client is created lazily and reused for every forwarded request.
* `Options` fields: `host` (default `InternetAddress.anyIPv4`), `port`
  (default 8180), `baseUrl` (default target), `handleCors` (default false),
  `corsHeaders` (default `corsDefaultHeaders`: Origin, Content-Type,
  Authorization, Accept, Connection, Content-length, Host, User-Agent; the
  two redirect headers are always appended), `forwardedHeaders` (explicit
  allow-list that overrides every other header rule), `forwardHeaders`
  (CLI flag, unused by the server).
* Target per request: the `x-tekartik-redirect-url` request header
  (`redirectUrlHeader`) is used as the full target; otherwise
  `x-tekartik-redirect-base-url` (`redirectBaseUrlHeader`, legacy
  `_tekartik_redirect_host`) or `options.baseUrl` is joined with the request
  path (`/` maps to the base url itself). The request query string is not
  carried over in this version. No base url and no full url: 405 with a text
  message; forwarding failure: 405 `caught error ...`.
* Header forwarding: with `forwardedHeaders` only those names; otherwise with
  `handleCors` only the `corsHeaders` names minus the redirect ones;
  otherwise everything except `host`. The method and body bytes are
  forwarded as is. Response: status code and every header except
  `content-length` and `content-encoding` are copied, plus
  `x-tekartik-redirect-url` set to the resolved target.
* CORS mode (`handleCors = true`): every response gets
  `Access-Control-Allow-Origin: *`,
  `Access-Control-Allow-Methods: POST, OPTIONS, GET, PATCH, DELETE` and
  `Access-Control-Allow-Headers: <corsHeaders>`; `OPTIONS` preflights get a
  200 without forwarding. Browser callers set `x-tekartik-redirect-url` or
  `x-tekartik-redirect-base-url` (both are in the allowed headers).
* Command line: `dart run tekartik_http_redirect:http_redirect -p 8180 -b
  https://api.example.com --cors --log info`. Options: `-h/--help`,
  `-c/--cors`, `-o/--cors-headers` (repeatable), `-l/--log` (fine, debug,
  info...), `-p/--port` (8180), `-b/--host` base url, `-w/--forward-headers`.
  `bin/whos_ip.dart` kills whatever listens on 8180 (`lsof`, dev only).
* Debugging: set `debugHttpRedirectServer = true` to print every step
  (target, headers, status).
* Tests: define a `run({HttpFactory? httpFactory, HttpFactory?
  testServerHttpFactory})` group and call it with `httpFactoryMemory` in a
  multiplatform file and with `httpFactoryIo`, mixing implementations, in a
  `@TestOn('vm')` file (see `test/multiplatform/http_redirect_test.dart`).
* Migration: change the git dependency to
  `url: https://github.com/tekartik/http_redirect.dart`,
  `path: packages/http_redirect`; review the `Options` defaults
  (`handleCors` and `forwardHeaders` become true, `forwardArguments` merges
  the query); use `RedirectClientFactory` on the client side instead of
  setting the headers by hand.

## Examples

### Proxy with a fixed target and CORS

```dart
import 'package:tekartik_http_io/http_io.dart';
// ignore: deprecated_member_use
import 'package:tekartik_http_redirect/http_redirect.dart';

Future<void> main() async {
  var server = await HttpRedirectServer.startServer(
    httpFactory: httpFactoryIo,
    options: Options()
      ..port = 8180
      ..baseUrl = 'https://api.example.com/v1'
      ..handleCors = true,
  );
  // GET http://localhost:8180/users -> GET https://api.example.com/v1/users
  print('proxy on port ${server.port}');
}
```

### Per-request target from a browser page

```dart
import 'package:tekartik_http_browser/http_client_browser.dart';

Future<String> readThroughProxy(Uri proxyUri, Uri target) async {
  var client = httpClientFactoryBrowser.newClient();
  try {
    return await httpClientRead(
      client,
      httpMethodGet,
      proxyUri,
      headers: {'x-tekartik-redirect-url': target.toString()},
    );
  } finally {
    client.close();
  }
}
```

### Test: memory proxy in front of a memory target

```dart
import 'package:tekartik_http/http.dart';
import 'package:tekartik_http/http_memory.dart';
// ignore: deprecated_member_use
import 'package:tekartik_http_redirect/http_redirect.dart';
import 'package:test/test.dart';

void main() {
  test('redirect', () async {
    var target = await httpServerFactoryMemory.bind(localhost, 0);
    target.listen((request) {
      request.response
        ..write('target ${request.uri.path}')
        ..close();
    });
    var proxy = await HttpRedirectServer.startServer(
      httpFactory: httpFactoryMemory,
      options: Options()
        ..host = localhost
        ..port = 0
        ..baseUrl = target.uri.toString(),
    );
    var client = httpClientFactoryMemory.newClient();
    var response = await httpClientSend(
      client,
      httpMethodGet,
      Uri.parse('http://$localhost:${proxy.port}/hello'),
    );
    expect(response.body, 'target /hello');
    expect(response.headers.value(redirectUrlHeader), '${target.uri}hello');
    client.close();
    await proxy.close();
    await target.close();
  });
}
```

## Common mistakes

* Adding new code on this package instead of the replacement repo.
* Expecting the request query string to reach the target (only the path is
  joined here; the replacement has `forwardArguments`).
* Forgetting `handleCors = true` for browser callers, or leaving the
  `x-tekartik-redirect-*` header out of a CORS-restricted client.
* Reading `proxy.port` before `startServer` completes, or leaving the proxy
  and target servers open in tests.
