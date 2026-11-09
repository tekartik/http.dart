# tekartik_http_browser

The browser implementation of the [tekartik_http](../http/README.md) client:
`httpClientFactoryBrowser` creates `package:http` `BrowserClient`s (`fetch`),
for Dart web and Flutter web, compiled with dart2js or dart2wasm. Client only:
a browser cannot serve (use `httpServerFactoryMemory` in page tests).

## Getting started

Git package, not on pub.dev:

```yaml
dependencies:
  tekartik_http_browser:
    git:
      url: https://github.com/tekartik/http.dart
      path: http_browser
```

```dart
import 'package:tekartik_http_browser/http_client_browser.dart';

Future<void> main() async {
  var client = httpClientFactoryBrowser.newClient();
  try {
    // The server must allow the page origin (CORS).
    print(await httpClientRead(
      client,
      httpMethodGet,
      Uri.parse('https://example.com/data.json'),
    ));
  } finally {
    client.close();
  }
}
```

Shared code takes an `HttpClientFactory`; only the web entry point names
`httpClientFactoryBrowser` (`httpClientFactoryIo` on the VM, memory in tests).

## Platforms

Web only. The import compiles everywhere (conditional export), but off the
web `httpClientFactoryBrowser` throws `UnimplementedError`. For Flutter code
running everywhere, `tekartik_app_http` picks the browser or the io factory.

## Object urls

`httpClientFactoryBrowser.createObjectUrl(bytes, contentType: 'image/png')`
returns a `blob:` url readable with GET by the same page (or usable as an
`<img src>`); call `revokeObjectUrl(url)` once done.

## Common pitfalls

* A cross origin call without CORS headers on the server fails with a
  `ClientException` (`Failed to fetch`), not with an HTTP status.
* Cookies and auth are sent cross site only with
  `(client as BrowserClient).withCredentials = true`.
* `followRedirects: false` makes the request fail with a `ClientException`
  (`fetch` with `redirect: 'error'`).
* Never revoking object urls keeps their bytes in memory.

## Testing

```bash
dart test -p chrome          # dart2js
dart test -p chrome -c dart2wasm
```

`test/web/http_browser_test.dart` calls an io echo server started in the VM
by `spawnHybridUri` (`runEchoServerClientTests` of `tekartik_http_test`).
