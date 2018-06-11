import 'package:node_http/node_http.dart' as http;
import 'package:http/http.dart' as http;
import 'package:tekartik_http/http_client.dart';

class HttpClientFactoryNode implements HttpClientFactory {
  @override
  http.Client newClient() {
    return new http.NodeClient();
  }
}

HttpClientFactoryNode _httpClientFactoryNode;

HttpClientFactoryNode get httpClientFactoryNode =>
    _httpClientFactoryNode ??= new HttpClientFactoryNode();
