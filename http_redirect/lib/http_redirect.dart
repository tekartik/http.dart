import 'package:http/http.dart' as http;
import 'package:path/path.dart' as _path;
import 'package:tekartik_common_utils/common_utils_import.dart';
import 'package:tekartik_http/http.dart';

Level? logLevel;

const String redirectBaseUrlHeader = 'x-tekartik-redirect-base-url';

// request
const String hostHeader = 'host';
// response
const String redirectUrlHeader = 'x-tekartik-redirect-url';

final http.Client _client = http.Client();

/// Proxy the HTTP request to the specified server.
Future proxyHttpRequest(Options options, HttpRequest request, String? baseUrl,
    {Uri? uri}) async {
  if (uri == null) {
    var path = request.uri.path;
    if (path.startsWith('/')) {
      path = path.substring(1);
    }

    print('baseUrl: $baseUrl, path: $path, headers: ${request.headers}');
    String? url;
    if (path == '' || path == '.' || path == '/') {
      url = baseUrl;
    } else {
      url = _path.url.join(baseUrl!, path);
      print('baseUrl: $baseUrl, path: $path, url $url');
    }
    uri = Uri.parse(url!);
  }
  print('calling ${request.method} $uri');

  Map<String, String>? headers = <String, String>{};

  request.headers.forEach((name, List<String> values) {
    void _set() {
      headers![name] = values.join(',');
    }

    if (options.forwardedHeaders != null) {
      for (var forwardedHeaders in options.forwardedHeaders!) {
        if (forwardedHeaders.toLowerCase() == name.toLowerCase()) {
          _set();
        }
      }
      return;
    }
    if (options.handleCors) {
      // don't forward redirect url
      if (name == redirectBaseUrlHeader) {
        return;
      }
      // don't forward redirect url
      if (name == redirectUrlHeader) {
        return;
      }
      if (options.containsHeader(name)) {
        _set();
      }
    } else {
      if (name == hostHeader) {
        // don't forward host (likely localhost: 8180)
        // needed for google storage
        return;
      }
      _set();
    }
  });
  print('headers: $headers');

  var bytes = <int>[];
  for (var list in await request.toList()) {
    bytes.addAll(list);
  }

  if ((!options.forwardHeaders!) || false) {
    headers = null;
  }

  var innerResponse = await httpClientSend(_client, request.method, uri,
      body: bytes, headers: headers);
  var innerBody = innerResponse.bodyBytes;
  var innerHeaders = innerResponse.headers;

  // final HttpClientRequest rq = await _client.openUrl(request.method, uri);

  // rq.contentLength = request.contentLength == null ? -1 : request.contentLength;
  /*
  rq
    ..followRedirects = request.
    ..maxRedirects = request.maxRedirects;
*/
  // await rq.addStream(request);
  // final HttpClientResponse rs = await rq.close();
  final r = request.response;

  r.statusCode = innerResponse.statusCode;
  print('response: ${r.statusCode}');
  print('respons headers: ${innerResponse.headers}');

  innerHeaders.forEach((key, values) {
    final lowercaseKey = key.toLowerCase();
    if (lowercaseKey == 'content-length') {
      return;
    }
    if (lowercaseKey == 'content-encoding') {
      return;
    }
    r.headers.set(key, values);
  });
  // r.contentLength = rs.contentLength == null ? -1 : rs.contentLength;
  // r.headers.contentType = ContentType.parse(innerResponse.headers[httpHeaderContentType]); //.contentType;
  print('fwd response headers: ${r.headers}');
  r.headers.set(redirectUrlHeader, uri.toString());

  await r.addStream(Stream.fromIterable([innerBody]));
  await r.flush();
  await r.close();
  print('done');
}

class Options {
  late bool handleCors;
  bool? forwardHeaders;
  int? port;
  Object? host;

  List<String>? forwardedHeaders;

  bool containsHeader(String name) {
    return _lowerCaseCorsHeaders.contains(name.toLowerCase());
  }

  // The default url to redirect too
  String? baseUrl;

  set corsHeaders(List<String> corsHeaders) {
    _corsHeaders = List.from(corsHeaders);
    _corsHeaders!.add(redirectBaseUrlHeader);
    _corsHeaders!.add(redirectUrlHeader);
    _lowerCaseCorsHeaders = <String>[];
    for (var name in _corsHeaders!) {
      _lowerCaseCorsHeaders.add(name.toLowerCase());
    }
  }

  List<String> get corsHeaders => _corsHeaders!;

  List<String>? _corsHeaders;
  late List<String> _lowerCaseCorsHeaders;
  String? _corsHeadersText;

  String get corsHeadersText => _corsHeadersText ??= () {
        if (_corsHeaders == null) {
          corsHeaders = corsDefaultHeaders;
        }
        return corsHeaders.join(',');
      }();
}

///
/// start http redirect server
///
Future<HttpServer> startServer(
    HttpServerFactory factory, Options options) async {
  var host = options.host ?? InternetAddress.anyIPv4;
  var port = options.port ?? 8180;
  final server = await factory.bind(host, port);
  print('listing on $host port $port');
  print('from http://localhost:$port');
  if (options.baseUrl != null) {
    print('default redirection to ${options.baseUrl}');
  }
  server.listen((request) async {
    print('uri: ${request.uri} ${request.method}');
    if (options.handleCors) {
      //request.response.headers.set(HttpHeaders.CONTENT_TYPE, 'text/plain; charset=UTF-8');
      request.response.headers.add(
          'Access-Control-Allow-Methods', 'POST, OPTIONS, GET, PATCH, DELETE');
      request.response.headers.add('Access-Control-Allow-Origin', '*');
      request.response.headers.add(
          'Access-Control-Allow-Headers',
          // 'Origin,Content-Type,Authorization,Accept,connection,content-length,host,user-agent');
          options.corsHeadersText);

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
    var baseUrl = request.headers.value(redirectBaseUrlHeader) ??
        // compat
        request.headers.value('_tekartik_redirect_host') ??
        options.baseUrl;

    var fullUrl = request.headers.value(redirectUrlHeader);

    if (baseUrl == null && fullUrl == null) {
      print('no host port');
      request.response
        ..statusCode = 405
        ..write('missing $redirectBaseUrlHeader header or $redirectUrlHeader');
      await request.response.flush();
      await request.response.close();
    } else {
      try {
        await proxyHttpRequest(options, request, baseUrl,
            uri: fullUrl != null ? Uri.parse(fullUrl) : null);
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
  return server;
}

var corsDefaultHeaders = [
  'Origin',
  'Content-Type',
  'Authorization',
  'Accept',
  'Connection',
  'Content-length',
  'Host',
  'User-Agent'
];
