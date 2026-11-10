# tekartik_http_test

The shared test suite of [tekartik_http](../http/README.md): an
implementation (`tekartik_http_io`, `tekartik_http_browser`, the memory one,
node...) is correct when `run(factory)` passes. It also has a small echo
server for your own tests.

## Getting started

Git package, not on pub.dev, in the `dev_dependencies` of the package under
test:

```yaml
dev_dependencies:
  tekartik_http_test:
    git:
      url: https://github.com/tekartik/http.dart
      path: http_test
```

Run the whole suite on an implementation (here io and the memory reference,
`test/http_suite_test.dart`):

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

## What is in it

| Import | Gives |
|---|---|
| `package:tekartik_http_test/http_test.dart` | `run(HttpFactory)`: client and server together (bind, headers, status, bodies, `IOSink` writes, the echo server group, `blob:` urls when supported) |
| `package:tekartik_http_test/echo_server_client_test.dart` | `runEchoServerClientTests(HttpClientFactory)`: client only, against an io echo server (a hybrid isolate in a browser test) |
| `package:tekartik_http_test/object_url_client_test.dart` | `runObjectUrlClientTests(HttpClientFactory)`: `blob:` urls (browser, memory) |
| `package:tekartik_http_test/test_server.dart` | the echo server: `echoServe(factory, port)`, `handleEchoRequest`, `EchoServerClient` |

The echo server answers the query parameters `body=<text>`, `statusCode=<n>`,
`use_body` (echo the request body), `header_get_demo` (return the `x-demo`
request header) and `header_set_demo=<value>` (set `x-demo`).

## Common pitfalls

* `runEchoServerClientTests` needs a client reaching a real localhost server
  (browser, io, node): the memory client only reaches memory servers.
* Three libraries export a function named `run`: import them with a prefix.
* Use port 0 (a free port) and close the servers and clients you create.

More: the [tekartik-http-test-setup skill](skills/tekartik-http-test-setup/SKILL.md).

## Testing

```bash
dart test
```
