import 'package:tekartik_http/http.dart';
import 'package:tekartik_http/src/http_client_memory.dart' as memory;
import 'package:tekartik_http/src/http_memory.dart' as memory;
import 'package:tekartik_http/src/http_server_memory.dart' as memory;
export 'package:tekartik_http/src/http_client_memory.dart' show HttpClientMixin;

export 'http_client.dart';
export 'http_server.dart';

/// Memory http client factory.
HttpClientFactory get httpClientFactoryMemory => memory.httpClientFactoryMemory;

/// Memory http server factory.
HttpServerFactory get httpServerFactoryMemory => memory.httpServerFactoryMemory;

/// Memory http factory.
HttpFactory get httpFactoryMemory => memory.httpFactoryMemory;
