---
name: tekartik-http-browser-setup
description: >-
  Use when running tekartik_http client code in the browser (Dart web, Flutter
  web, dart2js or dart2wasm) with tekartik_http_browser:
  httpClientFactoryBrowser (fetch based BrowserClient),
  HttpClientFactoryBrowser object urls (createObjectUrl / revokeObjectUrl,
  blob: urls from bytes), CORS and withCredentials caveats, and testing with
  dart test -p chrome, @TestOn('browser') and the memory implementation.
---

# tekartik_http_browser: the browser client

`tekartik_http_browser` implements `HttpClientFactory` on top of
`package:http`'s `BrowserClient` (`fetch`). There is no server side in the
browser: pair it with a remote server, with `httpServerFactoryMemory` for
in-page tests, or with a proxy such as `tekartik_http_redirect`.

## Guidelines

* Dependency (git, not on pub.dev):
  ```yaml
  dependencies:
    tekartik_http_browser:
      git:
        url: https://github.com/tekartik/http.dart
        path: http_browser
  ```
* Import `package:tekartik_http_browser/http_client_browser.dart`: it
  re-exports `package:tekartik_http/http_client.dart` (helpers, constants,
  `HttpClientFactory`, `HttpObjectUrlFactory`) and adds
  `httpClientFactoryBrowser`, typed `HttpClientFactoryBrowser`. Safe to
  import on the VM; accessing the getter there throws `UnimplementedError`.
* `httpClientFactoryBrowser.newClient()` returns a `BrowserClient`: the
  request body is buffered then sent with `fetch`, the response is streamed.
  Cross-origin calls need CORS headers on the server. Cookies and auth
  headers are sent cross-site only after
  `(client as BrowserClient).withCredentials = true`
  (`package:http/browser_client.dart`). `followRedirects: false` fails with a
  `ClientException`; `maxRedirects` and `persistentConnection` are ignored.
* Errors: network and CORS failures surface as `ClientException`
  (`Failed to fetch`), an aborted request as `RequestAbortedException`, HTTP
  errors as `HttpClientException` from `httpClientRead` / `throwOnFailure`.
  `client.close()` aborts in-flight requests.
* Object urls: `httpClientFactoryBrowser.createObjectUrl(bytes, contentType:)`
  wraps `URL.createObjectURL(Blob)` and returns a `blob:` `Uri` that the
  same page reads with GET (`client.readBytes(url)`, `client.read(url)`,
  `httpClientSend(client, httpMethodGet, url)`); the string form also works
  as an `<img src>` or download link. Call `revokeObjectUrl(url)` once
  consumed, the browser keeps the bytes until then. Shared code checks
  `factory.supportsObjectUrl` and goes through `factory.objectUrlFactory`.
  Only GET works, a revoked url fails with a `ClientException`.
* Shared code takes an `HttpClientFactory`; the web entry point passes
  `httpClientFactoryBrowser`, the VM one `httpClientFactoryIo`, tests
  `httpClientFactoryMemory` (`package:tekartik_http/http_memory.dart`, which
  also runs in the browser together with `httpServerFactoryMemory` and
  supports object urls).
* Testing: `dart test -p chrome` (with `dart2js` and `dart2wasm` when
  `dart_test.yaml` lists both compilers). Files that need a browser start
  with `@TestOn('browser')`; `@TestOn('vm || browser')` files must guard
  the getter access. A real server is reachable from a browser test through
  `spawnHybridUri`: `runEchoServerClientTests(httpClientFactoryBrowser)`
  from `package:tekartik_http_test/echo_server_client_test.dart` spawns the
  io echo server in the VM and calls it from the page (CORS handled by
  `handleCors`); `runObjectUrlClientTests(httpClientFactoryBrowser)` from
  `object_url_client_test.dart` covers `blob:` urls.
