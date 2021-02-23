import 'package:tekartik_http/http.dart';
import 'package:tekartik_http_io/http_client_io.dart';
import 'package:tekartik_http_io/http_server_io.dart';

class HttpFactoryIo implements HttpFactory {
  @override
  HttpClientFactory get client => httpClientFactoryIo;
  @override
  HttpServerFactory get server => httpServerFactoryIo;
}

HttpFactoryIo? _httpFactoryIo;

HttpFactory get httpFactoryIo => _httpFactoryIo ??= HttpFactoryIo();
