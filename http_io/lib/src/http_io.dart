import 'package:tekartik_http/http.dart';
import 'package:tekartik_http_io/http_client_io.dart';
import 'package:tekartik_http_io/http_server_io.dart';

/// Http factory io
abstract class HttpFactoryIo implements HttpFactory {}

/// Http factory io
class _HttpFactoryIo implements HttpFactoryIo {
  @override
  HttpClientFactory get client => httpClientFactoryIo;

  @override
  HttpServerFactory get server => httpServerFactoryIo;
}

HttpFactoryIo? _httpFactoryIo;

/// Http factory io
HttpFactoryIo get httpFactoryIo => _httpFactoryIo ??= _HttpFactoryIo();
