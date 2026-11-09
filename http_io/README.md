# tekartik_http_io

The `dart:io` implementation of [tekartik_http](../http/README.md): a real HTTP
client (`package:http` `IOClient`) and a real HTTP server, on the Dart VM and
Flutter native (Android, iOS, desktop). Code written against `HttpFactory`,
`HttpClientFactory` or `HttpServerFactory` gets `httpFactoryIo` from `main`.

## Getting started

Git package, not on pub.dev:

```yaml
dependencies:
  tekartik_http_io:
    git:
      url: https://github.com/tekartik/http.dart
      path: http_io
```

A server on a free port and a client calling it:

```dart
import 'package:tekartik_http_io/http_io.dart';

Future<void> main() async {
  var server = await httpFactoryIo.server.bind(localhost, 0); // 0: free port
  server.listen((request) async {
    request.response.write('hello ${request.uri.path}');
    await request.response.close();
  });

  var client = httpFactoryIo.client.newClient();
  try {
    var uri = httpServerGetUri(server).replace(path: 'world');
    print(await httpClientRead(client, httpMethodGet, uri)); // hello /world
  } finally {
    client.close();
    await server.close();
  }
}
```

A JSON example: [example/main.dart](example/main.dart).

## Platforms

Dart VM and Flutter native only. The libraries can be imported everywhere
(conditional exports), but on the web the getters throw
`UnimplementedError`: use `tekartik_http_browser` there, or
`tekartik_app_http` which picks one for you.

## Imports

| Import | Adds |
|---|---|
| `package:tekartik_http_io/http_io.dart` | `httpFactoryIo` (`.client`, `.server`) + the whole `tekartik_http` API |
| `package:tekartik_http_io/http_client_io.dart` | `httpClientFactoryIo`, `httpClientFactoryIoNoSslCheck`, `downloadFile` |
| `package:tekartik_http_io/http_server_io.dart` | `httpServerFactoryIo` |

## Common pitfalls

* `bind(address, port)` takes a host (`localhost`), an ip string, a
  `dart:io` `InternetAddress` or the abstract `InternetAddress.anyIPv4`
  (any other abstract address throws `UnsupportedError`). `localhost` is not
  reachable from the LAN: bind `InternetAddress.anyIPv4` for that.
* Close every client (`client.close()`) and every response in a handler
  (`await request.response.close()`), or the call never ends.
* `headers.contentType` is null when there is no content type; setting it to
  null removes the header (same as the memory implementation).
* `httpClientFactoryIoNoSslCheck` accepts any certificate: local development
  against self-signed servers only.
* `downloadFile(url, directory: ...)` names the file after the last url
  segment: give `path:` for a url ending with `/` or without a path.
* No object urls (`blob:`) on io: `supportsObjectUrl` is false.

## Testing

```bash
dart test
```

`test/http_io_test.dart` runs the shared `tekartik_http_test` suite
(`run(httpFactoryIo)`) and one real https download of a static test fixture.
