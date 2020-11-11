import 'package:tekartik_http/http.dart';

export 'package:tekartik_http/http_memory.dart' show httpClientFactoryMemory;
export 'package:tekartik_http/src/http_client.dart'
    show HttpClientFactory, httpClientSend, HttpClientResponse, httpClientRead;

/// Http client exception.
abstract class HttpClientException {
  /// Http status code.
  int get statusCode;

  /// Client response.
  HttpClientResponse get response;
}