* Never touch `dart:io` or the `tekartik_http_io` getters in web code; use
  `package:web` (not `dart:html`) when the DOM is needed, for example to put
  an object url in an `HTMLImageElement.src`.

## Examples

### Web entry point injecting the browser factory

```dart
import 'package:tekartik_http_browser/http_client_browser.dart';

import 'api_client.dart'; // class ApiClient(HttpClientFactory factory, Uri baseUri)

Future<void> main() async {
  var api = ApiClient(
    httpClientFactoryBrowser,
    Uri.parse('https://api.example.com/'),
  );
  print(await api.getJson('status'));
  api.close();
}
```

### Cross-site request with cookies

```dart
import 'package:http/browser_client.dart';
import 'package:tekartik_http_browser/http_client_browser.dart';

Future<String> fetchWithCookies(Uri uri) async {
  var client = httpClientFactoryBrowser.newClient() as BrowserClient
    ..withCredentials = true;
  try {
    return await httpClientRead(client, httpMethodGet, uri);
  } finally {
    client.close();
  }
}
```

### Blob url from bytes, displayed then read back

```dart
import 'dart:typed_data';

import 'package:tekartik_http_browser/http_client_browser.dart';
import 'package:web/web.dart' as web;

Future<void> showAndRead(web.HTMLImageElement img, Uint8List pngBytes) async {
  var url = httpClientFactoryBrowser.createObjectUrl(
    pngBytes,
    contentType: 'image/png',
  );
  try {
    img.src = url.toString();
    var client = httpClientFactoryBrowser.newClient();
    try {
      var bytes = await client.readBytes(url);
      assert(bytes.length == pngBytes.length);
    } finally {
      client.close();
    }
  } finally {
    httpClientFactoryBrowser.revokeObjectUrl(url);
  }
}
```

### Browser test file

```dart
@TestOn('browser')
library;

import 'dart:typed_data';

import 'package:tekartik_http_browser/http_client_browser.dart';
import 'package:tekartik_http_test/echo_server_client_test.dart';
import 'package:tekartik_http_test/object_url_client_test.dart';
import 'package:test/test.dart';

void main() {
  runEchoServerClientTests(httpClientFactoryBrowser);
  runObjectUrlClientTests(httpClientFactoryBrowser);

  test('read blob url', () async {
    var url = httpClientFactoryBrowser.createObjectUrl(
      Uint8List.fromList([1, 2, 3]),
      contentType: httpContentTypeBytes,
    );
    try {
      var client = httpClientFactoryBrowser.newClient();
      expect(await client.readBytes(url), [1, 2, 3]);
      client.close();
    } finally {
      httpClientFactoryBrowser.revokeObjectUrl(url);
    }
  });
}
```

`dart_test.yaml` to run on Chrome with both compilers and on the VM:

```yaml
platforms:
  - chrome
  - vm
compilers:
  - dart2js
  - dart2wasm
```

### Multiplatform test that also loads on the VM

```dart
@TestOn('vm || browser')
library;

import 'package:tekartik_common_utils/env_utils.dart';
import 'package:tekartik_http_browser/http_client_browser.dart';
import 'package:test/test.dart';

void main() {
  test('httpClientFactoryBrowser', () {
    try {
      httpClientFactoryBrowser;
      expect(kDartIsWeb, isTrue);
    } on UnimplementedError catch (_) {
      expect(kDartIsWeb, isFalse);
    }
  });
}
```

## Common mistakes

* Calling a server without `Access-Control-Allow-Origin`: the request fails
  with `ClientException: Failed to fetch`, not with an HTTP status.
* Expecting cookies on cross-site calls without `withCredentials = true`.
* Never revoking object urls in a long-lived page.
* Using `httpClientFactoryBrowser` in a VM test (throws): use
  `httpClientFactoryMemory` there.
* Trying to bind a server in the browser: use `httpServerFactoryMemory` in
  page tests or a real backend.
* Importing `dart:html`; use `package:web`.
