import 'package:tekartik_common_utils/common_utils_import.dart';
import 'package:tekartik_http/http.dart';
import 'package:tekartik_http/http_server.dart';

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
  print('simple body <${uri}?body=test>');
  print('Failed <${uri}?body=test&statusCode=400>');
  return server;
}
