import 'package:tekartik_http/http.dart';

class HttpFactoryMemory implements HttpFactory {
  @override
  HttpClientFactory get client => httpClientFactoryMemory;

  @override
  HttpServerFactory get server => httpServerFactoryMemory;
}

HttpFactoryMemory _httpFactoryMemory;

HttpFactory get httpFactoryMemory => _httpFactoryMemory ??= HttpFactoryMemory();
