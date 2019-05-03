import 'package:tekartik_http/http.dart';
import 'package:tekartik_http_node/http_client_node.dart';
import 'package:tekartik_http_node/http_server_node.dart';

class HttpFactoryNode implements HttpFactory {
  @override
  HttpClientFactory get client => httpClientFactoryNode;

  @override
  HttpServerFactory get server => httpServerFactoryNode;
}

HttpFactoryNode _httpFactoryNode;

HttpFactory get httpFactoryNode => _httpFactoryNode ??= HttpFactoryNode();
