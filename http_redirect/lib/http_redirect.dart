@Deprecated('Use https://github.com/tekartik/http_redirect.dart')
library;

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:tekartik_common_utils/common_utils_import.dart';
import 'package:tekartik_common_utils/log_utils.dart';
import 'package:tekartik_http/http.dart';
import 'package:tekartik_http_redirect/src/http_redirect_server.dart';

export 'src/http_redirect_server.dart' show HttpRedirectServer;

Level? logLevel;

const String redirectBaseUrlHeader = 'x-tekartik-redirect-base-url';

// request
const String hostHeader = 'host';
// response
const String redirectUrlHeader = 'x-tekartik-redirect-url';

void _log(Object? object) {
  // ignore: avoid_print
  print(object);
}

/// Proxy the HTTP request to the specified server.
Future proxyHttpRequest(
  Options options,
  HttpRequest request,
  String? baseUrl, {
  Uri? uri,
  required http.Client client,
}) async {
  if (uri == null) {
    var path = request.uri.path;
    if (path.startsWith('/')) {
      path = path.substring(1);
    }

    if (debugHttpRedirectServer) {
      _log('baseUrl: $baseUrl, path: $path, headers: ${request.headers}');
    }
    String? url;
    if (path == '' || path == '.' || path == '/') {
      url = baseUrl;
    } else {
      url = p.url.join(baseUrl!, path);
      if (debugHttpRedirectServer) {
        _log('baseUrl: $baseUrl, path: $path, url $url');
      }
    }
    uri = Uri.parse(url!);
  }
  if (debugHttpRedirectServer) {
    _log('calling ${request.method} $uri');
  }

  final headers = <String, String>{};

  request.headers.forEach((name, List<String> values) {
    void doSet() {
      headers[name] = values.join(',');
    }

    if (options.forwardedHeaders != null) {
      for (var forwardedHeaders in options.forwardedHeaders!) {
        if (forwardedHeaders.toLowerCase() == name.toLowerCase()) {
          doSet();
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
        doSet();
      }
    } else {
      if (name == hostHeader) {
        // don't forward host (likely localhost: 8180)
        // needed for google storage
        return;
      }
      doSet();
    }
  });
  if (debugHttpRedirectServer) {
    _log('headers: $headers');
  }

  var bytes = <int>[];
  for (var list in await request.toList()) {
    bytes.addAll(list);
  }

  // if ((!options.forwardHeaders) || false) {
  //  headers = null;
  // }

  var innerResponse = await httpClientSend(
    client,
    request.method,
    uri,
    body: bytes,
    headers: headers,
  );
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
  if (debugHttpRedirectServer) {
    _log('response: ${r.statusCode}');
    _log('respons headers: ${innerResponse.headers}');
  }

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
  if (debugHttpRedirectServer) {
    _log('fwd response headers: ${r.headers}');
  }
  r.headers.set(redirectUrlHeader, uri.toString());

  try {
    if (innerBody.isNotEmpty) {
      await r.addStream(Stream.fromIterable([innerBody]));
    }
  } catch (e, st) {
    if (debugHttpRedirectServer) {
      _log(st);
    }
    rethrow;
  }
  try {
    await r.flush();
  } catch (e, st) {
    _log('Error flushing $e');
    if (debugHttpRedirectServer) {
      _log(st);
    }
  }

  try {
    await r.close();
  } catch (e, st) {
    _log('Error closing $e');
    if (debugHttpRedirectServer) {
      _log(st);
    }
  }
  if (debugHttpRedirectServer) {
    _log('done');
  }
}

class Options {
  var handleCors = false;
  var forwardHeaders = false;
  int? port;
  Object? host;

  List<String>? forwardedHeaders;

  bool containsHeader(String name) {
    return _lowerCaseCorsHeaders.contains(name.toLowerCase());
  }

  // The default url to redirect too
  String? baseUrl;

  set corsHeaders(List<String> corsHeaders) {
    corsHeaders = _corsHeaders = List<String>.from(corsHeaders);
    corsHeaders.add(redirectBaseUrlHeader);
    corsHeaders.add(redirectUrlHeader);
    _lowerCaseCorsHeaders = <String>[];
    for (var name in corsHeaders) {
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

/// Client factory of the legacy [startServer], using the default client.
class _DefaultHttpClientFactory implements HttpClientFactory {
  @override
  http.Client newClient() => http.Client();
}

/// start http redirect server
@Deprecated('Use Redirect server')
Future<HttpServer> startServer(
  HttpServerFactory factory,
  Options options,
) async {
  var server = await HttpRedirectServer.startServer(
    httpClientFactory: _DefaultHttpClientFactory(),
    httpServerFactory: factory,
    options: options,
  );
  return server.httpServer;
}

var corsDefaultHeaders = [
  'Origin',
  'Content-Type',
  'Authorization',
  'Accept',
  'Connection',
  'Content-length',
  'Host',
  'User-Agent',
];
