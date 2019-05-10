import 'package:tekartik_http/http.dart';
import 'package:tekartik_http/http_memory.dart' as memory;

class HttpFactoryMemory implements HttpFactory {
  @override
  HttpClientFactory get client => memory.httpClientFactoryMemory;

  @override
  HttpServerFactory get server => memory.httpServerFactoryMemory;
}

HttpFactoryMemory _httpFactoryMemory;

HttpFactory get httpFactoryMemory => _httpFactoryMemory ??= HttpFactoryMemory();
