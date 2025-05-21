import 'package:http/http.dart' as http;
import 'package:tekartik_common_utils/common_utils_import.dart';
import 'package:tekartik_http/http.dart';
// ignore: deprecated_member_use_from_same_package
import 'package:tekartik_http_redirect/http_redirect.dart';

var debugHttpRedirectServer = false; // devWarning(true); // false

class HttpRedirectServer {
  late final HttpClientFactory _httpClientFactory;
  late final HttpServerFactory _httpServerFactory;
  http.Client? client;

  HttpServer? _httpServer;

  /// The actual server in place
  HttpServer get httpServer => _httpServer!;

  final Options options;

  HttpRedirectServer._({
    required HttpClientFactory httpClientFactory,
    required HttpServerFactory httpServerFactory,
    required this.options,
  }) {
    _httpClientFactory = httpClientFactory;
    _httpServerFactory = httpServerFactory;
  }

  int get port => _httpServer!.port;

  static Future<HttpRedirectServer> startServer({
    HttpFactory? httpFactory,
    HttpClientFactory? httpClientFactory,
    HttpServerFactory? httpServerFactory,
    required Options options,
  }) async {
    var server = HttpRedirectServer._(
      httpClientFactory: httpClientFactory ?? httpFactory!.client,
      httpServerFactory: httpServerFactory ?? httpFactory!.server,
      options: options,
    );
    try {
      await server._startServer(options);
    } catch (e) {
      await server.close();
      rethrow;
    }
    return server;
  }

  Future<HttpServer> _startServer(Options options) async {
    var host = options.host ?? InternetAddress.anyIPv4;
    var port = options.port ?? 8180;
    final server = await _httpServerFactory.bind(host, port);
    if (debugHttpRedirectServer) {
      print('listening on ${httpServerGetUri(server)}');
    }
    print('from http://localhost:$port');
    if (options.baseUrl != null) {
      print('default redirection to ${options.baseUrl}');
    }
    server.listen((request) async {
      print('uri: ${request.uri} ${request.method}');
      if (options.handleCors) {
        //request.response.headers.set(HttpHeaders.CONTENT_TYPE, 'text/plain; charset=UTF-8');
        request.response.headers.add(
          'Access-Control-Allow-Methods',
          'POST, OPTIONS, GET, PATCH, DELETE',
        );
        request.response.headers.add('Access-Control-Allow-Origin', '*');
        request.response.headers.add(
          'Access-Control-Allow-Headers',
          // 'Origin,Content-Type,Authorization,Accept,connection,content-length,host,user-agent');
          options.corsHeadersText,
        );

        if (request.method == 'OPTIONS') {
          request.response
            ..statusCode = 200
            ..write('');
          await request.response.close();
          return;
        }
      }
      /*
    var overridenRedirectHostPort =
        parseHostPort(request.headers.value('_tekartik_redirect_host'));
    var redirectHostPort = overridenRedirectHostPort ?? hostPort;
    */
      // compat
      var baseUrl =
          request.headers.value(redirectBaseUrlHeader) ??
          // compat
          request.headers.value('_tekartik_redirect_host') ??
          options.baseUrl;

      var fullUrl = request.headers.value(redirectUrlHeader);

      if (baseUrl == null && fullUrl == null) {
        print('no host port');
        request.response
          ..statusCode = 405
          ..write(
            'missing $redirectBaseUrlHeader header or $redirectUrlHeader',
          );
        await request.response.flush();
        await request.response.close();
      } else {
        client ??= _httpClientFactory.newClient();
        try {
          await proxyHttpRequest(
            options,
            request,
            baseUrl,
            uri: fullUrl != null ? Uri.parse(fullUrl) : null,
            client: client!,
          );
        } catch (e) {
          print('proxyHttpRequest error $e');
          try {
            request.response
              ..statusCode = 405
              ..write('caught error $e');
            await request.response.flush();
            await request.response.close();
          } catch (_) {}
        }
      }
    });
    return _httpServer = server;
  }

  Future<void> close() async {
    var future = _httpServer?.close(force: true);
    client?.close();
    await future;
  }
}
