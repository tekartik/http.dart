import 'package:http/browser_client.dart' as http;
import 'package:http/http.dart' as http;
import 'package:tekartik_http/http_client.dart';

class HttpClientFactoryBrowser implements HttpClientFactory {
  @override
  http.Client newClient() {
    return new http.BrowserClient();
  }
}

HttpClientFactoryBrowser _httpClientFactoryBrowser;

HttpClientFactoryBrowser get httpClientFactoryBrowser =>
    _httpClientFactoryBrowser ??= new HttpClientFactoryBrowser();
