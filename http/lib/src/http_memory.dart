import 'package:tekartik_http/http.dart';
import 'package:tekartik_http/http_memory.dart' as memory;

var httpMemoryHost = '_memory';

/// Http memory factory.
///
/// To use for testing.
class HttpFactoryMemory implements HttpFactory {
  @override
  HttpClientFactory get client => memory.httpClientFactoryMemory;

  @override
  HttpServerFactory get server => memory.httpServerFactoryMemory;
}

HttpFactoryMemory? _httpFactoryMemory;

/// Global memory http factory.
HttpFactory get httpFactoryMemory => _httpFactoryMemory ??= HttpFactoryMemory();
