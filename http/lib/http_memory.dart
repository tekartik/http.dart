export 'http_server.dart';
export 'http_client.dart';
import 'package:tekartik_http/http.dart';
import 'package:tekartik_http/src/http_memory.dart' as _;
export 'package:tekartik_http/src/http_client_memory.dart' show HttpClientMixin;

HttpFactory get httpFactoryMemory => _.httpFactoryMemory;
