import 'dart:io' as io;
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart' as http;
import 'package:path/path.dart';
import 'package:tekartik_http/http_client.dart';

/// Http client factory io
abstract class HttpClientFactoryIo implements HttpClientFactory {}

/// Http client factory io
class _HttpClientFactoryIo implements HttpClientFactoryIo {
  /// Optional inner builder
  io.HttpClient Function()? ioHttpClientBuilder;

  /// Constructor
  _HttpClientFactoryIo({this.ioHttpClientBuilder});

  @override
  http.Client newClient() {
    return http.IOClient(ioHttpClientBuilder?.call());
  }
}

HttpClientFactoryIo? _httpClientFactoryIo;

/// Http client factory io
HttpClientFactoryIo get httpClientFactoryIo =>
    _httpClientFactoryIo ??= _HttpClientFactoryIo();

/// Special IO client without SSL check
var httpClientFactoryIoNoSslCheck =
    _HttpClientFactoryIo(ioHttpClientBuilder: ioHttpClientWithoutSslCheck);

/// Special IO client without SSL check
io.HttpClient ioHttpClientWithoutSslCheck() {
  final ioc = io.HttpClient();
  ioc.badCertificateCallback =
      (io.X509Certificate cert, String host, int port) => true;
  return ioc;
}

/// Http client factory io helpers
extension HttpClientFactoryIoExt on HttpClientFactory {
  /// Download a file
  /// Either [path] or [directory] should be provided, otherwise
  /// default to current directory
  Future<void> downloadFile(Uri url, {String? path, String? directory}) async {
    var client = newClient();
    path ??= path ?? join(directory ?? '', url.pathSegments.last);
    var parent = Directory(dirname(path));
    if (!parent.existsSync()) {
      parent.createSync(recursive: true);
    }
    try {
      var bytes = await client.readBytes(url);
      await File(path).writeAsBytes(bytes);
    } finally {
      client.close();
    }
  }
}
