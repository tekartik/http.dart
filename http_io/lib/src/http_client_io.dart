import 'package:http/http.dart' as http;
import 'package:tekartik_http/http_client.dart';

class HttpClientFactoryIo implements HttpClientFactory {
  @override
  http.Client newClient() {
    return new http.Client();
  }
}

HttpClientFactoryIo _HttpClientFactoryIo;

HttpClientFactoryIo get httpClientFactoryIo =>
    _HttpClientFactoryIo ??= new HttpClientFactoryIo();
