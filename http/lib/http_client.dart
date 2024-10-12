import 'package:tekartik_http/src/http_client.dart';

export 'package:http/http.dart' show Client;
export 'package:tekartik_http/http_memory.dart' show httpClientFactoryMemory;
export 'package:tekartik_http/src/http_client.dart'
    show
        HttpClientFactory,
        httpClientSend,
        HttpClientResponse,
        httpClientRead,
        httpClientReadBytes;
export 'package:tekartik_http/src/http_constant.dart';
export 'package:tekartik_http/src/utils.dart' show isHttpStatusCodeSuccessful;

/// Http client exception.
abstract class HttpClientException {
  /// Http status code.
  int get statusCode;

  /// Client response.
  HttpClientResponse get response;
}
