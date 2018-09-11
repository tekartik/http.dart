import 'package:tekartik_http/http.dart';
import 'package:tekartik_http_io/http_client_io.dart';
import 'package:tekartik_http_io/http_server_io.dart';

class HttpFactoryIo implements HttpFactory {
  HttpClientFactory get client => httpClientFactoryIo;
  HttpServerFactory get server => httpServerFactoryIo;
}

HttpFactoryIo _httpFactoryIo;

HttpFactory get httpFactoryIo => _httpFactoryIo ??= new HttpFactoryIo();
