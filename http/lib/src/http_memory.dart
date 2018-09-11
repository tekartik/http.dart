import 'package:tekartik_http/http.dart';

class HttpFactoryMemory implements HttpFactory {
  HttpClientFactory get client => httpClientFactoryMemory;

  HttpServerFactory get server => httpServerFactoryMemory;
}

HttpFactoryMemory _httpFactoryMemory;

HttpFactory get httpFactoryMemory =>
    _httpFactoryMemory ??= new HttpFactoryMemory();
