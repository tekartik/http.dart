import 'package:tekartik_http/http.dart';
import 'package:tekartik_http/src/http_client.dart' show HttpClientFactory;
import 'package:tekartik_http/src/http_client_memory.dart' as memory;

export 'package:tekartik_http/src/http_client.dart'
    show HttpClientFactory, httpClientSend, HttpClientResponse, httpClientRead;

/// deprecated.
@deprecated
HttpClientFactory get httpClientFactoryMemory => memory.httpClientFactoryMemory;

/// Http client exception.
abstract class HttpClientException {
  /// Http status code.
  int get statusCode;

  /// Client response.
  HttpClientResponse get response;
}
