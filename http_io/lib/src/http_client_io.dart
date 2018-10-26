import 'package:http/http.dart' as http;
import 'package:tekartik_http/http_client.dart';

class HttpClientFactoryIo implements HttpClientFactory {
  @override
  http.Client newClient() {
    return http.Client();
  }
}

HttpClientFactoryIo _HttpClientFactoryIo;

HttpClientFactoryIo get httpClientFactoryIo =>
    _HttpClientFactoryIo ??= HttpClientFactoryIo();
