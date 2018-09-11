export 'http_server.dart';
export 'http_client.dart';
export 'src/http.dart';
import 'package:tekartik_http/http.dart';
import 'src/http_memory.dart' as _;
export 'src/http_client_memory.dart' show HttpClientMixin;

HttpFactory get httpFactoryMemory => _.httpFactoryMemory;
