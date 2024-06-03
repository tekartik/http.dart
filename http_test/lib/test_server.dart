// ignore_for_file: depend_on_referenced_packages

import 'package:http/http.dart';
import 'package:tekartik_common_utils/common_utils_import.dart';
import 'package:tekartik_http/http.dart';

/// Server state upon creation
class HttpServerState {
  final HttpServer httpServer;
  late final HttpServerInfo serverInfo;

  HttpServerState({required this.httpServer}) {
    serverInfo = HttpServerInfo(uri: httpServerGetUri(httpServer));
  }

  Uri get uri => serverInfo.uri;
  Future<void> close() async {
    await httpServer.close();
  }
}

/// Server info.
class HttpServerInfo {
  late final Uri uri;

  HttpServerInfo({required this.uri});
}

/// Server client.
class EchoServerClient {
  final HttpClientFactory factory;
  final Uri uri;
  Client? _client;
  Client get client => _client ??= factory.newClient();

  EchoServerClient({required this.factory, required this.uri});

  /// Read uri
  Future<String> read(Uri uri) async {
    var text = httpClientRead(client, httpMethodGet, uri);
    return text;
  }

  /// Ping query
  Future<void> ping() async {
    var text = await read(uri.replace(queryParameters: {'body': 'ping'}))
        .timeout(Duration(milliseconds: 10000));
    if (text != 'ping') {
      throw StateError('Server not running');
    }
  }
}

void handleEchoRequest(HttpRequest request) async {
  request.response.headers
    ..set(httpAccessControlAllowMethods,
        [httpMethodPost, httpMethodGet].join(', '))
    ..set(httpAccessControlAllowOrigin, '*')
    ..set(httpAccessControlAllowHeaders, '*')
    ..set(httpAccessControlExposeHeaders, '*');
  if (request.method == httpMethodOptions) {
    // Handle a CORS preflight request:
    // https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS#preflighted_requests
    await request.response.close();
    return;
  }
  var statusCode = parseInt(request.uri.queryParameters['statusCode']);

  request.response.headers.contentType = ContentType.parse(httpContentTypeText);
  var body = request.uri.queryParameters['body'];
  var useBody = request.uri.queryParameters.containsKey('use_body');
  var setDemoHeader = request.uri.queryParameters['header_set_demo'];
  var getDemoHeader =
      request.uri.queryParameters.containsKey('header_get_demo');
  if (statusCode != null) {
    request.response.statusCode = statusCode;
  }

  if (setDemoHeader != null) {
    request.response.headers.set('x-demo', setDemoHeader);
  }
  if (useBody) {
    var bytes = await request.getBodyBytes();
    request.response.add(bytes);
  }
  if (getDemoHeader) {
    request.response.write(request.headers.value('x-demo'));
  } else {
    if (body != null) {
      request.response.write(body);
    } else {
// needed for node
      request.response.write('');
    }
  }

  await request.response.close();
}

/// Use port 0 for automatic

Future<HttpServerState> echoServe(HttpServerFactory factory, int port) async {
  var server = await factory.bind(localhost, port);
  server.listen(handleEchoRequest);
  var uri = httpServerGetUri(server);
  print('simple body <$uri?body=test>');
  print('Failed <$uri?body=test&statusCode=400>');
  return HttpServerState(httpServer: server);
}

/// Use port 0 for automatic
Future<HttpServer> serve(HttpServerFactory factory, int port) async {
  var server = await factory.bind(localhost, port);
  server.listen((request) async {
    var statusCode = parseInt(request.uri.queryParameters['statusCode']);

    request.response.headers.contentType =
        ContentType.parse(httpContentTypeText);
    var body = request.uri.queryParameters['body'];

    if (statusCode != null) {
      request.response.statusCode = statusCode;
    }
    if (body != null) {
      request.response.write(body);
    } else {
// needed for node
      request.response.write('');
    }

    await request.response.close();
  });
  var uri = httpServerGetUri(server);
  print('simple body <$uri?body=test>');
  print('Failed <$uri?body=test&statusCode=400>');
  return server;
}
