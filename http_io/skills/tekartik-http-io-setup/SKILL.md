---
name: tekartik-http-io-setup
description: >-
  Use when running tekartik_http client or server code on the Dart VM or
  Flutter native (dart:io) with tekartik_http_io: httpFactoryIo,
  httpClientFactoryIo, httpClientFactoryIoNoSslCheck, httpServerFactoryIo,
  the downloadFile helper, the http_io.dart / http_client_io.dart /
  http_server_io.dart imports, keeping the io factories out of web code, and
  running the shared tekartik_http_test suites on io.
---

# tekartik_http_io: the dart:io implementation

`tekartik_http_io` implements the `tekartik_http` abstractions with `dart:io`
and `package:http`'s `IOClient`: real sockets, real ports, TLS to remote
servers. Nothing here works in a browser at runtime, but every import is safe
everywhere: the getters throw `UnimplementedError` off the VM.

## Guidelines

* Dependency (git, not on pub.dev):
  ```yaml
  dependencies:
    tekartik_http_io:
      git:
        url: https://github.com/tekartik/http.dart
        path: http_io
  ```
  It brings `tekartik_http` (same repo, `path: http`), the API shared code is
  written against; declare `tekartik_http` explicitly too when importing it.
* Imports: `package:tekartik_http_io/http_io.dart` re-exports
  `package:tekartik_http/http.dart` and adds `httpFactoryIo` (an
  `HttpFactory` with `.client` and `.server`);
  `package:tekartik_http_io/http_client_io.dart` re-exports
  `tekartik_http/http_client.dart` and adds `httpClientFactoryIo`,
  `httpClientFactoryIoNoSslCheck` and `HttpClientFactoryIoExt`;
  `package:tekartik_http_io/http_server_io.dart` re-exports
  `tekartik_http/http_server.dart` and adds `httpServerFactoryIo`.
* `httpClientFactoryIo.newClient()` returns an `IOClient` wrapping a
  `dart:io` `HttpClient`; `close()` it when done. It follows redirects and
  decodes gzip. It only reads `http:`/`https:` urls: no `data:`, `file:` or
  `blob:` (`supportsObjectUrl` is `false`, `objectUrlFactory` throws
  `UnsupportedError`).
* `httpClientFactoryIoNoSslCheck` accepts any certificate
  (`badCertificateCallback` returns true). Local development against
  self-signed servers only, never in production code paths.
* `httpServerFactoryIo.bind(address, port)`: `address` is a host name
  (`localhost`), an ip string (`localhostIpV4`), the abstract
  `InternetAddress.anyIPv4` or a `dart:io` `InternetAddress`. Port `0`
  picks a free port (`server.port`); `httpServerGetUri(server)` /
  `server.uri` is `http://localhost:<port>/`. Only `anyIPv4` is mapped among
  the abstract addresses; other abstract `InternetAddress` values throw
  `UnsupportedError`.
* The underlying `dart:io` request, response and server objects are not
  exposed by the public libraries. TLS servers (`bindSecure`), cookies or
  sessions mean using `dart:io` directly for that part.
* `factory.downloadFile(url, {path, directory})` (extension on any
  `HttpClientFactory` from `http_client_io.dart`) reads the url bytes with a
  temporary client and writes them to `path` (default: the last url segment
  inside `directory`, or the current directory), creating parent
  directories.
* Platform split: keep shared code on `tekartik_http`; `main` or a
  `@TestOn('vm')` test picks `httpFactoryIo`. In a multiplatform test guard
  the access with `try { httpFactoryIo; } on UnimplementedError catch (_) {}`
  or with `isRunningAsJavascript` / `kDartIsWeb` from
  `package:tekartik_common_utils/env_utils.dart`.
* Shared suites in `tekartik_http_test` (same repo, `path: http_test`):
  `run(httpFactoryIo)` from `http_test.dart` exercises client and server
  together; `echoServe(httpServerFactoryIo, 0)` and `EchoServerClient` from
  `test_server.dart` start an echo server (`?body=`, `?statusCode=`,
  `?use_body`, `x-demo` header) for client tests;
  `runEchoServerClientTests(clientFactory)` from
  `echo_server_client_test.dart` runs a client suite against that server,
  spawned in the VM even from a browser test.
* Run tests with `dart test` (VM). The io client test hitting google.com
  needs network access.

## Examples

### Command-line server on a chosen or dynamic port

```dart
import 'package:tekartik_http_io/http_io.dart';

Future<void> main(List<String> args) async {
  var port = args.isNotEmpty ? int.parse(args.first) : 0;
  var server = await httpServerFactoryIo.bind(InternetAddress.anyIPv4, port);
  server.listen((request) async {
    request.response.headers.set(httpHeaderContentType, httpContentTypeText);
    request.response.write('hello from ${request.uri.path}');
    await request.response.close();
  });
  print('listening on ${httpServerGetUri(server)}');
}
```

### Client call with and without certificate check

```dart
import 'package:tekartik_http_io/http_client_io.dart';

Future<String> fetch(Uri uri, {bool insecure = false}) async {
  var factory = insecure ? httpClientFactoryIoNoSslCheck : httpClientFactoryIo;
  var client = factory.newClient();
  try {
    return await httpClientRead(client, httpMethodGet, uri);
  } finally {
    client.close();
  }
}
```

### Download a file

```dart
import 'package:tekartik_http_io/http_client_io.dart';

Future<void> main() async {
  await httpClientFactoryIo.downloadFile(
    Uri.parse('https://example.com/archive.zip'),
    directory: '.local/downloads', // writes .local/downloads/archive.zip
  );
}
```

### Same test suite on memory and io

```dart
@TestOn('vm')
library;

import 'package:tekartik_http/http_memory.dart';
import 'package:tekartik_http_io/http_io.dart';
import 'package:test/test.dart';

import 'api_test_common.dart'; // void defineTests(HttpFactory httpFactory)

void main() {
  group('memory', () => defineTests(httpFactoryMemory));
  group('io', () => defineTests(httpFactoryIo));
}
```

### Run the shared tekartik_http_test suite on io

```dart
@TestOn('vm')
library;

import 'package:tekartik_http_io/http_io.dart';
import 'package:tekartik_http_test/http_test.dart';

void main() {
  run(httpFactoryIo);
}
```

## Common mistakes

* Accessing `httpFactoryIo`, `httpClientFactoryIo` or `httpServerFactoryIo`
  in code compiled for the web: importing is fine, accessing throws.
* Binding `localhost` and expecting LAN access: use `InternetAddress.anyIPv4`.
* Passing an abstract `InternetAddress` other than `anyIPv4` to `bind`.
* Shipping `httpClientFactoryIoNoSslCheck` in production paths.
* Expecting `blob:` or `data:` urls to be readable by the io client.
