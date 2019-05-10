import 'package:tekartik_http/http.dart';
import 'package:tekartik_http/src/http_client.dart' show HttpClientFactory;
import 'package:tekartik_http/src/http_client_memory.dart' as memory;

export 'package:tekartik_http/src/http_client.dart'
    show HttpClientFactory, httpClientSend, HttpClientResponse, httpClientRead;

@deprecated
HttpClientFactory get httpClientFactoryMemory => memory.httpClientFactoryMemory;

abstract class HttpClientException {
  int get statusCode;
  HttpClientResponse get response;
}
