import 'package:tekartik_http/http_client.dart';

/// Browser http client factory.
///
/// Clients are `BrowserClient` from `package:http` (fetch based).
/// Object urls (`blob:`) are supported through [HttpObjectUrlFactory]
/// (`URL.createObjectURL`/`URL.revokeObjectURL`).
abstract class HttpClientFactoryBrowser
    implements HttpClientFactory, HttpObjectUrlFactory {}
