import 'dart:io' as io;

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart' as http;
import 'package:tekartik_http/http_client.dart';

class HttpClientFactoryIo implements HttpClientFactory {
  /// Optional inner builder
  io.HttpClient Function()? ioHttpClientBuilder;

  HttpClientFactoryIo({this.ioHttpClientBuilder});

  @override
  http.Client newClient() {
    return http.IOClient(ioHttpClientBuilder?.call());
  }
}

HttpClientFactoryIo? _httpClientFactoryIo;

HttpClientFactoryIo get httpClientFactoryIo =>
    _httpClientFactoryIo ??= HttpClientFactoryIo();

var httpClientFactoryIoNoSslCheck =
    HttpClientFactoryIo(ioHttpClientBuilder: ioHttpClientWithoutSslCheck);

io.HttpClient ioHttpClientWithoutSslCheck() {
  final ioc = io.HttpClient();
  ioc.badCertificateCallback =
      (io.X509Certificate cert, String host, int port) => true;
  return ioc;
}
