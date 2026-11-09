# http.dart

Portable HTTP client and server for Dart: the same code runs on the Dart VM,
in the browser, on node and in memory for tests. A pub workspace.

| Package | Folder | What |
|---|---|---|
| `tekartik_http` | [`http/`](http) | The API (`HttpClientFactory`, `HttpServerFactory`, helpers, constants) and the memory implementation. Start with its [README](http/README.md). |
| `tekartik_http_io` | [`http_io/`](http_io) | Dart VM / Flutter io: `httpFactoryIo`, `httpClientFactoryIo`, `httpServerFactoryIo`. |
| `tekartik_http_browser` | [`http_browser/`](http_browser) | Browser client: `httpClientFactoryBrowser`. |
| `tekartik_http_redirect` | [`http_redirect/`](http_redirect) | Obsolete, see [http_redirect.dart](https://github.com/tekartik/http_redirect.dart). |
| `tekartik_http_test` | [`http_test/`](http_test) | Shared test suite of an `HttpFactory`. |

## Getting started

Git packages, not on pub.dev. On the VM:

```yaml
dependencies:
  tekartik_http_io:
    git:
      url: https://github.com/tekartik/http.dart
      path: http_io
```

```dart
import 'package:tekartik_http_io/http_client_io.dart';

Future<void> main() async {
  var client = httpClientFactoryIo.newClient();
  try {
    print(await httpClientRead(
      client,
      httpMethodGet,
      Uri.parse('https://example.com'),
    ));
  } finally {
    client.close();
  }
}
```

## Testing

```bash
# from a package folder
dart test
```
