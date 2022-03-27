import 'package:tekartik_http/http.dart';
import 'package:tekartik_http_io/src/http_client_io.dart' as impl;
import 'package:tekartik_http_io/src/http_io.dart' as impl;
import 'package:tekartik_http_io/src/http_server_io.dart' as impl;

HttpFactory get httpFactoryIo => impl.httpFactoryIo;

HttpClientFactory get httpClientFactoryIo => impl.httpClientFactoryIo;

HttpServerFactory get httpServerFactoryIo => impl.httpServerFactoryIo;

/// Special IO cliecn without SSL check
HttpClientFactory get httpClientFactoryIoNoSslCheck =>
    impl.httpClientFactoryIoNoSslCheck;
