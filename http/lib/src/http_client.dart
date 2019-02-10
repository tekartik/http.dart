import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:meta/meta.dart';
import 'package:tekartik_http/http.dart';
import 'package:tekartik_http/http_client.dart' as http_client;

abstract class HttpClientFactory {
  http.Client newClient();
}

class HttpClientResponse {
  bool get isSuccessful => statusCode < 400;

  final Response _response;
  Response get response => _response;

  int get statusCode => _response.statusCode;

  String _body;

  String get body => _body ??= _response.body;

  Uint8List get bodyBytes => _response.bodyBytes;

  HttpClientResponse(this._response);

  String reasonPhrase;
}

class HttpClientException extends http.ClientException
    implements http_client.HttpClientException {
  final HttpClientResponse response;


  HttpClientException({String message, @required this.response})
      : super(message, parseUri(response.response.request.url));

  @override
  int get statusCode => response.statusCode;
}

Future<HttpClientResponse> httpClientSend(
    http.Client client,
    String method,
    /* Uri | String */ dynamic url,
    {Map<String, String> headers,
    dynamic body,
    Encoding encoding}) async {
  Uri uri = parseUri(url);

  var request = http.Request(method, uri);

  if (headers != null) request.headers.addAll(headers);
  if (encoding != null) request.encoding = encoding;
  if (body != null) {
    if (body is String) {
      request.body = body;
    } else if (body is List) {
      request.bodyBytes = body.cast<int>();
    } else if (body is Map) {
      request.bodyFields = body.cast<String, String>();
    } else {
      throw ArgumentError('Invalid request body "$body".');
    }
  }

  var response = await Response.fromStream(await client.send(request));
  var httpResponse = HttpClientResponse(response);
  return httpResponse;
}


Future<String> httpClientRead(  http.Client client,
    String method,
/* Uri | String */ dynamic url,
{Map<String, String> headers,
    dynamic body,
Encoding encoding}) async {
    var response = await httpClientSend(client, method, url, headers: headers, body: body, encoding: encoding);
    if (_checkResponseSuccess(response)) {
      return response.body;
    } else {
      throw HttpClientException(response: response);
    }



}

/// Throws an error if [response] is not successful.
bool _checkResponseSuccess(HttpClientResponse response) {
  if (response.isSuccessful) {
    return true;
  }

  var message = "Request to ${response.response.request.url} failed with status ${response.statusCode}";
  if (response.reasonPhrase != null) {
    message = "$message: ${response.reasonPhrase}";
  }
  throw HttpClientException(message: message, response: response);
}