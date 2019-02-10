import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as _path;
import 'package:tekartik_common_utils/log_utils.dart';
import 'package:tekartik_http/http_server.dart';

Level logLevel;

const String redirectBaseUrlHeader = 'x-tekartik-redirect-base-url';

// request
const String hostHeader = 'host';
// response
const String redirectUrlHeader = 'x-tekartik-redirect-url';

final HttpClient _client = HttpClient();

///

/// Proxy the HTTP request to the specified server.
Future proxyHttpRequest(
    Options options, HttpRequest request, String baseUrl) async {
  var path = request.uri.path;
  if (path.startsWith("/")) {
    path = path.substring(1);
  }

  print("baseUrl: ${baseUrl}, path: ${path}, headers: ${request.headers}");
  String url;
  if (path == "" || path == "." || path == "/") {
    url = baseUrl;
  } else {
    url = _path.url.join(baseUrl, path);
    print("baseUrl: ${baseUrl}, path: ${path}, url ${url}");
  }
  var uri = Uri.parse(url);
  print("calling ${request.method} $uri");
  final HttpClientRequest rq = await _client.openUrl(request.method, uri);

  request.headers.forEach((name, List<String> values) {
    if (options.forwardedHeaders != null) {
      for (var forwardedHeaders in options.forwardedHeaders) {
        if (forwardedHeaders.toLowerCase() == name.toLowerCase()) {
          rq.headers.add(name, values);
        }
      }
      return;
    }
    if (options.handleCors) {
      // don't forward redirect url
      if (name == redirectBaseUrlHeader) {
        return;
      }
      if (options.containsHeader(name)) {
        rq.headers.add(name, values);
      }
    } else {
      if (name == hostHeader) {
        // don't forward host (likely localhost: 8180)
        // needed for google storage
        return;
      }
      rq.headers.add(name, values);
    }
  });
  print("headers: ${rq.headers}");
  rq.contentLength = request.contentLength == null ? -1 : request.contentLength;
  /*
  rq
    ..followRedirects = request.
    ..maxRedirects = request.maxRedirects;
*/
  await rq.addStream(request);
  final HttpClientResponse rs = await rq.close();
  final HttpResponse r = request.response;

  r.statusCode = rs.statusCode;
  print("response: ${r.statusCode}");
  print("respons headers: ${rs.headers}");

  rs.headers.forEach((key, values) {
    String lowercaseKey = key.toLowerCase();
    if (lowercaseKey == 'content-length') {
      return;
    }
    if (lowercaseKey == 'content-encoding') {
      return;
    }
    r.headers.set(key, values.join(','));
  });
  // r.contentLength = rs.contentLength == null ? -1 : rs.contentLength;
  r.headers.contentType = rs.headers.contentType;
  print("fwd response headers: ${r.headers}");
  r.headers.set(redirectUrlHeader, url);
  await r.addStream(rs);
  await r.flush();
  await r.close();
  print("done");
}

class Options {
  bool handleCors;
  int port;
  var host;

  List<String> forwardedHeaders;

  bool containsHeader(String name) {
    return _lowerCaseCorsHeaders.contains(name.toLowerCase());
  }

  // The default url to redirect too
  String baseUrl;

  set corsHeaders(List<String> corsHeaders) {
    _corsHeaders = List.from(corsHeaders);
    _corsHeaders.add(redirectBaseUrlHeader);
    _lowerCaseCorsHeaders = <String>[];
    _corsHeaders.forEach((name) {
      _lowerCaseCorsHeaders.add(name.toLowerCase());
    });
  }

  List<String> get corsHeaders => _corsHeaders;

  List<String> _corsHeaders;
  List<String> _lowerCaseCorsHeaders;
  String _corsHeadersText;

  String get corsHeadersText => _corsHeadersText ??= corsHeaders.join(",");
}

///
/// start http redirect server
///
Future<HttpServer> startServer(
    HttpServerFactory factory, Options options) async {
  HttpServer server = await factory.bind(options.host, options.port);
  print("listing on ${options.host} port ${options.port}");
  print("from http://localhost:${options.port}");
  if (options.baseUrl != null) {
    print("default redirection to ${options.baseUrl}");
  }
  server.listen((request) async {
    print("uri: ${request?.uri} ${request.method}");
    if (options.handleCors) {
      //request.response.headers.set(HttpHeaders.CONTENT_TYPE, "text/plain; charset=UTF-8");
      request.response.headers.add(
          "Access-Control-Allow-Methods", "POST, OPTIONS, GET, PATCH, DELETE");
      request.response.headers.add("Access-Control-Allow-Origin", "*");
      request.response.headers.add(
          'Access-Control-Allow-Headers',
          // "Origin,Content-Type,Authorization,Accept,connection,content-length,host,user-agent");
          options.corsHeadersText);

      if (request.method == 'OPTIONS') {
        request.response
          ..statusCode = 200
          ..write("");
        await request.response.close();
        return;
      }
    }
    /*
    var overridenRedirectHostPort =
        parseHostPort(request.headers.value("_tekartik_redirect_host"));
    var redirectHostPort = overridenRedirectHostPort ?? hostPort;
    */
    // compat
    String baseUrl = request.headers.value(redirectBaseUrlHeader);
    if (baseUrl == null) {
      // compat
      baseUrl = request.headers.value("_tekartik_redirect_host");
      if (baseUrl == null) {
        baseUrl = options.baseUrl;
      }
    }

    if (baseUrl == null) {
      print("no host port");
      request.response
        ..statusCode = 405
        ..write("missing ${redirectBaseUrlHeader} header");
      await request.response.flush();
      await request.response.close();
    } else {
      try {
        await proxyHttpRequest(options, request, baseUrl);
      } catch (e) {
        print("proxyHttpRequest error ${e}");
        try {
          request.response
            ..statusCode = 405
            ..write("caught error $e");
          await request.response.flush();
          await request.response.close();
        } catch (_) {}
      }
    }
  });
  return server;
}

var corsDefaultHeaders = [
  "Origin",
  "Content-Type",
  "Authorization",
  "Accept",
  "Connection",
  "Content-length",
  "Host",
  "User-Agent"
];
