# tekartik_http

Portable HTTP client and server for Dart. Code written against
`HttpClientFactory` / `HttpServerFactory` runs on the Dart VM, in the browser,
on node and fully in memory for tests: only the factory given at startup
changes. The client side is a regular `package:http` `Client`.

## Getting started

Git package, not on pub.dev:

```yaml
dependencies:
  tekartik_http:
    git:
      url: https://github.com/tekartik/http.dart
      path: http
```

A server and a client talking in memory (no network, any platform):

```dart
import 'package:tekartik_http/http.dart';
import 'package:tekartik_http/http_memory.dart';

Future<void> main() async {
  var factory = httpFactoryMemory; // httpFactoryIo on the VM
  var server = await factory.server.bind(localhost, 0); // 0: any free port
  server.listen((request) async {
    request.response
      ..headers.set(httpHeaderContentType, httpContentTypeText)
      ..write('hello ${request.uri.path}');
    await request.response.close();
  });

  var client = factory.client.newClient();
  try {
    print(await httpClientRead(
      client,
      httpMethodGet,
      server.uri.replace(path: 'world'),
    )); // hello /world
  } finally {
    client.close();
    await server.close();
  }
}
```

## Platforms

| Platform | Package (same repo) | Factory |
|---|---|---|
| Any, in memory (tests) | `tekartik_http` | `httpFactoryMemory`, `httpClientFactoryMemory`, `httpServerFactoryMemory` |
| Dart VM, Flutter io | `tekartik_http_io` (`http_io`) | `httpFactoryIo`, `httpClientFactoryIo`, `httpServerFactoryIo` |
| Browser, Flutter web (client only) | `tekartik_http_browser` (`http_browser`) | `httpClientFactoryBrowser` |
| Node | `tekartik_http_node` (repo common_node.dart) | `httpClientFactoryNode` |
| Flutter, picks io or browser | `tekartik_app_http` (repo app_common_utils.dart) | `httpClientFactory` |

Shared code imports only `tekartik_http` and takes a factory as a parameter;
`main` (or the test) picks it.

## When to use what

* `factory.newClient()`: a `package:http` `Client`. Close it when done.
* `httpClientSend(client, method, uri, ...)`: an `HttpClientResponse`
  (`statusCode`, `body`, `headers`), no throw on an HTTP error unless
  `throwOnFailure: true`.
* `httpClientRead` / `httpClientReadBytes`: the body, an
  `HttpClientException` (`statusCode`, `response`) on a status >= 400.
* `HttpServerFactory.bind(address, port)`: a `dart:io` like `HttpServer`
  (`HttpRequest`, `HttpResponse`, `HttpHeaders`) without importing `dart:io`.
* `package:tekartik_http/http_utils.dart`: `bodyAsMap`, `handleCors()`,
  `httpDataAsMap`.
* `BasicAuthClient(user, password)`: adds a Basic `Authorization` header.
* Object urls (`blob:`, browser and memory): `factory.objectUrlFactory`.

## Common pitfalls

* Always close the response in a handler (`await request.response.close()`),
  or the client waits forever.
* `package:http` decodes a body without charset as latin1: pass
  `responseEncoding: utf8` to `httpClientRead`, or send a charset from the
  server.
* A memory server is only reachable by memory clients of the same isolate.
* `handleCors()` allows every origin (`*`): any web page can read the
  responses. Do not use it on a server that relies on cookies or the caller
  origin.
* `BasicAuthClient` encodes the user and password as latin1: a character
  outside latin1 throws an `ArgumentError`.
* `copyRequest` cannot resend a multipart request with files once sent (the
  file streams are read once).
* `httpStreamGetBytes` copies the whole buffer for each chunk: fine for small
  bodies only.

The skills [tekartik-http-client](skills/tekartik-http-client/SKILL.md) and
[tekartik-http-server](skills/tekartik-http-server/SKILL.md) have more examples.
