import 'package:tekartik_http/http.dart';
import 'package:tekartik_http/src/http_memory.dart' as memory;

export 'package:tekartik_http/src/http_client_memory.dart' show HttpClientMixin;

export 'http_client.dart';
export 'http_server.dart';

HttpFactory get httpFactoryMemory => memory.httpFactoryMemory;
