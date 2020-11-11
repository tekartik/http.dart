import 'package:tekartik_http/http.dart';
import 'package:tekartik_http_node/src/http_node.dart' as impl;
import 'package:tekartik_http_node/src/http_client_node.dart' as impl;
import 'package:tekartik_http_node/src/http_server_node.dart' as impl;

HttpFactory get httpFactoryNode => impl.httpFactoryNode;
HttpClientFactory get httpClientFactoryNode => impl.httpClientFactoryNode;
HttpServerFactory get httpServerFactoryNode => impl.httpServerFactoryNode;
