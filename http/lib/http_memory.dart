export 'http_server.dart';
export 'http_client.dart';
export 'src/http.dart';
import 'package:tekartik_http/http.dart';
import 'src/http_memory.dart' as _;

HttpFactory get httpFactoryMemory => _.httpFactoryMemory;
