export 'src/http_client.dart' show HttpClientFactory;
import 'package:tekartik_http/src/http_client.dart';

import 'src/http_client_memory.dart' as _;

HttpClientFactory get httpClientFactoryMemory => _.httpClientFactoryMemory;
